
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/model/notification.dart';

class GeneralNotificationController {

  static List<NotificationData> notificationData = [];

  static fetchNotificationData() async {
    String url = baseApiURL + "method=get_notification_data&id=$userId";
    final response = await http.get(url, headers: headers);
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    notificationData = parsed.map<NotificationData>((json) => NotificationData.fromJson(json)).toList();
  }

   Future<int> notificationCount() async {
    notificationDataList.clear();
    await fetchNotificationData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove("notificationData");
    try {
      final jsonResponse = json.decode(prefs.getString('notificationData'));
      notificationDataList = jsonResponse.map<NotificationData>((json) => NotificationData.fromJson(json)).toList();
    } catch(error) {
    }

    if(notificationData.length > 0) {
      for(var i = 0; i < notificationData.length; i++) {
        if(notificationData[i].noti_status == 0) {
          if(notificationDataList.length > 0) {
            int k = notificationDataList.indexWhere((element) => element.id == notificationData[i].id);
            if(k == -1) {
              notificationDataList.add(notificationData[i]);
            } else {
              notificationDataList[k] = notificationData[i];
            }
          } else {
            notificationDataList.add(notificationData[i]);
          }
          prefs.setString('notificationData', json.encode(notificationDataList));
        }
      }
    }
    return notificationDataList.length;
  }
}