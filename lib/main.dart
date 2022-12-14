import 'package:control_app/home.dart';
import 'package:control_app/screens/bluetooth_status.dart';
import 'package:control_app/screens/connection_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Multi Signals Viewer',
        theme: ThemeData(
          primaryColor: Colors.grey[900],
        ),
        home: SplashScreen());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SplashScreenView(
            navigateRoute: Services(),
            duration: 4000,
            imageSize: 300,
            imageSrc: "assets/akwa.png",
            text: 'Multi Signals Viewer',
            speed: 150,
            textType: TextType.TyperAnimatedText,
            textStyle: TextStyle(
              fontSize: 25.0,
            ),
            backgroundColor: Colors.white,
          ),
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Powered by Akwa Mix'),
                Text('Team 15'),
              ],
            ),
            bottom: 50,
          )
        ],
      ),
    );
  }
}

class Services extends StatelessWidget {
  const Services({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FlutterBluetoothSerial.instance.requestEnable(),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return BluetoothStatus();
        } else {
          return ConnectionRoute();
        }
      },
    );
  }
}
