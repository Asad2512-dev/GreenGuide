import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cloudinary configuration is missing!')),
      );
      return null;
    }

    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request = http.MultipartRequest("POST", Uri.parse(url))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed!')),
      );
      return null;
    }
  }

  Future<void> uploadProduct() async {
    String name = nameController.text.trim();
    String price = priceController.text.trim();

    if (name.isEmpty || price.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl = await uploadImageToCloudinary(_image!);

      if (imageUrl == null) {
        setState(() => isLoading = false);
        return;
      }

      await _db.collection("products").add({
        "name": name,
        "price": double.parse(price),
        "image": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        isLoading = false;
        _image = null;
        nameController.clear();
        priceController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading product!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: _image != null
                  ? Image.file(_image!,
                      height: 150, width: 150, fit: BoxFit.cover)
                  : Container(
                      height: 150,
                      width: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.add_a_photo, size: 50),
                    ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadProduct,
                    child: Text("Add Product"),
                  ),
          ],
        ),
      ),
    );
  }
}
