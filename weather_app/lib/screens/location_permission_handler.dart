import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/screens/home_screen.dart';

class LocationPermissionHandler extends StatefulWidget {
  const LocationPermissionHandler({Key? key}) : super(key: key);

  @override
  _LocationPermissionHandlerState createState() =>
      _LocationPermissionHandlerState();
}

class _LocationPermissionHandlerState extends State<LocationPermissionHandler> {
  PermissionStatus? _permissionStatus; // Stores the current permission status

  @override
  void initState() {
    super.initState();
    _requestPermission(); // Request location permission when widget initializes
  }

  // Function to request location permission
  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status; // Update permission status after requesting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // the app icon in center of page
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Image.asset(
                'assets/weather-app.png',
                scale: 1,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Our Weather App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Check if location permission is granted
            if (_permissionStatus == PermissionStatus.granted)
              // button to go to the weather screen
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FutureBuilder(
                        future: _determinePosition(),
                        builder: (context, snapshot) {
                          //check if the app got the location or still waiting to fetch it
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return BlocProvider<WeatherBloc>(
                              create: (context) => WeatherBloc()
                                ..add(FetchWeather(snapshot.data as Position)),
                              child: const HomeScreen(),
                            );
                          } else {
                            return const Scaffold(
                              body: Center(
                                child: Text('Error determining position'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                child: Text('Go to Home Screen'),
              ),
            // If location permission is not granted, show buttons to request permission
            if (_permissionStatus != PermissionStatus.granted)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Give permission'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Can\'t show weather data. Must give location permission.',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
