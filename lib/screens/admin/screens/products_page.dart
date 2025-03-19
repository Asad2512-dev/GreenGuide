import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_guide/services/firebase_service.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late FirebaseService _firebaseService;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _loadProducts();
  }

  // Load products from Firestore
  Future<void> _loadProducts() async {
    try {
      QuerySnapshot productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        _products = productsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error loading products: $e");
    }
  }

  // Delete product
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      _loadProducts(); // Refresh product list after deletion
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  // Show edit dialog
  void _showEditDialog(Map<String, dynamic> product) {
    TextEditingController nameController = TextEditingController(text: product['name']);
    TextEditingController priceController = TextEditingController(text: product['price'].toString());
    TextEditingController descriptionController = TextEditingController(text: product['description']);
    TextEditingController imageController = TextEditingController(text: product['image']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = nameController.text;
              double price = double.tryParse(priceController.text) ?? 0.0;
              String description = descriptionController.text;
              String image = imageController.text;

              if (name.isNotEmpty && price > 0.0) {
                await FirebaseFirestore.instance.collection('products').doc(product['id']).update({
                  'name': name,
                  'price': price,
                  'description': description,
                  'image': image,
                });
                _loadProducts(); // Refresh product list after update
                Navigator.pop(context);
              }
            },
            child: Text('Save Changes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Products')),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text('Price: \$${product['price']}'),
                  leading: Image.network(product['image'], width: 50, height: 50),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
