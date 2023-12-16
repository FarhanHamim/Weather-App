import 'package:flutter/material.dart';
import 'package:weather_today_completed/screens/loading_screen.dart';
import 'package:weather_today_completed/utils/constants.dart';
import 'package:geolocator/geolocator.dart';
import '../services/network.dart';
import '../utils/custom_paint.dart';
import 'city_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  final String cityName;
  final locationWeather;

  LocationScreen({this.locationWeather, required this.cityName});

//u
  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  int temperature = 0;
  int minTemperature = 0;
  int maxTemperature = 0;
  double windSpeed = 2.9;
  int humidity = 0;

  String cityName = "Dhaka";

  @override
  void initState() {
    super.initState();

    updateUI(widget.locationWeather);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.09),
              BlendMode.darken,
            ),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$temperature°',
                        style: kTempTextStyle,
                      ),
                    ),
                    // Inside the LocationScreen build method
                    GestureDetector(
                      onTap: () async {
                        final selectedCity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CityScreen();
                            },
                          ),
                        );

                        // Updating cityName when a city is selected
                        if (selectedCity != null && selectedCity is String) {
                          setState(() {
                            cityName = selectedCity;
                          });
                        }
                      },

                      child: Image.asset(
                        'images/ic_search.png',
                        width: 32.0,
                      ),
                    ),


                    SizedBox(width: 24.0),
                    GestureDetector(
                      onTap: () async {

                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                        double latitude = position.latitude;
                        double longitude = position.longitude;
                        print('Latitude: $latitude, Longitude: $longitude');
                        String apiKey = 'b001c2c7b8d3b0dd8d4b3a6c419c2daf';

                        try{
                          String cityName2 = await getCityName(latitude, longitude, apiKey);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoadingScreen(cityName: cityName2);
                              },
                            ),
                          );



                        }
                        catch (e) {
                          print('Error: $e');
                        }

                      },
                      child: Image.asset(
                        'images/ic_current_location.png',
                        width: 32.0,
                      ),
                    ),
                    SizedBox(width: 24.0),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Image.asset(
                      'images/ic_location_pin.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text(
                        cityName,
                        textAlign: TextAlign.center,
                        style: kSmallTextStyle.copyWith(
                          fontSize: 16.0,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: CustomPaint(
                  painter: MyCustomPaint(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          bottom: 24.0,
                        ),
                        child: Text(
                          'Weather Today',
                          style: kConditionTextStyle.copyWith(fontSize: 16.0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ConditionRow(
                            icon: 'images/ic_temp.png',
                            title: 'Min Temp',
                            value: '$minTemperature°',
                          ),
                          ConditionRow(
                            icon: 'images/ic_wind_speed.png',
                            title: 'Wind Speed',
                            value: '${windSpeed.toStringAsFixed(1)} Km/h',
                          ),
                          ConditionRow(
                            icon: 'images/ic_temp.png',
                            title: 'Max Temp',
                            value: '$maxTemperature°',
                          ),
                          ConditionRow(
                            icon: 'images/ic_humidity.png',
                            title: 'Humidity',
                            value: '$humidity%',
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<String> getCityName(double latitude, double longitude, String apiKey) async {
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      //From the response extract the city name
      String cityName = data['name'];

      return cityName;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      temperature = (weatherData['main']['temp']).round();
      minTemperature = (weatherData['main']['temp_min']).round();
      maxTemperature = (weatherData['main']['temp_max']).round();

      // Print the wind speed value to check if it's being fetched correctly
      print("Wind Speed Raw: ${weatherData['wind']['speed']}");

      if (weatherData['wind'] != null && weatherData['wind']['speed'] != null) {
        windSpeed = double.parse(weatherData['wind']['speed'].toString());
      } else {
        windSpeed = 0.0; // Set a default value if wind speed is not available
      }

      humidity = weatherData['main']['humidity'];
      cityName = weatherData['name'];
    });
  }


}

class ConditionRow extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const ConditionRow({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          icon,
          width: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: Text(
            title,
            style: kConditionTextStyleSmall,
          ),
        ),
        Text(
          value,
          style: kConditionTextStyle,
        ),
      ],
    );
  }
}
