import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/chat_user.dart';

import 'chat_board_page.dart';

class ChatNotificationPage extends StatefulWidget {
  const ChatNotificationPage({Key key}) : super(key: key);

  @override
  _ChatNotificationPageState createState() => _ChatNotificationPageState();
}

class _ChatNotificationPageState extends State<ChatNotificationPage> {

  removeSelectedMessage(int index) async {
    missedMessageList.removeAt(index);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('savedMissedMessages', json.encode(missedMessageList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            "Unread Messages",
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
        elevation: 10.0,
      ),
      body: missedMessageList.length > 0 ? Container(
        padding: EdgeInsets.only(top: 20, bottom: 10),
        child: ListView.separated(
          itemCount: missedMessageList.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, color: Colors.black,),
          itemBuilder: (context, index) {
            ChatUser msg = missedMessageList[missedMessageList.length - 1 - index];
            return ListTile(
              onTap: () async {
                int i = missedMessageList.length - 1 - index;
                await removeSelectedMessage(i);
                await Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (_, ___, ____) =>
                        new ChatBoardPage(friedId: msg.to_id, id : msg.from_id, friendName: msg.user_name)
                ));
              },
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black12,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(msg.user_pic != '' ? baseUploadURL + msg.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                  ),
                ),
              ),
              title: Text(msg.user_name),
              subtitle: Text(msg.message.length < 30 ? msg.message : msg.message.substring(0, 30) + ' ...',),
              trailing: Container(
                child: Text(msg.date_time),
              ),
            );
          },
        ),
      )
      : Center(
        child: Text(
            'There is no a new message for now.',
            style: TextStyle(
              fontSize: 14,
            ),
        ),
      ),
    );
  }
}
