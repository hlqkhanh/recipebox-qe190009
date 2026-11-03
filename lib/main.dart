import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'ui/design.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<FirebaseApp> _initialization;
  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<FirebaseApp> _initialize() =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasData) return const RecipeBoxApp();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: recipeTheme(),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Content(
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Brand(),
                          const SizedBox(height: 20),
                          StatusBanner(
                            'Unable to initialize Firebase. ${snapshot.error}',
                            error: true,
                          ),
                          const SizedBox(height: 16),
                          SubmitButton(
                            label: 'Retry',
                            onPressed: () =>
                                setState(() => _initialization = _initialize()),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}
