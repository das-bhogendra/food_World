import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,

  
    fontFamily: 'OpenSans regular',

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'OpenSans Bold',
          color: Colors.white,
        ),
      ),
    ),
  );
}