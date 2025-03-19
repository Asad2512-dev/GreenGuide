import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_guide/app_drawer.dart';
import 'package:http/http.dart' as http;

class PlantDiseaseDiagnosisScreen extends StatefulWidget {
  const PlantDiseaseDiagnosisScreen({super.key});

  @override
  _PlantDiseaseDiagnosisScreenState createState() =>
      _PlantDiseaseDiagnosisScreenState();
}

class _PlantDiseaseDiagnosisScreenState
    extends State<PlantDiseaseDiagnosisScreen> {
  final TextEditingController _controller = TextEditingController();
  String _diagnosisResult = '';
  bool _isLoading = false;

  String _cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\*\*|__|\*|_'), '').trim();
  }

  Future<void> _fetchDiseaseDiagnosis(String symptoms) async {
    if (symptoms.isEmpty) {
      setState(() {
        _diagnosisResult = 'Please describe the symptoms.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _diagnosisResult = '';
    });

    final url =
        'https://royalblue-stingray-936294.hostingersite.com/index.php/api/garden/plant_disease?prompt=$symptoms';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'];

        if (candidates != null && candidates.isNotEmpty) {
          setState(() {
            _diagnosisResult =
                _cleanResponse(candidates[0]['content']['parts'][0]['text']);
          });
        } else {
          setState(() {
            _diagnosisResult = 'No diagnosis found for these symptoms.';
          });
        }
      } else {
        setState(() {
          _diagnosisResult = 'Failed to fetch diagnosis. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _diagnosisResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100,
              Colors.green.shade300,
              Colors.green.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage("assets/images_background2.jpg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌿 Plant Disease Diagnosis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black38,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Describe the symptoms of your plant’s disease.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type symptoms here...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _fetchDiseaseDiagnosis(_controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    backgroundColor: Colors.greenAccent,
                    disabledBackgroundColor:
                        Colors.greenAccent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Diagnose Disease',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_diagnosisResult.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _diagnosisResult,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
