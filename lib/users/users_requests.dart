import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/color_screen.dart';
import '../utils/size_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAllRequests() async {
    try {
      // Получение всех пользователей
      QuerySnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> allRequests = [];

      for (var userDoc in userSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final userEmail = userData?['email'] ?? 'No Email';

        // Получение всех запросов для конкретного пользователя
        QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('requests')
            .get();

        // Добавление всех запросов в общий список
        allRequests.addAll(
          requestSnapshot.docs.map((doc) {
            final requestData = doc.data() as Map<String, dynamic>?;
            return {
              'userId': userDoc.id,
              'userEmail': userEmail,
              'requestId': doc.id,
              ...?requestData,
            };
          }).toList(),
        );
      }

      return allRequests;
    } catch (e) {
      print('Error fetching requests: $e');
      return [];
    }
  }

  Future<void> deleteRequest(String userId, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('requests')
          .doc(requestId)
          .delete();
      print('Request $requestId deleted successfully for user $userId');
    } catch (e) {
      print('Error deleting request: $e');
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
                  'История заявок',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
                Text(
                  'Редактирование заявки',
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAllRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No requests found'));
                } else {
                  final allRequests = snapshot.data!;
                  return ListView.builder(
                    itemCount: allRequests.length,
                    itemBuilder: (context, index) {
                      final request = allRequests[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                        padding: EdgeInsets.all(10),
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
                        child: ListTile(
                          title: Text(
                            request['service'] ?? 'No Service',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${request['userEmail']}'),
                              Text('ID: ${request['requestId']}'),
                              Text('Date: ${request['date'] ?? 'No Date'}'),
                              Text('Time: ${request['time'] ?? 'No Time'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                        'Are you sure you want to delete this request?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm) {
                                await deleteRequest(
                                    request['userId'], request['requestId']);
                                // Перезагрузка данных
                                (context as Element).reassemble();
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
