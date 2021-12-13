import 'package:tjao/Screen/B1_Event/event_page.dart';
import 'package:tjao/Screen/B1_Home/club_main_page.dart';
import 'package:tjao/Screen/B1_Home/home_page.dart';
import 'package:tjao/Screen/B3_Navigation/B3_Map.dart';
import 'package:tjao/Screen/B3_Navigation/B3_Camera.dart';
import 'package:tjao/Screen/B4_Profile/B4_Profile.dart';
import 'package:flutter/material.dart';

import 'custom_nav_bar.dart';

// ignore: must_be_immutable
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key key}) : super(key: key);
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  bool _color = true;
  Widget callPage(int current) {
    switch (current) {
      case 0:
        return new HomePage(selectedTimelineId: 0,);
        break;
      case 1:
        return new EventPage();
        break;
      case 2:
        return new CameraPage();
        break;
      case 3:
        return new MapPage();
        break;
      case 4:
        return new ProfilePage();
        break;
      default:
        return new ClubMainPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callPage(currentIndex),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.white,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme
                .of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.black26))), // sets the inactive color of the `BottomNavigationBar`
        child: new BottomNavigationDotBar(
          color: Colors.black26,
          items: <BottomNavigationDotBarItem>[
                BottomNavigationDotBarItem(
                    icon: IconData(0xe900, fontFamily: 'home'),
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    }),
                  BottomNavigationDotBarItem(
                    icon: IconData(0xe707, fontFamily: 'MaterialIcons'),
                    onTap: () {
                      setState(() {
                        currentIndex = 1;
                      });
                    }),
                  BottomNavigationDotBarItem(
                    //icon: Icon(Icons.camera),
                    //icon: IconData(0xe62e, fontFamily: 'MaterialIcons'),
                    icon: Icons.camera_alt,
                    onTap: () {
                      setState(() {
                        currentIndex = 2;
                      });
                    }),
                  BottomNavigationDotBarItem(
                    icon: IconData(0xe8a0, fontFamily: 'MaterialIcons'),
                    onTap: () {
                      setState(() {
                        currentIndex = 3;
                      });
                    }),
                BottomNavigationDotBarItem(
                    icon: IconData(0xe900, fontFamily: 'profile'),
                    onTap: () {
                      setState(() {
                        currentIndex = 4;
                      });
                    }),
              ],
        ),
      )
    );
  }
}
