import 'package:flutter/material.dart';
import 'package:green_guide/app_drawer.dart'; // Assuming this exists in your project
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class PlantCare extends StatefulWidget {
  const PlantCare({Key? key}) : super(key: key);

  @override
  State<PlantCare> createState() => _PlantCareState();
}

class _PlantCareState extends State<PlantCare> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _conditionsController = TextEditingController();

  List<String> _careGuidancePoints = [];
  bool _isLoading = false;

  // Your Gemini API key (replace with your actual key)
  static const String _apiKey = 'AIzaSyCKuF_u5XVmUVjugMq7rK82LK2V6o7FkTI';

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Verify with Gemini API docs
      apiKey: _apiKey,
    );
  }

  // Parse response into a list of bullet points
  List<String> _parseResponse(String response) {
    return response
        .split('\n')
        .map((line) => line.trim())
        .where((line) =>
            line.startsWith('-') || line.startsWith('•') || line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'[-•]\s*'), '').trim())
        .toList();
  }

  Future<void> _getCareGuidance() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _careGuidancePoints = [];
      });

      try {
        final prompt = '''
          Provide care guidance for the following plant based on the given details:

          Plant Name: ${_plantNameController.text}
          Location: ${_locationController.text}
          Current Conditions: ${_conditionsController.text}

          Return a concise care guide as a bulleted list with 5-7 points.
          Include the plant name in the first point, followed by tips on watering, sunlight, and location-specific advice.
          Use simple, practical language and start each point with a "-".
          Example format:
          - [Plant Name]: Thrives in bright conditions.
          - Watering: Water weekly.
          - Sunlight: Needs full sun.
        ''';

        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);

        setState(() {
          String rawResponse = response.text ?? 'No guidance generated';
          _careGuidancePoints = _parseResponse(rawResponse);
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error generating care guidance: $e');
        setState(() {
          _isLoading = false;
          _careGuidancePoints = [
            'Error: Failed to get care guidance. Details: $e'
          ];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get care guidance: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _locationController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  // Define the background decoration to reuse
  final _backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.green.shade100,
        Colors.green.shade300,
        Colors.green.shade600,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    image: const DecorationImage(
      image: AssetImage("assets/images_background2.jpg"),
      fit: BoxFit.cover,
      opacity: 0.2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: _backgroundDecoration, // Apply background to body
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌱 Welcome to Plant Care!',
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
                    'Enter plant details to get expert care guidance.',
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _plantNameController,
                        decoration: InputDecoration(
                          hintText: 'Plant Name (e.g., Monstera)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          suffixIcon: Icon(Icons.local_florist,
                              color: Colors.green.shade700),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a plant name' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Location (e.g., Multan, Lahore)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          suffixIcon: Icon(Icons.location_on,
                              color: Colors.green.shade700),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your location'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _conditionsController,
                        decoration: InputDecoration(
                          hintText: 'Conditions (e.g., indoors, humid)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          suffixIcon: Icon(Icons.wb_sunny,
                              color: Colors.green.shade700),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter current conditions'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _getCareGuidance,
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
                              'Get Care Guidance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    // decoration:
                    //     _backgroundDecoration, // Always apply the same background
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _careGuidancePoints.isEmpty
                          ? [
                              SizedBox(
                                height: 330,
                              )
                            ]
                          : _careGuidancePoints
                              .map((point) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
