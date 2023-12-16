import 'package:flutter/material.dart';
import 'package:weather_today_completed/screens/city_screen.dart';
import 'package:weather_today_completed/screens/location_screen.dart';

import 'screens/loading_screen.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(
          cityName: '',
        ),
        '/city': (context) => CityScreen(),
        '/location': (context) => LocationScreen(
          cityName: '',
        ),
      },
    );
  }
}
