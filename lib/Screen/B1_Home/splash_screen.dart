import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/Screen/B3_Navigation/LocationService.dart';
import 'package:tjao/Screen/Bottom_Nav_Bar/bottomNavBar.dart';
import 'package:tjao/Screen/Login/onboarding_page.dart';
import 'package:tjao/controller/user_controller.dart';
import 'package:tjao/helper/helper.dart';
import 'dart:io' show Platform;


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  bool _connection = true;

  ///
  /// Checking user is logged in or not logged in
  ///
  ///
  checkUser() async {
    await UserController.getUserId();
    LocationService();
    if(userId > 0) {
      await UserController.getUserSetting();
    }
    print(['user already logged in with $userId', userSetting.checkIn]);
  }

  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(seconds: 5), navigatorPage);
  }

  /// Navigate user if already login or no
  void navigatorPage() {
    if(userId == 0) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => OnBoardingPage())
      );
    }
    else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar())
      );
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
    ///
    /// Check connectivity
    ///
    connectivity = new Connectivity();
    subscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          startTime();
          _connection = true;
        });
      } else {
        setState(() {
          _connection = false;
        });
      }
    });

    if (Platform.isAndroid) {
      // Android-specific code
      startTime();
    } else if (Platform.isIOS) {
      startTime();
      // iOS-specific code
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: _connection ? Container(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/image/logo.jpeg",
                      height: 97,
                      width: 300,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) : Column(
          children: <Widget>[
            SizedBox(
              height: 150.0,
            ),
            Container(
              height: 270.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/image/noInternet.png")),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "No Connection",
              style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: "Sofia",
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFAD2829)),
            ),
            SizedBox(
              height: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Text(
                "No internet connection found. Check your connection or try again",
                style: TextStyle(
                  fontSize: 17.0,
                  fontFamily: "Sofia",
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
