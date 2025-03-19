import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_guide/services/cloudinary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enhanced Signup with additional details and image upload
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String username,
    File? imageFile, // Optional profile image
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await CloudinaryService.uploadImage(imageFile);
      }

      await _db.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "name": name,
        "phoneNumber": phoneNumber,
        "username": username,
        "imageUrl": imageUrl ?? "default_image_url",
        "role": role,
        "createdAt": Timestamp.now(),
      });

      return userCredential;
    } catch (e) {
      log("Error during signup: $e");
      rethrow;
    }
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await _auth.signOut();
    log("User logged out");
  }

  // Product APIs
  Future<void> addProduct(String name, String imageUrl) async {
    await _db.collection('products').add({
      'name': name,
      'image': imageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> updatedProduct) async {
    await _db.collection("products").doc(productId).update(updatedProduct);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection("products").doc(productId).delete();
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    QuerySnapshot snapshot = await _db.collection("products").get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? 'No Name',
        'image': data['image'] ?? 'No Image',
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    DocumentSnapshot doc =
        await _db.collection("products").doc(productId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  // Order APIs
  Future<void> placeOrder(Map<String, dynamic> order) async {
    await _db.collection("orders").add(order);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    QuerySnapshot snapshot = await _db.collection("orders").get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    DocumentSnapshot doc = await _db.collection("orders").doc(orderId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  // Article APIs
  Future<void> addArticle(Map<String, dynamic> article) async {
    await _db.collection("articles").add(article);
  }

  Future<void> updateArticle(
      String articleId, Map<String, dynamic> updatedArticle) async {
    await _db.collection("articles").doc(articleId).update(updatedArticle);
  }

  Future<void> deleteArticle(String articleId) async {
    await _db.collection("articles").doc(articleId).delete();
  }

  Future<List<Map<String, dynamic>>> getAllArticles() async {
    QuerySnapshot snapshot = await _db.collection("articles").get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>?> getArticleDetails(String articleId) async {
    DocumentSnapshot doc =
        await _db.collection("articles").doc(articleId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<List<Map<String, dynamic>>> getAllTips() async {
    QuerySnapshot snapshot = await _db.collection("tips").get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'title': data['title'] ?? 'No Title',
        'content': data['content'] ?? 'No Content',
      };
    }).toList();
  }

  // Chat Functionality APIs
  static const String adminUid =
      "BFfCC32ScAZpTzNlTAS1qRuC9ZJ2"; // Your admin UID

  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "senderId": data["senderId"],
        "receiverId": data["receiverId"],
        "message": data["message"],
        "timestamp": data["timestamp"],
        "isRead": data["isRead"] ?? false,
      };
    }).toList();
  }

  Future<String?> getUserRole() async {
    if (_auth.currentUser == null) return null;
    DocumentSnapshot doc =
        await _db.collection("users").doc(_auth.currentUser!.uid).get();
    return doc.exists ? (doc.data() as Map<String, dynamic>)["role"] : null;
  }

  Future<void> sendMessageToAdmin({
    required String userId,
    required String message,
  }) async {
    try {
      await _db.collection("chats").doc(userId).collection("messages").add({
        "senderId": userId,
        "receiverId": adminUid,
        "message": message,
        "timestamp": Timestamp.now(),
        "isRead": false,
      });

      await _db.collection("chats").doc(userId).set({
        "userId": userId,
        "adminId": adminUid,
        "lastMessage": message,
        "lastMessageTime": Timestamp.now(),
        "unreadCount": FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      log("Error sending message: $e");
      rethrow;
    }
  }

  // Send message to user (admin sending to user)
  Future<void> sendMessageToUser({
    required String userId,
    required String message,
  }) async {
    if (_auth.currentUser?.uid != adminUid) {
      throw Exception("Only admin can send messages to users");
    }
    try {
      await _db.collection("chats").doc(userId).collection("messages").add({
        "senderId": adminUid,
        "receiverId": userId,
        "message": message,
        "timestamp": Timestamp.now(),
        "isRead": false,
      });

      await _db.collection("chats").doc(userId).set({
        "userId": userId,
        "adminId": adminUid,
        "lastMessage": message,
        "lastMessageTime": Timestamp.now(),
        "unreadCount": FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      log("Error sending message: $e");
      rethrow;
    }
  }

  // Get messages stream (latest at bottom)
  Stream<List<Map<String, dynamic>>> getMessagesStream(String userId) {
    return _db
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .orderBy("timestamp",
            descending: false) // Oldest first, latest at bottom
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              return {
                "id": doc.id,
                "senderId": data["senderId"],
                "receiverId": data["receiverId"],
                "message": data["message"],
                "timestamp": data["timestamp"],
                "isRead": data["isRead"] ?? false,
              };
            }).toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    QuerySnapshot unreadMessages = await _db
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .where("isRead", isEqualTo: false)
        .where("receiverId", isEqualTo: _auth.currentUser?.uid)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({"isRead": true});
    }

    await _db.collection("chats").doc(userId).update({
      "unreadCount": 0,
    });
  }

  // Get all chats stream (real-time, most recent at top)
  Stream<List<Map<String, dynamic>>> getAllChatsStream() {
    if (_auth.currentUser?.uid != adminUid) {
      throw Exception("Only admin can view all chats");
    }
    return _db
        .collection("chats")
        .orderBy("lastMessageTime", descending: true) // Most recent chats first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              return {
                "userId": data["userId"],
                "adminId": data["adminId"],
                "lastMessage": data["lastMessage"],
                "lastMessageTime": data["lastMessageTime"],
                "unreadCount": data["unreadCount"] ?? 0,
              };
            }).toList());
  }

  // Placeholder for getAllChats (if still needed elsewhere)
  Future<List<Map<String, dynamic>>> getAllChats() async {
    if (_auth.currentUser?.uid != adminUid) {
      throw Exception("Only admin can view all chats");
    }
    QuerySnapshot snapshot = await _db.collection("chats").get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        "userId": data["userId"],
        "adminId": data["adminId"],
        "lastMessage": data["lastMessage"],
        "lastMessageTime": data["lastMessageTime"],
        "unreadCount": data["unreadCount"] ?? 0,
      };
    }).toList();
  }

  // Get user details (simplified for admin use)
  Future<Map<String, dynamic>?> getUserDetails() async {
    if (_auth.currentUser == null) return null;
    DocumentSnapshot doc =
        await _db.collection("users").doc(_auth.currentUser!.uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}
