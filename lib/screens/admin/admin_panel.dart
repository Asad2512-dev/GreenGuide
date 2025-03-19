import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_guide/screens/admin/admin_chat_screen.dart';
import 'package:green_guide/screens/admin/screens/orders_screen.dart';
import 'package:green_guide/screens/admin/screens/products_page.dart';
import 'package:green_guide/screens/articles_support.dart';
import 'package:green_guide/screens/tips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:green_guide/auth/login_screen.dart';
import 'package:green_guide/screens/admin/screens/article_page.dart';
import 'package:green_guide/screens/admin/screens/add_product.dart';
import 'package:green_guide/screens/admin/screens/tips_page.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.green.shade700,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildAdminCard("Products", Icons.shopping_bag, ProductsPage()),
            _buildAdminCard("Articles", Icons.article, ArticlesSupport()),
            _buildAdminCard("Tips", Icons.lightbulb, TipsScreen()),
            _buildAdminCard("Orders", Icons.list_alt, AdminOrdersScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Get.to(() => screen);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green.shade700),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade700),
            child: const Center(
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          _buildDrawerItem('Add Product', Icons.add, AddProduct()),
          _buildDrawerItem('Add Tips', Icons.lightbulb, TipsPage()),
          _buildDrawerItem('Add Articles', Icons.article, ArticlesPage()),
          _buildDrawerItem('View Orders', Icons.list_alt, AdminOrdersScreen()),
          _buildDrawerItem('Chat', Icons.chat_bubble, AdminChatScreen()),
          const Divider(),
          _buildDrawerItem('Logout', Icons.logout, null, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Widget? screen,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          _showLogoutDialog();
        } else if (screen != null) {
          Get.to(() => screen);
        }
      },
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Confirm Logout",
      middleText: "Are you sure you want to log out?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAll(() => LoginScreen());
      },
      onCancel: () {},
    );
  }
}
