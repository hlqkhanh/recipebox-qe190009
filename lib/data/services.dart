import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'recipe.dart';

String serviceError(Object error) {
  if (error is FirebaseException) return error.message ?? error.code;
  return error.toString();
}

class Session extends ChangeNotifier {
  Session(this.auth) {
    _subscription = auth.authStateChanges().listen(
      (value) {
        if (_authAction) return;
        user = value;
        checking = false;
        notifyListeners();
      },
      onError: (Object e) {
        checking = false;
        error = serviceError(e);
        notifyListeners();
      },
    );
  }
  final FirebaseAuth auth;
  late final StreamSubscription<User?> _subscription;
  User? user;
  bool checking = true, _authAction = false;
  String? notice, error;

  Future<void> authenticate(
    String email,
    String password,
    bool register,
  ) async {
    _authAction = true;
    try {
      final result = register
          ? await auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            )
          : await auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
      user = result.user;
      checking = false;
      notice = register ? 'Registration successful' : null;
      notifyListeners();
    } finally {
      _authAction = false;
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    user = null;
    notice = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RecipeStore extends ChangeNotifier {
  RecipeStore(this.uid, {FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance {
    _subscription = collection
        .where('userId', isEqualTo: uid)
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.hasPendingWrites)
        .listen(
          (snapshot) {
            recipes = snapshot.docs.map(Recipe.fromDocument).toList();
            loading = false;
            error = null;
            notifyListeners();
          },
          onError: (Object e) {
            loading = false;
            error = serviceError(e);
            notifyListeners();
          },
        );
  }
  final String uid;
  final FirebaseFirestore db;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  _subscription;
  CollectionReference<Map<String, dynamic>> get collection =>
      db.collection('recipes');
  List<Recipe> recipes = [];
  bool loading = true;
  String? error;
  final Map<String, bool> _favoriteOverrides = {};
  final Set<String> favoriteBusy = {};
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<Recipe> get visibleData => recipes
      .map(
        (r) => _favoriteOverrides.containsKey(r.id)
            ? r.withFavorite(_favoriteOverrides[r.id]!)
            : r,
      )
      .toList();
  Recipe? byId(String id) {
    for (final r in visibleData) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<String> save(RecipeDraft draft, {Recipe? original}) async {
    final id = recipeDocumentId(uid, draft.name);
    final target = collection.doc(id);
    await db.runTransaction((transaction) async {
      // All reads precede writes; transactions serialize concurrent duplicates.
      final existing = await transaction.get(target);
      DocumentSnapshot<Map<String, dynamic>>? previous;
      if (original != null) {
        previous = original.id == id
            ? existing
            : await transaction.get(collection.doc(original.id));
        if (!previous.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'This recipe no longer exists.',
          );
        }
      }
      if (existing.exists && (original == null || original.id != id)) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'A recipe with this name already exists.',
        );
      }
      final old = previous?.data();
      final data = <String, dynamic>{
        'id': id,
        'userId': uid,
        'name': draft.name.trim(),
        'category': draft.category,
        'difficulty': draft.difficulty,
        'cookTime': draft.cookTime,
        'favorite': old?['favorite'] ?? false,
        'notes': draft.notes,
        'createdAt': old?['createdAt'] ?? FieldValue.serverTimestamp(),
        if (draft.servings != null) 'servings': draft.servings,
      };
      transaction.set(target, data);
      if (original != null && original.id != id) {
        transaction.delete(collection.doc(original.id));
      }
    });
    final saved = await target.get(const GetOptions(source: Source.server));
    final recipe = Recipe.fromDocument(saved);
    recipes = [
      ...recipes.where((r) => r.id != id && r.id != original?.id),
      recipe,
    ];
    notifyListeners();
    return id;
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    if (favoriteBusy.contains(recipe.id)) return;
    favoriteBusy.add(recipe.id);
    _favoriteOverrides[recipe.id] = !recipe.favorite;
    notifyListeners();
    try {
      await db.runTransaction((transaction) async {
        final ref = collection.doc(recipe.id);
        final current = await transaction.get(ref);
        if (!current.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'This recipe no longer exists.',
          );
        }
        transaction.update(ref, {'favorite': !recipe.favorite});
      });
      recipes = recipes
          .map((r) => r.id == recipe.id ? r.withFavorite(!recipe.favorite) : r)
          .toList();
    } finally {
      _favoriteOverrides.remove(recipe.id);
      favoriteBusy.remove(recipe.id);
      notifyListeners();
    }
  }

  Future<void> delete(Recipe recipe) async {
    await collection.doc(recipe.id).delete();
    recipes = recipes.where((r) => r.id != recipe.id).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
