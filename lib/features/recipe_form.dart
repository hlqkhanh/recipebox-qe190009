import 'package:flutter/material.dart';

import '../data/recipe.dart';
import '../data/services.dart';
import '../data/validators.dart';
import '../ui/design.dart';

class RecipeForm extends StatefulWidget {
  const RecipeForm({
    super.key,
    this.initial,
    required this.onSave,
    this.onCancel,
  });
  final Recipe? initial;
  final Future<void> Function(RecipeDraft draft) onSave;
  final VoidCallback? onCancel;
  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _cookTime, _servings, _notes;
  late String _category, _difficulty;
  bool _submitted = false, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _name = TextEditingController(text: r?.name ?? '');
    _cookTime = TextEditingController(text: r?.cookTime.toString() ?? '');
    _servings = TextEditingController(text: r?.servings?.toString() ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
    _category = r?.category ?? '';
    _difficulty = r?.difficulty ?? '';
  }

  @override
  void dispose() {
    for (final c in [_name, _cookTime, _servings, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.onSave(
        RecipeDraft(
          name: _name.text.trim(),
          category: _category,
          difficulty: _difficulty,
          cookTime: int.parse(_cookTime.text.trim()),
          servings: _servings.text.trim().isEmpty
              ? null
              : int.parse(_servings.text.trim()),
          notes: _notes.text,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = serviceError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _text(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    String? hint,
    bool numeric = false,
    int lines = 1,
  }) => LabeledInput(
    label: label,
    child: TextFormField(
      controller: controller,
      validator: validator,
      enabled: !_busy,
      keyboardType: numeric
          ? TextInputType.number
          : lines > 1
          ? TextInputType.multiline
          : TextInputType.text,
      textCapitalization: numeric
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      textInputAction: lines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      minLines: lines,
      maxLines: lines,
      decoration: InputDecoration(hintText: hint),
    ),
  );
  Widget _dropdown(
    String label,
    String selected,
    List<String> options,
    String hint,
    String error,
    ValueChanged<String?> onChanged,
  ) => LabeledInput(
    label: label,
    child: DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      validator: (v) => v == null || v.isEmpty ? error : null,
      decoration: const InputDecoration(),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(hint, style: const TextStyle(color: Palette.secondary)),
        ),
        ...options.map(
          (item) => DropdownMenuItem(value: item, child: Text(item)),
        ),
      ],
      onChanged: _busy ? null : onChanged,
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Form(
      key: _form,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text(
            'Name',
            _name,
            Validators.name,
            hint: 'e.g. Lemon garlic chicken',
          ),
          _dropdown(
            'Category',
            _category,
            categories,
            'Choose category',
            'Please choose a category',
            (v) => setState(() => _category = v ?? ''),
          ),
          _dropdown(
            'Difficulty',
            _difficulty,
            difficulties,
            'Choose difficulty',
            'Please choose a difficulty',
            (v) => setState(() => _difficulty = v ?? ''),
          ),
          _text(
            'Cook time',
            _cookTime,
            Validators.cookTime,
            hint: 'Minutes · 1–600',
            numeric: true,
          ),
          _text(
            'Servings (optional)',
            _servings,
            Validators.servings,
            hint: '1–20 servings',
            numeric: true,
          ),
          _text(
            'Notes (optional)',
            _notes,
            Validators.notes,
            hint: 'A little reminder for next time…',
            lines: 4,
          ),
          SubmitButton(
            label: widget.initial == null ? 'Add Recipe' : 'Save',
            busy: _busy,
            onPressed: _submit,
            icon: widget.initial == null
                ? Icons.add_rounded
                : Icons.check_rounded,
          ),
          if (_error != null) StatusBanner(_error!, error: true),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
