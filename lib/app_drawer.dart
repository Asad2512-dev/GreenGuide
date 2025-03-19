import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_guide/screens/ai/plant_recomendation_page.dart';
import 'package:green_guide/screens/articles_support.dart';
import 'package:green_guide/screens/chat/chat_support_page.dart';
import 'package:green_guide/screens/ai/garden_layout.dart';
import 'package:green_guide/screens/profile/user_profile.dart';
import 'package:green_guide/screens/tips_screen.dart';
import 'package:green_guide/screens/marketplace/cart_screen.dart';
import 'package:green_guide/screens/marketplace/marketplace.dart';
import 'package:green_guide/screens/marketplace/order_history_screen.dart';
import 'package:green_guide/screens/ai/plant_disease_diagnose.dart';
import 'package:green_guide/screens/home_screen.dart';
import 'package:green_guide/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade200),
            child: Text(
              'Green Guide',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            screen: UserProfileScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.search,
            title: 'Plant Identification',
            screen: const HomeScreen(),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.bug_report,
            title: 'Plant Disease Diagnosis',
            screen: const PlantDiseaseDiagnosisScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.map,
            title: 'Garden Layout Planner',
            screen: const GardenLayoutPlannerScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.recommend,
            title: 'Plant recomendations',
            screen: const PlantRecommendationScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart,
            title: 'Marketplace',
            screen: const MarketplaceScreen(),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.shopping_basket,
            title: 'Cart',
            screen: CartScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Order History',
            screen: OrderHistoryScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            title: 'Support',
            screen: ChatScreen(),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.book,
            title: 'Tips ',
            screen: const TipsScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.article,
            title: 'Articles',
            screen: const ArticlesSupport(),
          ),

          const Divider(),

          // 🔥 Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.defaultDialog(
                title: "Confirm Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  // Clear user authentication data
                  await prefs.remove('auth_token');
                  await prefs.remove('user_id');
                  await prefs.remove('user_role');

                  String? userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    // Delete all items in the cart for this user
                    QuerySnapshot cartSnapshot = await FirebaseFirestore
                        .instance
                        .collection('cart')
                        .where('userId', isEqualTo: userId)
                        .get();

                    for (var doc in cartSnapshot.docs) {
                      await doc.reference.delete();
                    }
                  }

                  Get.offAll(() => LoginScreen()); // Navigate to Login
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required Widget screen}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer before navigating
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
