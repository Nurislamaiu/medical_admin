import 'package:flutter/material.dart';

import '../utils/color_screen.dart';
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ScreenColor.color6,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ScreenColor.white),
        ),
      ),
    );
  }
}
