import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Future<void> Function()? onPressed; // allow async
  final Color? color;
  final Color? textColor;
  final bool showSnackBar;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color,
    this.textColor,
    this.showSnackBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed == null
            ? null
            : () async {
                if (showSnackBar) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$title clicked")),
                  );
                }
                await onPressed!(); // call async function
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
