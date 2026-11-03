import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipebox_qe190009/main.dart' as app;
import 'package:recipebox_qe190009/data/recipe.dart';

const testEmail = String.fromEnvironment('TEST_EMAIL');
const testPassword = String.fromEnvironment('TEST_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real Firebase auth, CRUD, filters, favorites, summary and navigation',
    (tester) async {
      Future<void> waitFor(Finder finder, {int seconds = 30}) async {
        for (var i = 0; i < seconds * 5; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (finder.evaluate().isNotEmpty) {
            await tester.pumpAndSettle();
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        fail('Timed out waiting for $finder');
      }

      Future<void> tap(Finder finder) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(finder.first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(finder.first);
        await tester.pumpAndSettle();
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 400));
      }

      Future<void> shot(String name) async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        debugPrint('RECIPEBOX_SCREENSHOT:$name');
        await Future<void>.delayed(const Duration(seconds: 3));
      }

      Future<void> enter(int index, String text) async {
        final field = find.byType(TextFormField).at(index);
        await tester.ensureVisible(field);
        // Native IME can retain a closed test connection after a disabled submit.
        // Set the real field controller so retries replace the entire value reliably.
        tester
            .widget<TextFormField>(field)
            .controller!
            .value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.widget<TextFormField>(field).controller!.text, text);
      }

      Future<void> choose(int index, String choice) async {
        final field = find.byType(DropdownButtonFormField<String>).at(index);
        await tap(field);
        await tester.pumpAndSettle();
        await tester.tap(find.text(choice).last);
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      Future<void> login(String email, String password) async {
        await tap(find.widgetWithText(TextButton, 'Login'));
        await waitFor(find.byType(TextFormField));
        await enter(0, email);
        await enter(1, password);
        await tap(find.widgetWithText(FilledButton, 'Login'));
        await waitFor(find.text('My recipes'));
      }

      Future<void> add(
        String name,
        String category,
        String difficulty,
        int time,
        String notes, {
        int servings = 2,
      }) async {
        await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
        await waitFor(find.byType(TextFormField));
        await enter(0, name);
        await choose(0, category);
        await choose(1, difficulty);
        await enter(1, '$time');
        await enter(2, '$servings');
        await enter(3, notes);
        await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
        await waitFor(find.text('My recipes'));
        await waitFor(find.text(name));
      }

      expect(testEmail, isNotEmpty);
      expect(testPassword, isNotEmpty);
      app.main();
      await waitFor(find.text('RecipeBox'));
      if (FirebaseAuth.instance.currentUser != null) {
        await waitFor(find.text('Logout'));
        await tap(find.text('Logout'));
        await waitFor(find.text('Save your recipes'));
      }
      await shot('01_home');
      await tap(find.widgetWithText(TextButton, 'Register'));
      await tap(find.widgetWithText(FilledButton, 'Register'));
      await waitFor(find.text('Email is required'));
      await shot('02_register_validation');
      final qaEmail =
          'qa.qe190009.${DateTime.now().millisecondsSinceEpoch}@example.com';
      await enter(0, qaEmail);
      await enter(1, testPassword);
      await enter(2, testPassword);
      await tap(find.widgetWithText(FilledButton, 'Register'));
      await waitFor(find.text('Registration successful'));
      await tester.ensureVisible(find.text('Registration successful'));
      await shot('03_register_success');
      await waitFor(find.text('No recipes found'));
      await tester.ensureVisible(find.text('No recipes found'));
      await shot('04_empty_state');
      await tap(find.text('Logout'));
      await waitFor(find.text('Save your recipes'));
      await tap(find.widgetWithText(TextButton, 'Login'));
      await waitFor(find.byType(TextFormField));
      await shot('05_login');
      await enter(0, testEmail);
      await enter(1, 'WrongPasswordForQATest!');
      await tap(find.widgetWithText(FilledButton, 'Login'));
      await waitFor(find.byIcon(Icons.error_outline_rounded));
      await shot('05b_login_server_error');
      await enter(1, testPassword);
      await tap(find.widgetWithText(FilledButton, 'Login'));
      await waitFor(find.text('My recipes'));
      await waitFor(find.widgetWithText(FilledButton, 'Add Recipe'));
      await waitFor(find.textContaining(RegExp(r'^Recipes: ')));

      // Remove only samples created by this test, leaving all other user data intact.
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final collection = FirebaseFirestore.instance.collection('recipes');
      final existing = await collection.where('userId', isEqualTo: uid).get();
      for (final doc in existing.docs) {
        if ((doc.data()['name'] as String).startsWith('QA • ')) {
          await doc.reference.delete();
        }
      }
      await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
      await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
      await waitFor(find.text('Name is required'));
      await tester.ensureVisible(find.text('Name is required'));
      await shot('06_add_validation');
      await back();
      await add(
        'QA • Avocado toast',
        'Breakfast',
        'Easy',
        10,
        'Fresh lemon and pepper.',
      );
      await tester.ensureVisible(find.text('QA • Avocado toast'));
      await shot('07_add_success_recipe');
      await tester.ensureVisible(find.text('Recipe added'));
      await shot('08_add_success_message');
      await add(
        'QA • Garden veggie bowl',
        'Lunch',
        'Easy',
        20,
        'Crisp greens and lemon dressing.',
      );
      await add(
        'QA • Lemon garlic chicken',
        'Dinner',
        'Medium',
        35,
        'Serve with rice.',
      );
      await add(
        'QA • Berry yogurt',
        'Dessert',
        'Easy',
        10,
        'Fresh berries.',
        servings: 1,
      );
      await add(
        'QA • Roasted vegetables',
        'Dinner',
        'Hard',
        50,
        'Slow roast until golden.',
        servings: 4,
      );

      await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
      await enter(0, 'qa • avocado toast');
      await choose(0, 'Breakfast');
      await choose(1, 'Easy');
      await enter(1, '12');
      await tap(find.widgetWithText(FilledButton, 'Add Recipe'));
      await waitFor(find.text('A recipe with this name already exists.'));
      await shot('08b_duplicate_name_rejected');
      await back();

      // Set two favorites through the actual recipe card controls.
      final search = find.byType(TextField).first;
      Future<void> searchFor(String text) async {
        await tester.ensureVisible(search);
        final input = tester.widget<TextField>(search);
        input.controller!.text = text;
        input.onChanged?.call(text);
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }

      for (final name in ['Garden veggie bowl', 'Lemon garlic chicken']) {
        await searchFor(name);
        await tap(find.byTooltip('Add to favorites'));
        await waitFor(find.byTooltip('Remove from favorites'));
      }
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await tester.ensureVisible(find.text('Recipes: 5'));
      await shot('09_summary');
      expect(find.text('Favorites: 2'), findsOneWidget);
      expect(find.text('Total time: 125 min'), findsOneWidget);
      await tap(find.widgetWithText(ChoiceChip, 'Lunch'));
      await tester.ensureVisible(find.text('Recipes: 1'));
      await shot('10_category_filter');
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await tap(find.widgetWithText(ChoiceChip, 'Hard'));
      await tester.ensureVisible(find.text('Recipes: 1'));
      await shot('11_difficulty_filter');
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await tap(find.byType(SwitchListTile));
      await tester.ensureVisible(find.text('Recipes: 2'));
      await shot('12_favorites_filter');
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await searchFor('  LEMON  ');
      await tester.ensureVisible(find.text('Recipes: 3'));
      await shot('13_search_notes');
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await searchFor('Garden veggie bowl');
      await tap(find.text('QA • Garden veggie bowl'));
      await waitFor(find.text('Detail'));
      await shot('14_detail_view');
      await tap(find.widgetWithText(OutlinedButton, 'Edit'));
      await enter(0, '');
      await tap(find.widgetWithText(FilledButton, 'Save'));
      await waitFor(find.text('Name is required'));
      await tester.ensureVisible(find.text('Name is required'));
      await shot('15_edit_validation');
      await enter(0, 'QA • Garden veggie bowl updated');
      await enter(1, '7');
      await tap(find.widgetWithText(FilledButton, 'Save'));
      await waitFor(find.text('Detail'));
      await waitFor(find.text('QA • Garden veggie bowl updated'));
      await shot('16_detail_after_save');
      await tap(find.byTooltip('Remove from favorites'));
      await waitFor(find.byTooltip('Add to favorites'));
      await shot('17_favorite_off');
      await tap(find.byTooltip('Add to favorites'));
      await waitFor(find.byTooltip('Remove from favorites'));
      await shot('18_favorite_on');
      await back();
      await tap(find.byType(SwitchListTile));
      await waitFor(find.text('Recipes: 1'));
      await tap(find.byTooltip('Remove from favorites'));
      await waitFor(find.text('No recipes found'));
      expect(find.text('Recipes: 0'), findsOneWidget);
      await tap(find.widgetWithText(TextButton, 'Clear'));
      await searchFor('Berry yogurt');
      await tap(find.text('QA • Berry yogurt'));
      await tap(find.widgetWithText(TextButton, 'Delete'));
      await waitFor(find.text('Delete this recipe?'));
      await shot('19_delete_confirmation');
      await tap(find.widgetWithText(TextButton, 'Cancel'));
      expect(find.text('Detail'), findsOneWidget);
      await tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await waitFor(find.text('My recipes'));
      await waitFor(find.text('No recipes found'));
      await tester.ensureVisible(find.text('No recipes found'));
      await shot('20_after_delete');
      await tap(find.widgetWithText(TextButton, 'Clear'));
      final saved = await collection
          .doc(recipeDocumentId(uid, 'QA • Garden veggie bowl updated'))
          .get(const GetOptions(source: Source.server));
      expect(saved.data()!['cookTime'], 7);
      expect(saved.data()!['favorite'], false);
      final removed = await collection
          .doc(recipeDocumentId(uid, 'QA • Berry yogurt'))
          .get();
      expect(removed.exists, false);

      // Authenticated root replaces the auth forms rather than leaving them in Back history.
      expect(
        Navigator.of(tester.element(find.text('My recipes'))).canPop(),
        false,
      );
      expect(find.text('My recipes'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await tap(find.text('Logout'));
      await waitFor(find.text('Save your recipes'));
      await login(qaEmail, testPassword);
      await waitFor(find.text('No recipes found'));
      await tap(find.text('Logout'));
      await waitFor(find.text('Save your recipes'));
      await login(testEmail, testPassword);
      await waitFor(find.text('Recipes: 4'));
      await tester.ensureVisible(find.text('My recipes'));
      await shot('21_list_header');
      await tester.ensureVisible(find.text('QA • Lemon garlic chicken'));
      await shot('22_list_collection');
      expect(tester.takeException(), isNull);
    },
  );
}
