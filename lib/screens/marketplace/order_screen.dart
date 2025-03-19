import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:green_guide/screens/home_screen.dart';

class OrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  OrderScreen({super.key, required this.cartItems});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPlacingOrder = false; // Track order placement state

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();

  void placeOrder() async {
    if (_formKey.currentState!.validate()) {
      if (widget.cartItems.isEmpty) {
        Get.snackbar('Error', 'Cart is empty!');
        return;
      }

      setState(() {
        _isPlacingOrder = true; // Show progress indicator
      });

      try {
        // Calculate total price
        double totalPrice = widget.cartItems.fold(0, (sum, item) {
          return sum + (item['price'] * item['quantity']);
        });

        // Get current user ID
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Create order data
        Map<String, dynamic> orderData = {
          'userId': userId,
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'city': cityController.text,
          'postalCode': postalCodeController.text,
          'items': widget.cartItems,
          'totalPrice': totalPrice,
          'timestamp': Timestamp.now(),
        };

        // Store order in Firestore
        await FirebaseFirestore.instance.collection('orders').add(orderData);

        // Clear the cart after order is placed
        QuerySnapshot cartSnapshot =
            await FirebaseFirestore.instance.collection('cart').get();
        for (var doc in cartSnapshot.docs) {
          await doc.reference.delete();
        }

        // Clear the cart locally
        setState(() {
          widget.cartItems.clear();
          _isPlacingOrder = false; // Hide progress indicator
        });

        Get.snackbar('Success', 'Order Placed Successfully!');
        Get.off(HomeScreen()); // Navigate to home screen
      } catch (e) {
        setState(() {
          _isPlacingOrder = false; // Hide progress indicator
        });
        Get.snackbar('Error', 'Failed to place order. Try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });

    return Scaffold(
      appBar: AppBar(title: Text("Place Order")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 10),

              // Phone Number
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your phone number' : null,
              ),
              SizedBox(height: 10),

              // Address
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your address' : null,
              ),
              SizedBox(height: 10),

              // City
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Enter your city' : null,
              ),
              SizedBox(height: 10),

              // Postal Code
              TextFormField(
                controller: postalCodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Postal Code'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter postal code' : null,
              ),
              SizedBox(height: 20),

              // Cart Items Preview
              Text("Ordered Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              widget.cartItems.isEmpty
                  ? Text("No items in cart")
                  : Column(
                      children: widget.cartItems.map((item) {
                        return ListTile(
                          leading: Image.network(item['image'],
                              width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(item['name']),
                          subtitle: Text("Qty: ${item['quantity']}"),
                          trailing: Text(
                              "RS: ${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 20),

              // Total Price
              Text("Total: RS ${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              SizedBox(height: 20),

              // Place Order Button with Progress Indicator
              Center(
                child: ElevatedButton(
                  onPressed: _isPlacingOrder
                      ? null
                      : placeOrder, // Disable button if loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: _isPlacingOrder
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Place Order", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
