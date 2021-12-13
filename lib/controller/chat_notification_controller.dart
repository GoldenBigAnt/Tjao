
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/chat_user.dart';

class ChatNotificationController {
  static List<ChatUser> chatUser = [];

  static fetchChatUserHistory() async {
    String currentTime = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}";
    String url = baseApiURL + "method=get_chat_users&id=$userId&curr_time=${Uri.encodeComponent(currentTime)}";
    final response = await http.get(url, headers: headers);
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    chatUser = parsed.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();
  }

  Future<int> unReadMessageCount() async {
    missedMessageList.clear();
    await fetchChatUserHistory();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final jsonResponse = json.decode(prefs.getString('savedMissedMessages'));
      missedMessageList = jsonResponse.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();
    } catch(error) {
    }
    if(chatUser.length > 0) {
      for(var i = 0; i < chatUser.length; i++) {
        if(chatUser[i].read_status == 0) {
          if(missedMessageList.length > 0) {
            int k = missedMessageList.indexWhere((element) => element.id == chatUser[i].id);
            if(k == -1) {
              missedMessageList.add(chatUser[i]);
            } else {
              missedMessageList[k] = chatUser[i];
            }
          } else {
            missedMessageList.add(chatUser[i]);
          }
          prefs.setString('savedMissedMessages', json.encode(missedMessageList));
        }
      }
    }
    return missedMessageList.length;

  }
}