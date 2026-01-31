import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/screen/buttom_screen.dart';

import '../../../../core/services/hive/hive_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

import '../providers/auth_provider.dart';
import '../state/auth_state.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  final HiveService hiveService;

  const LoginPage({super.key, required this.hiveService});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPage(hiveService: widget.hiveService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Handle success & error safely
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.authEntity != null) {
        SnackbarUtils.showSuccess(context, "Login Successful");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomScreenLayout()),
        );
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(145, 61, 61, 1),
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
              "Welcome",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Login to continue to FoodWorld",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // Email
            CustomTextField(
              key: const Key('email_field'),
              controller: _emailController,
              label: "Email",
              hint: "Enter your email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // Password
            CustomTextField(
              key: const Key('password_field'),
              controller: _passwordController,
              label: "Password",
              hint: "Enter your password",
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Login Button
            CustomButton(
              key: const Key('login_button'),
              title: authState.status == AuthStatus.loading
                  ? "Logging in..."
                  : "Login",
              onPressed: authState.status == AuthStatus.loading ? null : _login,
              color: const Color.fromRGBO(143, 59, 59, 1),
              textColor: Colors.white,
            ),
            const SizedBox(height: 20),

            // Register link
            Center(
              child: TextButton(
                key: const Key('register_link'),
                onPressed: _navigateToRegister,
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
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
