import 'package:flutter_test/flutter_test.dart';
import 'package:recipebox_qe190009/data/recipe.dart';
import 'package:recipebox_qe190009/data/validators.dart';

Recipe recipe(
  String name,
  String category,
  int time, {
  bool favorite = false,
  String difficulty = 'Easy',
  String notes = '',
}) => Recipe(
  id: name,
  userId: 'user',
  name: name,
  category: category,
  difficulty: difficulty,
  cookTime: time,
  favorite: favorite,
  createdAt: null,
  notes: notes,
);

void main() {
  test('sort by time then case-insensitive name and combine all filters', () {
    final recipes = [
      recipe('Zulu', 'Dinner', 15, favorite: true),
      recipe('apple', 'Dinner', 15, favorite: true, notes: 'Fresh lemon'),
      recipe('Fast', 'Lunch', 5),
      recipe('Apple cake', 'Dessert', 25, difficulty: 'Hard'),
    ];
    expect(const RecipeFilter().apply(recipes).map((r) => r.name), [
      'Fast',
      'apple',
      'Zulu',
      'Apple cake',
    ]);
    expect(
      const RecipeFilter(
        category: 'Dinner',
        difficulty: 'Easy',
        favoritesOnly: true,
        search: ' LEMON ',
      ).apply(recipes).map((r) => r.name),
      ['apple'],
    );
    expect(
      const RecipeFilter(category: 'Lunch', favoritesOnly: true).apply(recipes),
      isEmpty,
    );
  });
  test('summary uses visible records and category tie order', () {
    final data = [
      recipe('a', 'Lunch', 5),
      recipe('b', 'Breakfast', 10, favorite: true),
      recipe('c', 'Dinner', 25),
      recipe('d', 'Dinner', 15, favorite: true),
    ];
    final summary = RecipeSummary(data);
    expect(summary.count, 4);
    expect(summary.favorites, 2);
    expect(summary.totalTime, 55);
    expect(summary.breakdown.map((e) => e.key), [
      'Dinner',
      'Breakfast',
      'Lunch',
    ]);
    final empty = RecipeSummary([]);
    expect(empty.totalTime, 0);
    expect(empty.breakdown, isEmpty);
  });
  test(
    'canonical id is case-insensitive, user-specific, Unicode and slash safe',
    () {
      expect(
        recipeDocumentId('u', ' Pho Bo '),
        recipeDocumentId('u', 'pho bo'),
      );
      expect(recipeDocumentId('u', 'Phở Bò'), recipeDocumentId('u', 'PHỞ BÒ'));
      expect(recipeDocumentId('u', 'a/b'), isNot(contains('/')));
      expect(recipeDocumentId('a', 'Pho'), isNot(recipeDocumentId('b', 'Pho')));
    },
  );
  test('auth exact validation and login allows short nonempty password', () {
    expect(Validators.email(''), 'Email is required');
    expect(Validators.email('bad'), 'Please enter a valid email address');
    expect(Validators.email('a@example.com'), isNull);
    expect(Validators.password(''), 'Password is required');
    expect(Validators.password('a'), isNull);
    expect(
      Validators.password('a', register: true),
      'Password must be at least 6 characters',
    );
    expect(Validators.confirm('', 'secret'), 'Confirm password is required');
    expect(Validators.confirm('other', 'secret'), 'Passwords do not match');
  });
  test('recipe validation boundaries and non-integer inputs', () {
    expect(Validators.name('  '), 'Name is required');
    expect(Validators.name('a' * 81), 'Name must be at most 80 characters');
    expect(Validators.cookTime(''), 'Cook time is required');
    for (final value in ['0', '601', '1.5', '2e1', '-1', 'abc']) {
      expect(
        Validators.cookTime(value),
        'Cook time must be a whole number from 1 to 600',
      );
    }
    expect(Validators.cookTime('1'), isNull);
    expect(Validators.cookTime('600'), isNull);
    expect(Validators.servings(''), isNull);
    expect(Validators.servings('20'), isNull);
    expect(
      Validators.servings('21'),
      'Servings must be a whole number from 1 to 20',
    );
    expect(Validators.notes('n' * 301), 'Notes must be at most 300 characters');
  });
}
