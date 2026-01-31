import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/hive/hive_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

import '../providers/auth_provider.dart';
import '../state/auth_state.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  final HiveService hiveService;

  const SignupPage({
    super.key,
    required this.hiveService,
  });

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= HANDLE REGISTER =================
  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      SnackbarUtils.showError(
          context, "All required fields must be filled");
      return;
    }

    if (password != confirmPassword) {
      SnackbarUtils.showError(context, "Passwords do not match");
      return;
    }

    await ref.read(authViewModelProvider.notifier).register(
          fullName: fullName,
          email: email,
          username: username,
          password: password,
          confirmPassword: confirmPassword,
          role: "user",
          phoneNumber: phone.isEmpty ? null : phone,
          batchId: null,
        );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          hiveService: widget.hiveService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    /// Listen for success / error
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
            context, "Registration successful");
        _navigateToLogin();
      }

      if (next.status == AuthStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 31, 31),
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign up to start using FoodWorld",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),

            /// Full Name
            CustomTextField(
              controller: _fullNameController,
              label: "Full Name",
              hint: "Enter full name",
            ),
            const SizedBox(height: 15),

            /// Email
            CustomTextField(
              controller: _emailController,
              label: "Email",
              hint: "Enter email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            /// Username
            CustomTextField(
              controller: _usernameController,
              label: "Username",
              hint: "Choose username",
            ),
            const SizedBox(height: 15),

            /// Phone (Optional)
            CustomTextField(
              controller: _phoneController,
              label: "Phone Number (Optional)",
              hint: "98XXXXXXXX",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            /// Password
            CustomTextField(
              controller: _passwordController,
              label: "Password",
              hint: "Enter password",
              obscureText: true,
            ),
            const SizedBox(height: 15),

            /// Confirm Password
            CustomTextField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              hint: "Confirm password",
              obscureText: true,
            ),
            const SizedBox(height: 30),

            /// Register Button
            CustomButton(
              title: authState.status == AuthStatus.loading
                  ? "Creating..."
                  : "Create Account",
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : _handleRegister,
              color: const Color.fromARGB(255, 42, 15, 15),
              textColor: Colors.white,
            ),
            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  "Already have an account? Login",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
