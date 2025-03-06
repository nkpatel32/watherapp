import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w700, 
            color: Colors.blueGrey[900]
          ),
        ),
      ),
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey = 'e3ead430f662473fb21123019250603';
    final String url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _animationController.forward(from: 0.0);
        });
      } else {
        _showErrorDialog('City not found or an error occurred.');
      }
    } catch (e) {
      _showErrorDialog('Error fetching weather data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Weather Insight',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.blueGrey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.blueGrey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather Insights',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Get real-time weather information',
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildSearchField(),
                    SizedBox(height: 20),
                    _isLoading
                        ? _buildLoadingIndicator()
                        : _weatherData != null
                            ? FadeTransition(
                                opacity: _animation,
                                child: WeatherDetailCard(weatherData: _weatherData!),
                              )
                            : _buildWelcomeMessage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _cityController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Enter city name',
          hintStyle: TextStyle(color: Colors.blueGrey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blueGrey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  fetchWeather(_cityController.text);
                }
              },
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(color: Colors.blueGrey[800]),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 100,
            color: Colors.blueGrey[300],
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to Weather Insights',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Discover weather conditions for any city',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }
}
class WeatherDetailCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  WeatherDetailCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    // Format the date - in a real app, use DateTime.now()
    //final String currentDate = 'March 06, 2025'; // Static for demo
    // For dynamic date, you could use:
    final DateTime now = DateTime.now();
    final String currentDate = DateFormat('MMMM dd, yyyy').format(now);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              '${weatherData['location']['name']}, ${weatherData['location']['country']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[900],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              currentDate,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getWeatherIcon(weatherData['current']['condition']['text']),
                  size: 70,
                  color: Colors.blueGrey[600],
                ),
                SizedBox(width: 15),
                Text(
                  '${weatherData['current']['temp_c']}°C',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '${weatherData['current']['condition']['text']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailChip(
                  'Humidity',
                  '${weatherData['current']['humidity']}%',
                  Icons.water_drop_outlined,
                ),
                _buildDetailChip(
                  'Wind',
                  '${weatherData['current']['wind_kph']} kph',
                  Icons.air,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('cloud')) return Icons.cloud_outlined;
    if (condition.contains('rain')) return Icons.water_drop_outlined;
    if (condition.contains('sun')) return Icons.wb_sunny_outlined;
    if (condition.contains('clear')) return Icons.wb_sunny_outlined;
    return Icons.wb_cloudy_outlined;
  }

  Widget _buildDetailChip(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueGrey[700], size: 30),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.blueGrey[600], fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.blueGrey[900],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}