import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../utils/color_screen.dart';
import '../utils/size_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool isUsers = true;

  Future<void> deleteUser(String collection, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userId)
          .delete();
      print('$collection $userId deleted successfully');
    } catch (e) {
      print('Error deleting $collection $userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Верхний блок дизайна
          Container(
            width: double.infinity,
            height: ScreenSize(context).height * 0.30,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ScreenColor.color6,
                  ScreenColor.color6.withOpacity(0.2)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: ScreenColor.color6.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Пользователи',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
                const Text(
                  'Редактирование пользователей',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Переключатель между вкладками
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: ScreenColor.color6,
                  labelColor: ScreenColor.color6,
                  unselectedLabelColor: ScreenColor.color2,
                  splashFactory: NoSplash.splashFactory,
                  isScrollable: false,
                  tabs: const [
                    Tab(text: 'Пользователи'),
                    Tab(text: 'Медсестры'),
                  ],
                  onTap: (index) {
                    setState(() {
                      isUsers = index == 0;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Список данных
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(isUsers ? 'users' : 'nurse')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset("assets/lottie/loading.json"),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Нет данных'),
                  );
                } else {
                  final data = snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    };
                  }).toList();

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [ScreenColor.background, Colors.white70],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${item['name'] ?? 'No Name'}'),
                              Text('Email: ${item['email'] ?? 'No Email'}'),
                              Text('Phone: ${item['phone'] ?? 'No Phone'}'),
                              Text('ID: ${item['id'] ?? 'No ID'}', style: TextStyle(fontSize: 10),),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Iconsax.trash, color: ScreenColor.color6),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('Подтвердите удаление'),
                                    content: const Text(
                                        'Вы уверены, что хотите удалить этот элемент?'),

                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Отмена'),
                                        style: TextButton.styleFrom(
                                          backgroundColor: ScreenColor.color6,
                                          foregroundColor: Colors.white
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                          Get.snackbar('Успешно','Пользователь успешно удален');
                                        },
                                        child: const Text('Удалить'),
                                        style: TextButton.styleFrom(
                                            backgroundColor: ScreenColor.color6,
                                            foregroundColor: Colors.white
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm) {
                                await deleteUser(
                                    isUsers ? 'users' : 'nurse', item['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
