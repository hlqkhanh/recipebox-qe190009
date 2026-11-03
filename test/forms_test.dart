import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipebox_qe190009/features/auth_screens.dart';
import 'package:recipebox_qe190009/features/recipe_form.dart';
import 'package:recipebox_qe190009/ui/design.dart';

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: recipeTheme(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: child,
  ),
);

void main() {
  testWidgets('home has required feature cards at 360dp and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(HomeScreen(onLogin: () {}, onRegister: () {}), scale: 1.8),
    );
    expect(find.text('Save your recipes'), findsOneWidget);
    expect(find.text('Sort by cooking time'), findsOneWidget);
    expect(find.text('Mark your favorites'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'register blank initially, submit errors, corrected email clears, server error stays on form',
    (tester) async {
      await tester.pumpWidget(
        host(
          AuthScreen(
            register: true,
            onSubmit: (_, _, _) async =>
                throw Exception('Backend rejected request'),
          ),
        ),
      );
      expect(find.text('Email is required'), findsNothing);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Register'));
      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm password is required'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'qa@example.com',
      );
      await tester.pump();
      expect(find.text('Email is required'), findsNothing);
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Register'));
      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Backend rejected request'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shared recipe form shows exact errors only after submit and supports 360dp keyboard layout',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: RecipeForm(onSave: (_) async {}),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Name is required'), findsNothing);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Add Recipe'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Add Recipe'));
      await tester.pump();
      for (final error in [
        'Name is required',
        'Please choose a category',
        'Please choose a difficulty',
        'Cook time is required',
      ]) {
        expect(find.text(error), findsOneWidget);
      }
      await tester.enterText(find.byType(TextFormField).first, 'Soup');
      await tester.pump();
      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Cook time is required'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
