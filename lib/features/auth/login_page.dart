// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => errorText = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => loading = true);

    final ok = await AuthService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      context.go('/home');
    } else {
      setState(() => errorText = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Log in to continue your wellness journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email
                    const _Label('Email'),
                    const SizedBox(height: 8),
                    _InputShell(
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('hello@example.com'),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Email is required';
                          if (!t.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      trailing: const Icon(Icons.mail),
                    ),

                    const SizedBox(height: 20),

                    // Password
                    const _Label('Password'),
                    const SizedBox(height: 8),
                    _InputShell(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('••••••••'),
                        validator: (v) => (v == null || v.length < 4)
                            ? 'Minimum 4 characters'
                            : null,
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Login button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(
                            'Create one',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.7)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}

// ---------- UI helpers ----------

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InputShell extends StatelessWidget {
  final Widget child;
  final Widget trailing;

  const _InputShell({required this.child, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconTheme(
              data: IconThemeData(color: AppColors.textMuted),
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}
