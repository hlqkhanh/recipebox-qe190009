import 'package:flutter/material.dart';

import '../data/services.dart';
import '../data/validators.dart';
import '../ui/design.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });
  final VoidCallback onLogin, onRegister;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Content(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  const Brand(),
                  Wrap(
                    children: [
                      TextButton(
                        onPressed: onLogin,
                        child: const Text('Login'),
                      ),
                      TextButton(
                        onPressed: onRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Palette.mint,
                      Palette.mintLight,
                      Color(0xFFF8F6ED),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A LITTLE SPACE FOR GOOD FOOD',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.7,
                        fontWeight: FontWeight.w800,
                        color: Palette.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RecipeBox',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your recipes, beautifully organized.',
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.5,
                        color: Palette.deep,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Keep the meals you love and the ones you can’t wait to try. Your own private cookbook, all in one place.',
                      style: TextStyle(color: Palette.secondary),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        height: 120,
                        width: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: -.14,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .8),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 66,
                                  color: Palette.primary,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 8,
                              top: 1,
                              child: CategoryArt('Dessert', size: 53),
                            ),
                            const Positioned(
                              left: 5,
                              bottom: 1,
                              child: CategoryArt('Breakfast', size: 51),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubmitButton(
                      label: 'Register',
                      onPressed: onRegister,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Made for your everyday cooking',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const _Feature(
                Icons.menu_book_rounded,
                'Save your recipes',
                'A private home for your tried-and-true dishes and new ideas.',
              ),
              const _Feature(
                Icons.schedule_rounded,
                'Sort by cooking time',
                'Find something that fits the time you have.',
              ),
              const _Feature(
                Icons.star_outline_rounded,
                'Mark your favorites',
                'Keep your go-to recipes close, whenever you need them.',
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Your kitchen. Your collection.',
                  style: TextStyle(color: Palette.secondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title, description;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Palette.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Palette.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Palette.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.register, required this.onSubmit});
  final bool register;
  final Future<void> Function(String email, String password, bool register)
  onSubmit;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _submitted = false,
      _busy = false,
      _hidePassword = true,
      _hideConfirm = true;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await widget.onSubmit(
        _email.text.trim(),
        _password.text,
        widget.register,
      );
    } catch (e) {
      if (mounted) setState(() => _error = serviceError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.register ? 'Register' : 'Login';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Content(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Brand(),
                const SizedBox(height: 30),
                Text(
                  widget.register
                      ? 'Make room for\nsomething delicious.'
                      : 'Good to have\nyou back.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.register
                      ? 'Create your own private recipe collection.'
                      : 'Your favorite recipes are right where you left them.',
                  style: const TextStyle(color: Palette.secondary),
                ),
                const SizedBox(height: 28),
                Panel(
                  child: Form(
                    key: _form,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabeledInput(
                          label: 'Email',
                          child: TextFormField(
                            controller: _email,
                            enabled: !_busy,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                            ),
                          ),
                        ),
                        LabeledInput(
                          label: 'Password',
                          child: TextFormField(
                            controller: _password,
                            enabled: !_busy,
                            obscureText: _hidePassword,
                            validator: (v) => Validators.password(
                              v,
                              register: widget.register,
                            ),
                            onChanged: (_) {
                              if (_submitted && widget.register) {
                                _form.currentState?.validate();
                              }
                            },
                            textInputAction: widget.register
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!widget.register) _submit();
                            },
                            decoration: InputDecoration(
                              hintText: widget.register
                                  ? 'At least 6 characters'
                                  : 'Enter your password',
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.register)
                          LabeledInput(
                            label: 'Confirm password',
                            child: TextFormField(
                              controller: _confirm,
                              enabled: !_busy,
                              obscureText: _hideConfirm,
                              validator: (v) =>
                                  Validators.confirm(v, _password.text),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: 'Re-enter your password',
                                suffixIcon: IconButton(
                                  tooltip: _hideConfirm
                                      ? 'Show confirm password'
                                      : 'Hide confirm password',
                                  onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm,
                                  ),
                                  icon: Icon(
                                    _hideConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        SubmitButton(
                          label: title,
                          busy: _busy,
                          onPressed: _submit,
                        ),
                        if (_error != null) StatusBanner(_error!, error: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => AuthScreen(
                                register: !widget.register,
                                onSubmit: widget.onSubmit,
                              ),
                            ),
                          ),
                    child: Text(
                      widget.register
                          ? 'Already have an account? Login'
                          : 'New to RecipeBox? Register',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
