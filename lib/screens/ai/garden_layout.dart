import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GardenLayoutPlannerScreen extends StatefulWidget {
  const GardenLayoutPlannerScreen({super.key});

  @override
  _GardenLayoutPlannerScreenState createState() =>
      _GardenLayoutPlannerScreenState();
}

class _GardenLayoutPlannerScreenState extends State<GardenLayoutPlannerScreen> {
  final TextEditingController _customController = TextEditingController();
  String _gardenPlan = '';
  bool _isLoading = false;

  final List<String> _dimensionOptions = [
    '5m x 5m',
    '10m x 5m',
    '15m x 10m',
    'Custom'
  ];
  final List<String> _sunlightOptions = [
    'Full sun',
    'Partial shade',
    'Full shade'
  ];
  final List<String> _soilOptions = ['Well-drained', 'Clay', 'Sandy', 'Custom'];
  final List<String> _styleOptions = [
    'Cottage garden',
    'Modern',
    'Zen',
    'Custom'
  ];
  final List<String> _plantOptions = [
    'Roses, Lavender, Herbs',
    'Succulents, Cacti',
    'Vegetables, Fruits',
    'Custom'
  ];

  String _selectedDimension = '10m x 5m';
  String _selectedSunlight = 'Full sun';
  String _selectedSoil = 'Well-drained';
  String _selectedStyle = 'Cottage garden';
  String _selectedPlants = 'Roses, Lavender, Herbs';

  Future<void> _fetchGardenPlan() async {
    setState(() {
      _isLoading = true;
      _gardenPlan = '';
    });

    final url =
        'https://royalblue-stingray-936294.hostingersite.com/index.php/api/garden/garden_plan?prompt='
        'Dimensions: $_selectedDimension\n'
        'Sunlight: $_selectedSunlight\n'
        'Soil: $_selectedSoil\n'
        'Style: $_selectedStyle\n'
        'Plants: $_selectedPlants';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'];

        if (candidates != null && candidates.isNotEmpty) {
          setState(() {
            _gardenPlan =
                _cleanResponse(candidates[0]['content']['parts'][0]['text']);
          });
        } else {
          setState(() {
            _gardenPlan = 'No garden plan found.';
          });
        }
      } else {
        setState(() {
          _gardenPlan = 'Failed to fetch garden plan. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _gardenPlan = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\*\*|__|\*|_|##'), '').trim();
  }

  Widget _buildDropdown(String label, List<String> options,
      String selectedValue, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          borderRadius: BorderRadius.circular(20),
          onChanged: (newValue) {
            if (newValue == 'Custom') {
              _customController.clear();
            }
            onChanged(newValue!);
          },
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 240, 205),
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌿 Plan Your Garden!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                _buildDropdown(
                    'Dimensions', _dimensionOptions, _selectedDimension,
                    (value) {
                  setState(() => _selectedDimension = value);
                }),
                _buildDropdown('Sunlight', _sunlightOptions, _selectedSunlight,
                    (value) {
                  setState(() => _selectedSunlight = value);
                }),
                _buildDropdown('Soil', _soilOptions, _selectedSoil, (value) {
                  setState(() => _selectedSoil = value);
                }),
                _buildDropdown('Style', _styleOptions, _selectedStyle, (value) {
                  setState(() => _selectedStyle = value);
                }),
                _buildDropdown('Plants', _plantOptions, _selectedPlants,
                    (value) {
                  setState(() => _selectedPlants = value);
                }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fetchGardenPlan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)
                        : const Text('Generate Layout',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),
                if (_gardenPlan.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _gardenPlan,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
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
