import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicall_admin/proifile/profile.dart';
import 'package:medicall_admin/users/users.dart';
import 'package:medicall_admin/users/users_requests.dart';
import 'package:medicall_admin/utils/color_screen.dart';
import 'home/admin_screen.dart';

class NavBarScreen extends StatefulWidget {
  @override
  _NavBarScreenState createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _currentIndex = 0; // Индекс текущей вкладки

  // Список экранов для навигации
  final List<Widget> _screens = [
    AdminApprovalScreen(),
    RequestsScreen(),
    UsersScreen(),
    AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Отображение текущего экрана
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Обновляем индекс выбранной вкладки
          });
        },
        backgroundColor: ScreenColor.white,
        selectedItemColor: ScreenColor.color6,
        unselectedItemColor: ScreenColor.color2,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.copy),
            label: 'Проверка документа',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.clock),
            label: 'История заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.command),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

