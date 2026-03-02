import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/dashboard/buttom_screen.dart';

import '../../../../core/services/hive/hive_service.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../app/theme/app_colors.dart';
import 'register_screen.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/auth/presentation/state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final HiveService hiveService;

  const LoginScreen({super.key, required this.hiveService});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login function
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackbarUtils.showError(context, "Email and password are required");
      return;
    }

    ref.read(authViewModelProvider.notifier).login(
          username: email,
          password: password,
        );
  }

  /// Navigate to Register screen
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(hiveService: widget.hiveService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for auth state changes
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.authEntity != null) {
        SnackbarUtils.showSuccess(context, "Login Successful");

        final role = next.authEntity!.role ?? 'user';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BottomScreenLayout(userRole: role),
          ),
        );
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Login to continue to FoodWorld",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),

            // Email field
            CustomTextField(
              controller: _emailController,
              label: "Email",
              hint: "Enter your email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // Password field
            CustomTextField(
              controller: _passwordController,
              label: "Password",
              hint: "Enter your password",
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Login Button
            CustomButton(
              title: authState.status == AuthStatus.loading
                  ? "Logging in..."
                  : "Login",
              onPressed: authState.status == AuthStatus.loading ? null : _login,
              color: AppColors.primary,
              textColor: Colors.white,
            ),
            const SizedBox(height: 20),

            // Navigate to Register
            Center(
              child: TextButton(
                onPressed: _navigateToRegister,
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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