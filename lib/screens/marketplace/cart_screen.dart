import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_guide/screens/marketplace/order_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void goToOrderScreen() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    var cartItemsSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId) // Fetch only logged-in user's cart
        .get();

    if (cartItemsSnapshot.docs.isEmpty) {
      Get.snackbar('Cart is Empty', 'Please add items before placing an order');
      return;
    }

    List<Map<String, dynamic>> cartItems = cartItemsSnapshot.docs.map((doc) {
      return {
        'productId': doc['productId'],
        'name': doc['name'],
        'image': doc['image'],
        'quantity': doc['quantity'],
        'price': doc['price'],
      };
    }).toList();

    Get.to(() => OrderScreen(cartItems: cartItems));
  }

  void deleteCartItem(String docId) {
    FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: userId) // Filter by userId
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Cart is empty'));
          }

          var cartItems = snapshot.data!.docs
              .where((doc) => doc['userId'] == userId)
              .toList();
          double totalPrice = cartItems.fold(0, (sum, item) {
            return sum + (item['price'] * item['quantity']);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index];
                    return ListTile(
                      leading: Image.network(cartItem['image'],
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(cartItem['name']),
                      subtitle: Text('Qty: ${cartItem['quantity']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              'RS: ${(cartItem['price'] * cartItem['quantity']).toStringAsFixed(2)}'),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCartItem(cartItem.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total: RS ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: goToOrderScreen, // Navigate to OrderScreen
          child: Text('Proceed to Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
