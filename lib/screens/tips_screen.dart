// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TipsScreen extends StatelessWidget {
//   const TipsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tips'),
//         backgroundColor: Colors.green,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('tips').snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error loading tips'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No tips available'));
//           }

//           var tips = snapshot.data!.docs;

//           return ListView.builder(
//             padding: EdgeInsets.all(16.0),
//             itemCount: tips.length,
//             itemBuilder: (context, index) {
//               var tip = tips[index];
//               var tipData = tip.data() as Map<String, dynamic>;

//               return Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 3,
//                 margin: EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: Icon(Icons.lightbulb, color: Colors.orange),
//                   title: Text(
//                     tipData['title'] ?? 'No Title',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(tipData['description'] ?? 'No Description'),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tip Detail Screen
class TipDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const TipDetailScreen(
      {required this.title, required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tips').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tips'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tips available'));
          }

          var tips = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              var tip = tips[index];
              var tipData = tip.data() as Map<String, dynamic>;
              String title = tipData['title'] ?? 'No Title';
              String description = tipData['description'] ?? 'No Description';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.orange),
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipDetailScreen(
                          title: title,
                          description: description,
                        ),
                      ),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
