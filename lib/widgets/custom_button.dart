import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? color;       // optional button color
  final Color? textColor;   // optional text color
  final bool showSnackBar;  // optional: show SnackBar when clicked

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color,
    this.textColor,
    this.showSnackBar = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50, // fixed height for better UI
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (showSnackBar) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title clicked")),
            );
          }
          onPressed();
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
