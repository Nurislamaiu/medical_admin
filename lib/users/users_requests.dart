import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../utils/color_screen.dart';
import '../utils/size_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  Stream<List<Map<String, dynamic>>> fetchRequestsByStatusStream(String status) {
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap((userSnapshot) async {
      List<Map<String, dynamic>> requests = [];

      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.data()?['email'] ?? 'No Email';
        final userName = userDoc.data()?['name'] ?? 'No Name';
        final requestSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('requests')
            .where('status', isEqualTo: status)
            .get();

        for (var doc in requestSnapshot.docs) {
          final requestData = doc.data();
          Map<String, dynamic> request = {
            'userId': userDoc.id,
            'userEmail': userEmail,
            'userName': userName,
            'requestId': doc.id,
            ...?requestData,
          };
          requests.add(request);
        }
      }

      return requests;
    });
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

  void deleteRequestWithConfirmation(
      BuildContext context, String userId, String requestId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await deleteRequest(userId, requestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                    ScreenColor.color6.withOpacity(0.2),
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
            const SizedBox(height: 20),
            const TabBar(
              indicatorColor: ScreenColor.color6,
              labelColor: ScreenColor.color6,
              unselectedLabelColor: ScreenColor.color2,
              splashFactory: NoSplash.splashFactory,
              tabs: [
                Tab(text: 'Доступные'),
                Tab(text: 'Принятые'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestsList(context, 'rejected'),
                  _buildRequestsList(context, 'accepted'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchRequestsByStatusStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Lottie.asset("assets/lottie/loading.json"));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No requests found'));
        } else {
          final requests = snapshot.data!;
          return ListView(
            children: requests.map((request) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [
                      ScreenColor.background,
                      Colors.white70,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['service'] ?? 'No Service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Имя: ${request['userName']}'),
                      Text('Почта: ${request['userEmail']}'),
                      Text('Дата: ${request['date'] ?? 'No Date'}'),
                      Text('Время: ${request['time'] ?? 'No Time'}'),
                      Text('ID: ${request['requestId']}', style: TextStyle(fontSize: 10),),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Iconsax.trash, color: ScreenColor.color6),
                    onPressed: () {
                      deleteRequestWithConfirmation(context, request['userId'], request['requestId']);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
