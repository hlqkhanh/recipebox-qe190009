class Validators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {bool register = false}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (register && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirm(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm password is required';
    return value == password ? null : 'Passwords do not match';
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return value.runes.length > 80
        ? 'Name must be at most 80 characters'
        : null;
  }

  static String? cookTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Cook time is required';
    return _whole(value, 600)
        ? null
        : 'Cook time must be a whole number from 1 to 600';
  }

  static String? servings(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _whole(value, 20)
        ? null
        : 'Servings must be a whole number from 1 to 20';
  }

  static bool _whole(String text, int max) {
    final trimmed = text.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) return false;
    final value = int.tryParse(trimmed);
    return value != null && value >= 1 && value <= max;
  }

  static String? notes(String? value) => (value ?? '').runes.length > 300
      ? 'Notes must be at most 300 characters'
      : null;
}
