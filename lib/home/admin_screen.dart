import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medicall_admin/admin_login.dart';
import 'package:medicall_admin/utils/color_screen.dart';
import 'package:medicall_admin/utils/size_screen.dart';

class AdminApprovalScreen extends StatefulWidget {
  @override
  _AdminApprovalScreenState createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Обновление статуса пользователя
  void _updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('nurse').doc(userId).update({'status': status});
      Get.snackbar("Успех", "Статус пользователя обновлен на '$status'");
    } catch (e) {
      Get.snackbar("Ошибка", "Не удалось обновить статус");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Админ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
                Text(
                  'Проверка документов',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('nurse')
                  .where('status', isEqualTo: 'pending')
                  .where('registeredFromApp', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset("assets/lottie/loading.json", height: ScreenSize(context).height * 0.1),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lottie/check.json", height: ScreenSize(context).height * 0.3),
                        SizedBox(height: 10),
                        Text("Нет пользователей для проверки"),
                      ],
                    ),
                  );
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = user.id;
                    final certificateNumber = user['certificateNumber'];
                    final name = user['name'];
                    final city = user['city'];
                    final experience = user['experience'];
                    final iin = user['iin'];
                    final phone = user['phone'];
                    final email = user['email'];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            ScreenColor.background,
                            Colors.white70
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Имя: $name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Почта: $email",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text("Номер Сертификата: $certificateNumber", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5),
                                  Text("ИИН: $iin", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5),
                                  Text("Адрес: $city", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5),
                                  Text("Опыт: $experience", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5),
                                  Text("Телефон: $phone", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  SizedBox(height: 5),
                                  Text("ID: $userId", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Divider(thickness: 1, color: Colors.grey[300]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  label: Text("Approve", style: TextStyle(color: Colors.green)),
                                  onPressed: () {
                                    _updateUserStatus(userId, 'approved');
                                  },
                                ),
                                SizedBox(width: 10),
                                TextButton.icon(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  label: Text("Reject", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    _updateUserStatus(userId, 'rejected');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      )
    );
  }
}
