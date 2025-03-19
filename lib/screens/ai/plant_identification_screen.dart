import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlantIdentificationScreen extends StatefulWidget {
  const PlantIdentificationScreen({super.key});

  @override
  _PlantIdentificationScreenState createState() =>
      _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  String _cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\*\*|__|\*|_'), '').trim();
  }

  Future<void> _identifyPlant() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      setState(() => _result = 'Please enter a plant description.');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final url =
        'https://royalblue-stingray-936294.hostingersite.com/api/garden/plant_id/?prompt=$prompt';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'];
        setState(() {
          _result = candidates != null && candidates.isNotEmpty
              ? _cleanResponse(candidates[0]['content']['parts'][0]['text'] ??
                  'No additional information available.')
              : 'No results found. Try again with more details.';
        });
      } else {
        setState(() =>
            _result = 'Failed to identify plant. Please try again later.');
      }
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter Plant Description',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                  suffixIcon: Icon(Icons.search, color: Colors.green.shade700),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _identifyPlant,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.all(14), // Slightly reduced padding
                    shape: StadiumBorder(), // Simplifies rounded corners
                    backgroundColor:
                        Colors.greenAccent, // A more standard color
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
                          'Identify Plant',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _result,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
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
