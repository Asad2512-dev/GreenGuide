import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).get();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(child: Text("No user data found"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['imageUrl'] != null
                      ? NetworkImage(userData['imageUrl'])
                      : AssetImage("assets/default_avatar.png") as ImageProvider,
                ),
                SizedBox(height: 20),
                Text(userData['name'] ?? "Unknown", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(userData['email'] ?? "No email", style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Username: ${userData['username'] ?? 'N/A'}"),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Phone: ${userData['phoneNumber'] ?? 'N/A'}"),
                ),
                ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text("Role: ${userData['role'] ?? 'N/A'}"),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Get.offAllNamed("/login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}