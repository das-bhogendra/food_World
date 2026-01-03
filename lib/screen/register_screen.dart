import 'package:flutter/material.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import '../core/utils/snackbar_utils.dart';
import 'package:food_mandu/features/auth/data/models/auth_hive_model.dart';

class RegisterScreen extends StatefulWidget {
  final HiveService hiveService;
  const RegisterScreen({super.key, required this.hiveService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// ================= HANDLE REGISTER =================
  Future<void> _handleRegister() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      SnackbarUtils.showError(context, "All fields are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      final emailExists = await widget.hiveService.isEmailExists(email);
      if (emailExists) {
        SnackbarUtils.showError(context, "Email already registered");
        return;
      }

      // Create AuthHiveModel
      final newUser = AuthHiveModel(
        fullName: name,
        email: email,
        username: email.split("@")[0],
        password: password,
      );

      // Register user in Hive
      await widget.hiveService.registerUser(newUser);
      print("✅ Registered User: ${newUser.email}");

      // Navigate to LoginScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(hiveService: widget.hiveService),
        ),
      );

      SnackbarUtils.showSuccess(context, "Registration successful!");
    } catch (e) {
      SnackbarUtils.showError(context, "Registration failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 31, 31),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Register",
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
                "Create Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Sign up to start using FoodWorld",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: _name,
                label: "Full Name",
                hint: "Enter your full name",
              ),
              const SizedBox(height: 15),
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
              CustomButton(
                title: _isLoading ? "Creating..." : "Create Account",
                onPressed: _isLoading ? null : _handleRegister,
                color: const Color.fromARGB(255, 42, 15, 15),
                textColor: Colors.white,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(hiveService: widget.hiveService),
                      ),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 62, 26, 26),
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
