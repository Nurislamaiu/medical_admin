import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicall_admin/nav_bar.dart';
import 'package:medicall_admin/utils/color_screen.dart';
import 'package:medicall_admin/utils/size_screen.dart';
import 'package:medicall_admin/widgets/custom_button.dart';
import 'package:medicall_admin/widgets/custom_text_field.dart';

import 'home/admin_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Авторизация
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Переход на экран администратора
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavBarScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Ошибка", e.message ?? "Не удалось войти");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: ScreenSize(context).width * 0.4,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Добро пожаловать, Администратор!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ScreenColor.color6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(controller: _emailController, label: "Email", icon: Icons.email),
                  SizedBox(height: 20),
                  CustomTextField(controller: _passwordController, label: "Пароль", icon: Icons.lock),
                  SizedBox(height: 30),
                  CustomButton(text: "Войти", onPressed: _login),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
