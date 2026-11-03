import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

const categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
const difficulties = ['Easy', 'Medium', 'Hard'];

String recipeDocumentId(String uid, String name) {
  final hex = utf8
      .encode(name.trim().toLowerCase())
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
  return '${uid}__$hex';
}

class RecipeDraft {
  const RecipeDraft({
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.notes = '',
  });
  final String name, category, difficulty, notes;
  final int cookTime;
  final int? servings;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    required this.favorite,
    required this.createdAt,
    this.servings,
    this.notes = '',
  });
  final String id, userId, name, category, difficulty, notes;
  final int cookTime;
  final int? servings;
  final bool favorite;
  final Timestamp? createdAt;

  factory Recipe.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Recipe(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      category: data['category'] as String,
      difficulty: data['difficulty'] as String,
      cookTime: (data['cookTime'] as num).toInt(),
      servings: (data['servings'] as num?)?.toInt(),
      notes: data['notes'] as String? ?? '',
      favorite: data['favorite'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Recipe withFavorite(bool value) => Recipe(
    id: id,
    userId: userId,
    name: name,
    category: category,
    difficulty: difficulty,
    cookTime: cookTime,
    servings: servings,
    notes: notes,
    favorite: value,
    createdAt: createdAt,
  );
}

class RecipeFilter {
  const RecipeFilter({
    this.category = 'All',
    this.difficulty = 'All',
    this.favoritesOnly = false,
    this.search = '',
  });
  final String category, difficulty, search;
  final bool favoritesOnly;
  List<Recipe> apply(Iterable<Recipe> recipes) {
    final query = search.trim().toLowerCase();
    final result = recipes
        .where(
          (r) =>
              (category == 'All' || category == r.category) &&
              (difficulty == 'All' || difficulty == r.difficulty) &&
              (!favoritesOnly || r.favorite) &&
              (query.isEmpty ||
                  r.name.toLowerCase().contains(query) ||
                  r.notes.toLowerCase().contains(query)),
        )
        .toList();
    result.sort((a, b) {
      final time = a.cookTime.compareTo(b.cookTime);
      if (time != 0) return time;
      final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return name != 0 ? name : a.id.compareTo(b.id);
    });
    return result;
  }
}

class RecipeSummary {
  RecipeSummary(List<Recipe> recipes)
    : count = recipes.length,
      favorites = recipes.where((r) => r.favorite).length,
      totalTime = recipes.fold(0, (total, r) => total + r.cookTime),
      breakdown = _breakdown(recipes);
  final int count, favorites, totalTime;
  final List<MapEntry<String, int>> breakdown;
  static List<MapEntry<String, int>> _breakdown(List<Recipe> recipes) {
    final counts = <String, int>{};
    for (final r in recipes) {
      counts.update(r.category, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts.entries.toList()..sort((a, b) {
      final count = b.value.compareTo(a.value);
      return count != 0
          ? count
          : categories.indexOf(a.key).compareTo(categories.indexOf(b.key));
    });
  }
}
