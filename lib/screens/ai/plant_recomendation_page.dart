import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class PlantRecommendationScreen extends StatefulWidget {
  const PlantRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<PlantRecommendationScreen> createState() =>
      _PlantRecommendationScreenState();
}

class _PlantRecommendationScreenState extends State<PlantRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _sunlightController = TextEditingController();
  final _experienceController = TextEditingController();
  final _interestsController = TextEditingController();

  String _recommendations = '';
  bool _isLoading = false;

  // Your Gemini API key
  static const String _apiKey = 'AIzaSyCKuF_u5XVmUVjugMq7rK82LK2V6o7FkTI';

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model:
          'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  // Function to clean markdown from the response
  String _cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\*\*|\*|_'), '').trim();
  }

  Future<void> _getRecommendations() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _recommendations = '';
      });

      try {
        final prompt = '''
          I am looking for plant recommendations based on the following information:

          Location: ${_locationController.text}
          Sunlight: ${_sunlightController.text}
          Gardening Experience: ${_experienceController.text}
          Plant Interests: ${_interestsController.text}

          Considering these factors, suggest 3-5 plants suitable for my needs. 
          Give name and short growing recommendation only. Just one or two sentences only!
          Provide only short explanation.
        ''';

        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);

        setState(() {
          // Clean the response to remove markdown (** or *)
          _recommendations =
              _cleanResponse(response.text ?? 'No recommendations generated');
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error generating plant recommendations: $e');
        setState(() {
          _isLoading = false;
          _recommendations =
              'Error: Failed to get recommendations. Details: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get recommendations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _sunlightController.dispose();
    _experienceController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Recommendations"), // Fixed typo in title
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    suffixIcon:
                        Icon(Icons.location_on, color: Colors.green.shade700),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter location' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _sunlightController,
                  decoration: InputDecoration(
                    labelText: 'Sunlight (e.g., full sun, partial shade)',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    suffixIcon:
                        Icon(Icons.wb_sunny, color: Colors.green.shade700),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter sunlight conditions'
                      : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(
                    labelText: 'Gardening Experience (e.g., beginner, expert)',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    suffixIcon:
                        Icon(Icons.handyman, color: Colors.green.shade700),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter experience level' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _interestsController,
                  decoration: InputDecoration(
                    labelText: 'Plant Interests (e.g., flowers, herbs)',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    suffixIcon:
                        Icon(Icons.local_florist, color: Colors.green.shade700),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your interests' : null,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getRecommendations,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.greenAccent,
                      disabledBackgroundColor:
                          Colors.greenAccent.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Get Recommendations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_recommendations.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _recommendations,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
