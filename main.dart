import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Ensure this is uncommented
import 'landing_page.dart';
import 'package:geolocator/geolocator.dart';
import 'splash_screen.dart'; // Import your splash screen
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check internet connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    runApp(MyApp(showError: true)); // Show error if no internet connection
  } else {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    } catch (e) {
      runApp(MyApp(showError: true)); // Show error if Firebase initialization fails
    }
  }
}

class MyApp extends StatelessWidget {
  final bool showError; // To manage error state

  MyApp({this.showError = false}); // Default to false if not provided

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri-Vision AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: showError ? ErrorScreen() : SplashScreen(), // Use SplashScreen here
    );
  }
}

// Create an error screen to display messages
class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Error!',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Failed to connect to the internet or initialize Firebase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                runApp(MyApp()); // Restart the app
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return CropYieldDashboardScreen(user: user); // Pass user data to screen
        } else {
          return const LandingPage(); // Show sign-in or create account forms if not signed in
        }
      },
    );
  }
}

// Custom App Bar with a refresh indicator and logout toggle button
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 24, 97, 27),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Agri-Vision AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120.0);
}


// Dashboard with Refresh Indicator and Location-based Data
class CropYieldDashboardScreen extends StatefulWidget {
  final User user; // Add user parameter

  const CropYieldDashboardScreen({super.key, required this.user});

  @override
  _CropYieldDashboardScreenState createState() => _CropYieldDashboardScreenState();
}

class _CropYieldDashboardScreenState extends State<CropYieldDashboardScreen> {
  String _location = 'Fetching location...';
  double _temperature = 0.0;
  double _rainfall = 0.0;
  String _description = '';
  double _humidity = 0.0;
  double _windSpeed = 0.0;
  String _iconUrl = 'https://cdn.weatherapi.com/weather/64x64/day/113.png';
  bool _isLoading = true; // To track loading state

  Future<void> _fetchWeatherData(Position position) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final apiKey = '3a88e5ed149840d989791620243009';
    final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Weather API Response: $data");
      setState(() {
        _temperature = (data['current']['temp_c'] as num).toDouble();
        _rainfall = (data['current']['precip_mm'] as num).toDouble();
        _humidity = (data['current']['humidity'] as num).toDouble();
        _description = data['current']['condition']['text'];
        _iconUrl = data['current']['condition']['icon'];
        _location = '${data['location']['region']}, ${data['location']['country']}';
        _windSpeed = (data['current']['wind_kph'] as num).toDouble();
        _isLoading = false; // Loading complete
      });
    } else {
      setState(() {
        _location = 'Failed to fetch weather data';
        _isLoading = false; // Loading complete
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await _fetchWeatherData(position);
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getLocation();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Welcome, ${widget.user.email!.split('@')[0]}!', // Extract first name from email
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_isLoading) // Show spinner and message while loading
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white, // Set spinner color to green
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Fetching weather data...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                )
                else
                  // Weather Data Card
                  SizedBox(
        width: double.infinity, // Expands card to fit screen width
        child: Card(
                    color: Colors.green[100],
                    shadowColor: Colors.black45,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Current Weather',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Location: $_location',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            'https:$_iconUrl',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _description,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Temperature: ${_temperature.toStringAsFixed(1)} °C',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rainfall: ${_rainfall.toStringAsFixed(1)} mm',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Humidity: $_humidity%',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Wind Speed: $_windSpeed km/h',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
  
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the prediction module
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PredictionFormScreen(), // Updated to navigate to the renamed form screen
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Predict Crop Yield', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Crop Yield Prediction Form Screen
class PredictionFormScreen extends StatefulWidget { // Renamed from CropYieldPredictionScreen
  const PredictionFormScreen({super.key});

  @override
  PredictionFormScreenState createState() => PredictionFormScreenState(); // Renamed createState method
}

class PredictionFormScreenState extends State<PredictionFormScreen> {
  final TextEditingController _daysController = TextEditingController();
  final List<String> _cropTypes = ['Cotton', 'Rice', 'Barley', 'Soybean', 'Wheat', 'Maize'];
  final List<String> _soilTypes = ['Sandy', 'Clay', 'Loam', 'Silt', 'Chalky', 'Peaty'];
  //final List<String> _regions = ['East', 'West', 'South', 'North'];

  String? _selectedCropType;
  String? _selectedSoilType;
  String? _selectedRegion;
  bool _fertilizerUsed = false;
  bool _irrigationUsed = false;
  String _predictedYield = '';
  bool _isLoading = false;
  bool _isKgs = false;
  String _errorMessage = '';

  Future<void> _predictYield() async {
    // Validation checks
    if (_selectedCropType == null || _selectedSoilType == null) {
      setState(() {
        _errorMessage = 'Please fill all required fields.';
      });
      return;
    }
    
    final daysToHarvest = int.tryParse(_daysController.text);
    if (daysToHarvest == null || daysToHarvest < 70) {
      setState(() {
        _errorMessage = 'Harvest days must be at least 70 days.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _predictedYield = '';
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://agri-visionai-f1a01ee8f2c5.herokuapp.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'crop_type': _selectedCropType,
          'soil_type': _selectedSoilType,
          'region': _selectedRegion,
          'fertilizer_used': _fertilizerUsed,
          'irrigation_used': _irrigationUsed,
          'days_to_harvest': daysToHarvest,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictedYield = data['predicted_yield'].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error predicting yield: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void resetForm() {
    setState(() {
      _daysController.clear();
      _selectedCropType = null;
      _selectedSoilType = null;
      _selectedRegion = null;
      _fertilizerUsed = false;
      _irrigationUsed = false;
      _predictedYield = '';
      _isKgs = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 252, 248),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Crop Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              hint: const Text('Select Crop'),
              value: _selectedCropType,
              isExpanded: true,
              items: _cropTypes.map((String crop) {
                return DropdownMenuItem<String>(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCropType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Soil Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._soilTypes.map((soil) {
              return RadioListTile<String>(
                title: Text(soil),
                value: soil,
                groupValue: _selectedSoilType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSoilType = value;
                  });
                },
                activeColor: Colors.green, // Set to green for "Yes"
              );
            }),
           // const SizedBox(height: 20),
           // const Text('Select Region:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           // DropdownButton<String>(
          //    hint: const Text('Select Region'),
           //   value: _selectedRegion,
           //   isExpanded: true,
          //    items: _regions.map((String region) {
          //      return DropdownMenuItem<String>(
           //       value: region,
            //      child: Text(region),
          //      );
          //    }).toList(),
          //    onChanged: (String? newValue) {
          //      setState(() {
          //        _selectedRegion = newValue;
          //      });
          //    },
         //   ),
            const SizedBox(height: 20),
            const Text('Fertilizer Used:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _fertilizerUsed,
                  onChanged: (value) {
                    setState(() {
                      _fertilizerUsed = value!;
                    });
                  },
                  activeColor: Colors.green, // Set to green for "Yes"
                ),
                const Text('Yes'),
                Radio<bool>(
                  value: false,
                  groupValue: _fertilizerUsed,
                  onChanged: (value) {
                    setState(() {
                      _fertilizerUsed = value!;
                    });
                  },
                  activeColor: Colors.red, // Set to green for "Yes"
                ),
                const Text('No'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Irrigation Used:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _irrigationUsed,
                  onChanged: (value) {
                    setState(() {
                      _irrigationUsed = value!;
                    });
                  },
                  activeColor: Colors.green, // Set to green for "Yes"
                ),
                const Text('Yes'),
                Radio<bool>(
                  value: false,
                  groupValue: _irrigationUsed,
                  onChanged: (value) {
                    setState(() {
                      _irrigationUsed = value!;
                    });
                  },
                  activeColor: Colors.red, // Set to green for "Yes"
                ),
                const Text('No'),
                
              ],
            ),
            const SizedBox(height: 20),
            const Text('Approximate the days required for crop harvest:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                 enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green, width: 2.0), // Set the border color to green
                ),
               focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green, width: 2.0), // Set the focused border color to green
            ),
                labelText: 'Days',
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _isLoading ? null : _predictYield,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: _isLoading
                  ? const SpinKitChasingDots(color: Colors.white, size: 25.0)
                  : const Text('Predict Yield', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            if (_predictedYield.isNotEmpty)
              Text(
                'Predicted Yield: ${_isKgs ? (double.parse(_predictedYield) * 1000).toStringAsFixed(2) : _predictedYield} ${_isKgs ? 'kgs' : 'tonnes'} per hectare',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isKgs = !_isKgs;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(_isKgs ? 'Convert to Tonnes' : 'Convert to Kgs', style: TextStyle(color: Colors.white)),
            ),
           // const SizedBox(height: 10),
            //ElevatedButton(
              //onPressed: resetForm,
              //style: ElevatedButton.styleFrom(
                //backgroundColor: Colors.red,
              //),
              //child: const Text('Reset Form', style: TextStyle(color: Colors.white)),
           // ),
          ],
        ),
      ),
    );
  }
} 
