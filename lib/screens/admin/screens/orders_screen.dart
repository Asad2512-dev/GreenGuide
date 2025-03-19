
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_guide/services/firebase_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late FirebaseService _firebaseService;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _loadOrders();
  }

  // Load orders from Firestore
  Future<void> _loadOrders() async {
    try {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
      setState(() {
        _orders = ordersSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error loading orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Orders')),
      body: _orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                var order = _orders[index];
                return ListTile(
                  title: Text('Order ID: ${order['userId']}'),
                  subtitle: Text('Total Price: \$${order['totalPrice']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.view_list),
                    onPressed: () => _showOrderDetails(order),
                  ),
                );
              },
            ),
    );
  }

  // Show order details in a dialog or new screen
  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${order['name']}'),
              Text('Phone: ${order['phone']}'),
              Text('Address: ${order['address']}'),
              Text('City: ${order['city']}'),
              Text('Postal Code: ${order['postalCode']}'),
              SizedBox(height: 10),
              Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._buildOrderItemsList(order['items']),
              Text('Total Price: \$${order['totalPrice']}'),
              Text('Timestamp: ${order['timestamp'].toDate()}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build the list of order items
  List<Widget> _buildOrderItemsList(List items) {
    return items.map<Widget>((item) {
      return ListTile(
        title: Text(item['name']),
        subtitle: Text('Quantity: ${item['quantity']}'),
        leading: Image.network(item['image'], width: 50, height: 50),
        trailing: Text('\$${item['price']}'),
      );
    }).toList();
  }
}
