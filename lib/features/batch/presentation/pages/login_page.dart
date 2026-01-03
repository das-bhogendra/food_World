import 'package:flutter/material.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/utils/snackbar_utils.dart';
import 'package:food_mandu/screen/buttom_screen.dart';
import 'package:food_mandu/screen/register_screen.dart';
import 'package:food_mandu/widgets/custom_button.dart';
import 'package:food_mandu/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  final HiveService hiveService; // ✅ Use the same HiveService instance
  const LoginPage({super.key, required this.hiveService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// ================= HANDLE LOGIN =================
  Future<void> _handleLogin() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackbarUtils.showError(context, "Email and password are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Use the injected HiveService instance
      final user = await widget.hiveService.loginUser(email, password);

      if (user != null) {
        print("✅ Login Success:");
        print("Current User ID: ${widget.hiveService.currentUserId}");
        print("Email: ${user.email}");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomScreenLayout()),
        );
      } else {
        SnackbarUtils.showError(context, "Invalid email or password");
      }
    } catch (e) {
      SnackbarUtils.showError(context, "Login failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ================= NAVIGATE TO REGISTER =================
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              RegisterScreen(hiveService: widget.hiveService)), // pass same instance
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(145, 61, 61, 1),
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Welcome login page",
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

              CustomTextField(
                controller: _email,
                label: "Email",
                hint: "Enter your email",
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: _password,
                label: "Password",
                hint: "Enter your password",
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // ================= LOGIN BUTTON =================
              CustomButton(
                title: _isLoading ? "Logging in..." : "Login",
                onPressed: _isLoading ? null : _handleLogin,
                color: const Color.fromRGBO(143, 59, 59, 1),
                textColor: Colors.white,
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
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
      ),
    );
  }
}
