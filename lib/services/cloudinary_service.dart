import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  static Future<String?> uploadImage(File imageFile) async {
    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      return responseData['secure_url']; // Returns uploaded image URL
    }
    return null;
  }

  static Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
