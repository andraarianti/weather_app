import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late GoogleMapController mapController;
  String weatherApiKey = '';
  String _weather = 'Loading...';
  double _temperature = 0;
  double _latitude = 0;
  double _longitude = 0;
  String _city = 'Loading...';

  @override
  void initState() {
    super.initState();
    _updateWeather();
  }

  Future<void> _updateWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$weatherApiKey'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      String weather = data['weather'][0]['description'];
      double temp = data['main']['temp'];
      double temperature = temp.toDouble();
      double latitude = position.latitude;
      double longitude = position.longitude;
      String city = data['name'];
      setState(() {
        _weather = weather;
        _temperature = temperature;
        _latitude = latitude;
        _longitude = longitude;
        _city = city;
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  IconData _getWeatherIcon(String weatherDescription) {
    if (weatherDescription.toLowerCase().contains('rain')) {
      return Icons.cloudy_snowing;
    } else if (weatherDescription.toLowerCase().contains('cloud')) {
      return Icons.cloud;
    } else if (weatherDescription.toLowerCase().contains('clear')) {
      return Icons.wb_sunny;
    } else {
      return Icons.wb_sunny;
    }
  }

  Gradient _getBackgroundColor(String weatherDescription) {
    List<Color> gradientColors;

    if (weatherDescription.toLowerCase().contains('rain')) {
      gradientColors = [Colors.blueGrey[800]!, Colors.blueGrey[600]!];
    } else if (weatherDescription.toLowerCase().contains('cloud')) {
      gradientColors = [Colors.blue[500]!, Colors.blue[300]!];
    } else if (weatherDescription.toLowerCase().contains('clear')) {
      gradientColors = [Colors.lightBlue[300]!, Colors.lightBlue[100]!];
    } else {
      gradientColors = [Colors.blue[200]!, Colors.blue[100]!]; // Default gradient for unknown weather
    }

    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    String googleApiKey = '';
    String mapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$_latitude,$_longitude&markers=$_latitude,$_longitude&zoom=20&size=600x300&key=$googleApiKey';

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the app bar shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundColor(_weather),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Icon(
                _getWeatherIcon(_weather),
                color: Colors.white,
                size: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pin_drop_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$_city',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '$_weather',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${_temperature}°C',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Latitude: $_latitude',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                'Longitude: $_longitude',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Maps Weather Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    mapUrl,
                    fit: BoxFit.cover,
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
