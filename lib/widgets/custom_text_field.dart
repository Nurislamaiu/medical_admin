import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/color_screen.dart';
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType type;
  final String? Function(String?)? validator; // Новый параметр для валидации
  final List<TextInputFormatter>? inputFormatters; // Новый параметр для маски ввода

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.type = TextInputType.text,
    this.inputFormatters, // Принимаем список масок ввода
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText; // Инициализируем скрытие для пароля
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.type,
      controller: widget.controller,
      obscureText: _isObscured,
      validator: widget.validator, // Подключаем функцию проверки
      inputFormatters: widget.inputFormatters, // Применяем маски ввода
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: ScreenColor.color6),
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: ScreenColor.color2,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ScreenColor.color2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ScreenColor.color2, width: 2),
        ),
      ),
    );
  }
}
