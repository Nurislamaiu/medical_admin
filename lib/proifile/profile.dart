import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _cachedAdminData;

  @override
  void initState() {
    super.initState();
    _getAdminData();
  }

  Future<void> _getAdminData() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser!;
      print("Fetching admin data for UID: ${_currentUser?.uid}");

      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('admin').get();

      for (var doc in snapshot.docs) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
      }

      // Specific document query
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(_currentUser?.uid)
          .get();

      if (doc.exists) {
        _cachedAdminData = doc.data() as Map<String, dynamic>?;
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Admin data not found.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          _buildInfoCard(
                              icon: Iconsax.user_tag,
                              title: "Роль",
                              value:
                                  _cachedAdminData?['role'] ?? "Not Available"),
                          _buildInfoCard(
                              icon: Iconsax.location,
                              title: "Локация",
                              value: _cachedAdminData?['location'] ??
                                  "Not Available"),
                          _buildInfoCard(
                              icon: Iconsax.calendar_1,
                              title: "Дата регистрации",
                              value: _cachedAdminData?['registrationDate'] ??
                                  "Not Available"),
                          _buildInfoCard(
                              icon: Iconsax.call,
                              title: "Контакт",
                              value: _cachedAdminData?['phone'] ??
                                  "Not Available"),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _cachedAdminData?['photoUrl'] != null
                    ? NetworkImage(_cachedAdminData!['photoUrl'])
                    : null,
                child: _cachedAdminData?['photoUrl'] == null
                    ? const Icon(Icons.person,
                        size: 50, color: ScreenColor.color6)
                    : null,
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error logging out: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _cachedAdminData?['name'] ?? "Unknown Admin",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                _cachedAdminData?['email'] ?? "Unknown Email",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [ScreenColor.background, Colors.white70],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: ScreenColor.color6),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      ),
    );
  }
}
