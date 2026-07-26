import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/global_snackbar.dart';
import '../data/app_exception.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      GlobalSnackbar.show(context, 'Passwords do not match');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authProvider.notifier).register(
            username: _usernameController.text.trim(),
            userEmail: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      GlobalSnackbar.show(context, 'Registered successfully. Please sign in.',
          success: true);
      Navigator.pop(context);
    } on AppException catch (error) {
      if (!mounted) return;
      GlobalSnackbar.show(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, size: 20, color: AppTheme.textPrimary(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Create account',
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create your account',
                        style: AppTextStyles.display(color: AppTheme.textPrimary(context)),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _usernameController,
                        label: 'Username',
                        prefixIcon: LucideIcons.user,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.required(value, field: 'Username'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: LucideIcons.mail,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        showVisibilityToggle: true,
                        prefixIcon: LucideIcons.lock,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.minLength(value, 5, field: 'Password'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        obscureText: true,
                        showVisibilityToggle: true,
                        prefixIcon: LucideIcons.lock,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            Validators.required(value, field: 'Confirm password'),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentStrong(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _register,
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.onAccentStrong(context)),
                              )
                            : Text('Register',
                                style: AppTextStyles.bodyBold(color: AppTheme.onAccentStrong(context))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
