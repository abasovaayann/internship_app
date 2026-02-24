import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final universityController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    universityController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => error = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final ok = await AuthService.register(
      name: nameController.text.trim(),
      university: universityController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: passwordController.text,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      context.go('/home');
    } else {
      setState(() => error = 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                _field(
                  label: 'Full Name',
                  controller: nameController,
                  hint: 'Your name',
                ),

                const SizedBox(height: 16),

                _field(
                  label: 'University',
                  controller: universityController,
                  hint: 'Your university',
                ),

                const SizedBox(height: 16),

                _field(
                  label: 'Email',
                  controller: emailController,
                  hint: 'name@university.edu',
                  keyboard: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                _field(
                  label: 'Password',
                  controller: passwordController,
                  hint: '••••••••',
                  obscure: obscure,
                  trailing: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGreen),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: trailing,
            ),
            validator: (v) =>
            (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
