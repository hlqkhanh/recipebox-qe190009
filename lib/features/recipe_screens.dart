import 'package:flutter/material.dart';

import '../data/recipe.dart';
import '../data/services.dart';
import '../ui/design.dart';
import 'recipe_form.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({
    super.key,
    required this.store,
    required this.email,
    required this.onLogout,
    this.notice,
  });
  final RecipeStore store;
  final String email;
  final Future<void> Function() onLogout;
  final String? notice;
  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _search = TextEditingController();
  String _category = 'All', _difficulty = 'All';
  bool _favorites = false, _loggingOut = false;
  String? _notice;
  @override
  void initState() {
    super.initState();
    _notice = widget.notice;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _search.clear();
    _category = 'All';
    _difficulty = 'All';
    _favorites = false;
  });
  Future<void> _add() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddRecipeScreen(store: widget.store)),
    );
    if (added == true && mounted) {
      setState(() {
        _notice = 'Recipe added';
      });
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } catch (e) {
      if (mounted) {
        showError(context, serviceError(e));
        setState(() => _loggingOut = false);
      }
    }
  }

  Widget _chips(
    String title,
    List<String> choices,
    String selected,
    ValueChanged<String> choose,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Palette.secondary,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 7,
        runSpacing: 3,
        children: ['All', ...choices]
            .map(
              (item) => ChoiceChip(
                label: Text(item),
                selected: selected == item,
                onSelected: (_) => choose(item),
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            )
            .toList(),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final store = widget.store;
          final visible = RecipeFilter(
            category: _category,
            difficulty: _difficulty,
            favoritesOnly: _favorites,
            search: _search.text,
          ).apply(store.visibleData);
          return SingleChildScrollView(
            child: Content(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Brand()),
                      TextButton.icon(
                        onPressed: _loggingOut ? null : _logout,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.secondary,
                    ),
                  ),
                  if (_notice != null) StatusBanner(_notice!),
                  const SizedBox(height: 28),
                  Text(
                    'My recipes',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep your favorites close.',
                    style: TextStyle(color: Palette.secondary),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search recipes or notes',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () => setState(_search.clear),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: Palette.primary,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Filters',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: _clear,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        _chips(
                          'Category',
                          categories,
                          _category,
                          (v) => setState(() => _category = v),
                        ),
                        const SizedBox(height: 12),
                        _chips(
                          'Difficulty',
                          difficulties,
                          _difficulty,
                          (v) => setState(() => _difficulty = v),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Favorites only',
                            style: TextStyle(fontSize: 14),
                          ),
                          secondary: const Icon(
                            Icons.star_outline_rounded,
                            color: Palette.gold,
                          ),
                          value: _favorites,
                          onChanged: (v) => setState(() => _favorites = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (store.loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (store.error != null)
                    StatusBanner(store.error!, error: true)
                  else ...[
                    RecipeSummaryCard(RecipeSummary(visible)),
                    const SizedBox(height: 24),
                    Text(
                      'Your collection',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                  SubmitButton(
                    label: 'Add Recipe',
                    onPressed: _add,
                    icon: Icons.add_rounded,
                  ),
                  const SizedBox(height: 18),
                  if (!store.loading && store.error == null)
                    if (visible.isEmpty)
                      const Panel(
                        color: Palette.mintLight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Column(
                            children: [
                              CategoryArt('', size: 64),
                              SizedBox(height: 16),
                              Text(
                                'No recipes found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.deep,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add a recipe or try clearing your filters.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Palette.secondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...visible.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RecipeCard(
                            recipe: r,
                            favoriteBusy: store.favoriteBusy.contains(r.id),
                            onFavorite: () async {
                              try {
                                await store.toggleFavorite(r);
                              } catch (e) {
                                if (context.mounted) {
                                  showError(context, serviceError(e));
                                }
                              }
                            },
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(store: store, recipe: r),
                              ),
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class RecipeSummaryCard extends StatelessWidget {
  const RecipeSummaryCard(this.summary, {super.key});
  final RecipeSummary summary;
  @override
  Widget build(BuildContext context) => Panel(
    color: Palette.mintLight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 18,
              color: Palette.primary,
            ),
            SizedBox(width: 8),
            Text('At a glance', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 22,
          runSpacing: 8,
          children: [
            Text(
              'Recipes: ${summary.count}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Favorites: ${summary.favorites}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Total time: ${summary.totalTime} min',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (summary.breakdown.isNotEmpty) ...[
          const Divider(),
          ...summary.breakdown.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Palette.secondary),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    required this.onFavorite,
    this.favoriteBusy = false,
  });
  final Recipe recipe;
  final VoidCallback onOpen, onFavorite;
  final bool favoriteBusy;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Palette.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryArt(recipe.category),
                const Spacer(),
                IconButton(
                  tooltip: recipe.favorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: favoriteBusy ? null : onFavorite,
                  icon: Icon(
                    recipe.favorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: recipe.favorite ? Palette.gold : Palette.secondary,
                    size: 29,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              recipe.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [Tag(recipe.category), Tag(recipe.difficulty)],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: Palette.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${recipe.cookTime} min',
                    style: const TextStyle(color: Palette.secondary),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: Palette.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key, required this.store});
  final RecipeStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add Recipe')),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Content(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Something worth keeping.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Save a little inspiration for your next meal.',
                style: TextStyle(color: Palette.secondary),
              ),
              const SizedBox(height: 24),
              Panel(
                child: RecipeForm(
                  onSave: (draft) async {
                    await store.save(draft);
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.store,
    required this.recipe,
  });
  final RecipeStore store;
  final Recipe recipe;
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late String _id;
  late Recipe _last;
  bool _editing = false, _deleting = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _id = widget.recipe.id;
    _last = widget.recipe;
  }

  Future<void> _delete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this recipe?'),
        content: Text('“${recipe.name}” will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Palette.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await widget.store.delete(recipe);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = serviceError(e);
          _deleting = false;
        });
      }
    }
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Palette.secondary)),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_deleting,
    child: Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Recipe' : 'Detail')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            final current = widget.store.byId(_id);
            if (current != null) _last = current;
            final recipe = current ?? _last;
            return SingleChildScrollView(
              child: Content(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_editing)
                      Panel(
                        child: RecipeForm(
                          initial: recipe,
                          onCancel: () => setState(() => _editing = false),
                          onSave: (draft) async {
                            final id = await widget.store.save(
                              draft,
                              original: recipe,
                            );
                            if (mounted) {
                              setState(() {
                                _id = id;
                                _last = widget.store.byId(id) ?? _last;
                                _editing = false;
                              });
                            }
                          },
                        ),
                      )
                    else ...[
                      Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CategoryArt(recipe.category, size: 76),
                                const Spacer(),
                                IconButton(
                                  tooltip: recipe.favorite
                                      ? 'Remove from favorites'
                                      : 'Add to favorites',
                                  onPressed:
                                      _deleting ||
                                          widget.store.favoriteBusy.contains(
                                            recipe.id,
                                          )
                                      ? null
                                      : () async {
                                          try {
                                            await widget.store.toggleFavorite(
                                              recipe,
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              setState(
                                                () => _error = serviceError(e),
                                              );
                                            }
                                          }
                                        },
                                  icon: Icon(
                                    recipe.favorite
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 32,
                                    color: recipe.favorite
                                        ? Palette.gold
                                        : Palette.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              recipe.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Tag(recipe.category),
                                Tag(recipe.difficulty),
                              ],
                            ),
                            const Divider(),
                            _row('Category', recipe.category),
                            _row('Difficulty', recipe.difficulty),
                            _row('Cook time', '${recipe.cookTime} min'),
                            _row(
                              'Servings',
                              recipe.servings?.toString() ?? 'Not specified',
                            ),
                            const Divider(),
                            const Text(
                              'Notes',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              recipe.notes.isEmpty
                                  ? 'No notes added'
                                  : recipe.notes,
                              style: const TextStyle(color: Palette.secondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleting
                              ? null
                              : () => setState(() => _editing = true),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _deleting ? null : () => _delete(recipe),
                          style: TextButton.styleFrom(
                            foregroundColor: Palette.error,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(_deleting ? 'Deleting…' : 'Delete'),
                        ),
                      ),
                      if (_error != null) StatusBanner(_error!, error: true),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
