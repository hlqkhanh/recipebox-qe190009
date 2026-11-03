import 'package:flutter/material.dart';

abstract final class Palette {
  static const deep = Color(0xFF173D32),
      primary = Color(0xFF236A54),
      mint = Color(0xFFDDF2E5);
  static const mintLight = Color(0xFFEFF8F1),
      coral = Color(0xFFE95D4F),
      canvas = Color(0xFFFAFAF6);
  static const text = Color(0xFF1E322A),
      secondary = Color(0xFF65746C),
      border = Color(0xFFE3E9E2);
  static const error = Color(0xFFC73838), gold = Color(0xFFE7A936);
}

ThemeData recipeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.primary,
      primary: Palette.primary,
      secondary: Palette.coral,
      surface: Colors.white,
      error: Palette.error,
    ),
    scaffoldBackgroundColor: Palette.canvas,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: Palette.text, displayColor: Palette.deep)
        .copyWith(
          headlineLarge: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 38,
            height: 1.16,
            fontWeight: FontWeight.w800,
            color: Palette.deep,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 28,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: Palette.deep,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Palette.deep,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Palette.deep,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            height: 1.5,
            color: Palette.text,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.canvas,
      foregroundColor: Palette.deep,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      hintStyle: const TextStyle(color: Palette.secondary, fontSize: 14),
      errorMaxLines: 4,
      errorStyle: const TextStyle(
        fontSize: 12,
        height: 1.4,
        color: Palette.error,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.error),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.coral,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: shape,
        textStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.primary,
        minimumSize: const Size(48, 52),
        shape: shape,
        side: const BorderSide(color: Palette.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.primary,
        minimumSize: const Size(48, 48),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: Palette.mint,
      side: const BorderSide(color: Palette.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: Palette.deep,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Palette.border, space: 28),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.deep,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class Content extends StatelessWidget {
  const Content({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Palette.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0916392B),
          offset: Offset(0, 4),
          blurRadius: 18,
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 9,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.mint,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.menu_book_rounded, size: 22, color: Palette.deep),
        ),
      ),
      Text(
        'RecipeBox',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Palette.deep,
        ),
      ),
    ],
  );
}

class StatusBanner extends StatelessWidget {
  const StatusBanner(this.message, {super.key, this.error = false});
  final String message;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(top: 12),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFF1F0) : const Color(0xFFE8F6EC),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 20,
          color: error ? Palette.error : Palette.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: error ? Palette.error : Palette.primary),
          ),
        ),
      ],
    ),
  );
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [if (icon != null) Icon(icon, size: 20), Text(label)],
            ),
    ),
  );
}

class LabeledInput extends StatelessWidget {
  const LabeledInput({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class CategoryArt extends StatelessWidget {
  const CategoryArt(this.category, {super.key, this.size = 56});
  final String category;
  final double size;
  @override
  Widget build(BuildContext context) {
    final (icon, background) = switch (category) {
      'Breakfast' => (Icons.bakery_dining_rounded, const Color(0xFFFFEED6)),
      'Lunch' => (Icons.ramen_dining_rounded, Palette.mint),
      'Dinner' => (Icons.dinner_dining_rounded, const Color(0xFFE9EDFB)),
      'Dessert' => (Icons.cake_outlined, const Color(0xFFFFE8E2)),
      _ => (Icons.menu_book_rounded, Palette.mint),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Palette.deep, size: size * .49),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Palette.mintLight,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: Palette.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(error.toString())));
}
