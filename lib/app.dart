import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/services.dart';
import 'features/auth_screens.dart';
import 'features/recipe_screens.dart';
import 'ui/design.dart';

class RecipeBoxApp extends StatefulWidget {
  const RecipeBoxApp({super.key});
  @override
  State<RecipeBoxApp> createState() => _RecipeBoxAppState();
}

class _RecipeBoxAppState extends State<RecipeBoxApp> {
  late final Session _session;
  @override
  void initState() {
    super.initState();
    _session = Session(FirebaseAuth.instance);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RecipeBox',
    debugShowCheckedModeBanner: false,
    theme: recipeTheme(),
    home: AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        if (_session.checking) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = _session.user;
        if (user != null) {
          return _SignedInArea(
            key: ValueKey(user.uid),
            session: _session,
            user: user,
          );
        }
        return _PublicArea(key: const ValueKey('public'), session: _session);
      },
    ),
  );
}

class _PublicArea extends StatefulWidget {
  const _PublicArea({super.key, required this.session});
  final Session session;
  @override
  State<_PublicArea> createState() => _PublicAreaState();
}

class _PublicAreaState extends State<_PublicArea> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => NavigatorPopHandler(
    onPopWithResult: (_) => _navigator.currentState?.pop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => HomeScreen(
          onLogin: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuthScreen(
                register: false,
                onSubmit: widget.session.authenticate,
              ),
            ),
          ),
          onRegister: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuthScreen(
                register: true,
                onSubmit: widget.session.authenticate,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SignedInArea extends StatefulWidget {
  const _SignedInArea({super.key, required this.session, required this.user});
  final Session session;
  final User user;
  @override
  State<_SignedInArea> createState() => _SignedInAreaState();
}

class _SignedInAreaState extends State<_SignedInArea> {
  late final RecipeStore _store;
  final _navigator = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    _store = RecipeStore(widget.user.uid);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NavigatorPopHandler(
    onPopWithResult: (_) => _navigator.currentState?.pop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => RecipeListScreen(
          store: _store,
          email: widget.user.email ?? '',
          onLogout: widget.session.logout,
          notice: widget.session.notice,
        ),
      ),
    ),
  );
}
