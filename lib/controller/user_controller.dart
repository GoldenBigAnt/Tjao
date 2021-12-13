import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/user_setting.dart';
import 'package:http/http.dart' as http;

class UserController {
  static getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt("user_id") != null && prefs.getInt("user_id") > 0) {
      userId = prefs.getInt("user_id");
    }
  }

  static getUserSetting() async {
    String url = baseApiURL + "method=get_user_privacy&id=$userId";
    final response = await http.get(url, headers: headers);
    final parsed = jsonDecode(response.body);
    userSetting = UserSetting.fromJson(parsed);
  }
}