import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("My Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching orders'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderData = order.data() as Map<String, dynamic>;

              // Debug: Print the order data to check values in Firestore
              print("Order Data: $orderData");

              var items = orderData['items'] as List<dynamic>;

              // Fix: Ensure `totalPrice` is properly converted
              double totalPrice = 0.0;
              if (orderData.containsKey('totalPrice')) {
                try {
                  totalPrice = (orderData['totalPrice'] as num).toDouble();
                } catch (e) {
                  print("Error parsing totalPrice: $e");
                }
              }

              String formattedDate = orderData['timestamp'] != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(orderData['timestamp'].toDate())
                  : "Unknown Date";

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header: ID & Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${order.id.substring(0, 6)}...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Divider(),

                      // Order Items
                      Column(
                        children: items.map((item) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              item['name'] ?? 'Unknown Product',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Qty: ${item['quantity'] ?? 1}"),
                          );
                        }).toList(),
                      ),

                      Divider(),

                      // Address Section
                      Text(
                        "Address: ${orderData['address'] ?? 'N/A'}, ${orderData['city'] ?? ''}",
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Postal Code: ${orderData['postalCode'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 10),

                      // Total Price Display
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total: RS ${totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
