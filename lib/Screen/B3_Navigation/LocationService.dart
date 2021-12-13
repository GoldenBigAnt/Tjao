
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';

class LocationService {
  var location = Location();

  checkAndRequestLocationPermissions() async {
    if (await Permission.location.request().isGranted) {
      location_permission_granted = true;
    } else{
      location_permission_granted = false;
    }


    if (location_permission_granted) {
      getLocation();
      // If granted listen to the onLocationChanged stream and emit over our controller
      location.onLocationChanged().listen((locationData) {
        if (locationData != null) {
          // print('latitude---: ${locationData.latitude}');
          // print('longitude---: ${locationData.longitude}');
          updateLocation(locationData.latitude, locationData.longitude);
        }
      });
    }
  }

  Future<void> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      if(userLocation != null){
        updateLocation(userLocation.latitude, userLocation.longitude);
      }
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }

  updateLocation(double lat, double lng) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId > 0) {
      int loc_time = 0;
      if(prefs.getInt("loc_time") != null){
        loc_time = prefs.getInt("loc_time");
      }
      int loc_time_diff = DateTime.now().millisecondsSinceEpoch - loc_time;

      if(userId > 0 && (loc_time == 0 || loc_time_diff > 60000) && userSetting.checkIn == 0){
        // print("-------------loc_time_diff: ${loc_time_diff}");

        prefs.setInt("loc_time", DateTime.now().millisecondsSinceEpoch);
        String url = baseApiURL + "method=add_location&id=$userId&lat=$lat&lng=$lng";
        await http.Client().get(url);
      }
    }
  }

  LocationService() {
    // Request permission to use location
    checkAndRequestLocationPermissions();
    // if (permission_granted) {
    //   getLocation();
    //   // If granted listen to the onLocationChanged stream and emit over our controller
    //   location.onLocationChanged().listen((locationData) {
    //     if (locationData != null) {
    //      print('latitude---: ${locationData.latitude}');
    //      print('longitude---: ${locationData.longitude}');
    //       updateLocation(locationData.latitude, locationData.longitude);
    //     }
    //   });
    // }
    // else{
    //   print('Location permission not granted');
    //   getLocation();
    // }
  }
}