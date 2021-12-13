import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/Screen/B1_Event/event_detail_page.dart';
import 'package:tjao/Screen/B1_Home/home_page.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/notification.dart';
import 'package:http/http.dart' as http;

class GeneralNotification extends StatefulWidget {
  const GeneralNotification({Key key}) : super(key: key);

  @override
  _GeneralNotificationState createState() => _GeneralNotificationState();
}

class _GeneralNotificationState extends State<GeneralNotification> {
  Future<List<NotificationData>> dataList;
  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<NotificationData>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final jsonResponse = json.decode(prefs.getString('notificationData'));
      return jsonResponse.map<NotificationData>((json) => NotificationData.fromJson(json)).toList();
    } catch(error) {
      return null;
    }
  }

  removeSelectedNotificationData(int index, int notificationId) async {
    notificationDataList.removeAt(index);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notificationData', json.encode(notificationDataList));
    String url = baseApiURL + "method=update_notification_status&notification_id=$notificationId";
    await http.get(url, headers: headers);
  }

  goToHomePage(int timelineId) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(selectedTimelineId: timelineId,))
    );
  }

  goToEventDetailsPage(int eventId) async {
    String url = baseApiURL + "method=get_events&id=$userId&event_id=$eventId";
    final response = await http.Client().get(url, headers: headers);
    if(response.body != '[]') {
      Map<String, dynamic> event = jsonDecode(response.body);
      await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => new EventDetailPage(
              eventId: eventId,
              event_type: event['event_type'],
              event_name: event['event_name'],
              event_date: event['event_date'],
              imageUrl: event['imageUrl'],
              start_time: event['start_time'],
              location: event['location'],
              city: event['city'],
              description: event['description'],
              added_by: event['added_by'],
              joined: event['joined'],
              approved: event['approved']
          ),
          transitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }
      ));
    } else {
      showToast("There is no this event.", Colors.black87);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataList = fetchData();
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
            "Notification",
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
      body: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: FutureBuilder<List<NotificationData>>(
          future: dataList,
          builder: (context, snapshot) {
            notificationDataList = snapshot.data;
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData ? ListView.separated(
              itemCount: snapshot.data.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, color: Colors.black,),
              itemBuilder: (context, index) {
                int i = snapshot.data.length - index - 1;
                NotificationData nd = snapshot.data[i];
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    onTap: () async {
                      await removeSelectedNotificationData(i, nd.id);
                      if(nd.noti_type == 'event_invite') {
                        goToEventDetailsPage(nd.event_id);
                      } else {
                        goToHomePage(nd.timeline_id);
                      }
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(nd.friend_pic != '' ? baseUploadURL + nd.friend_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                        ),
                      ),
                    ),
                    title: nd.noti_type == "tag" ? RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: nd.friend_name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            TextSpan(
                                text: ' tagged you in a post',
                                style: TextStyle(color: Colors.black)
                            )
                          ]
                      ),
                    ) : nd.noti_type == "like" ? RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: nd.friend_name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            TextSpan(
                                text: ' liked your post',
                                style: TextStyle(color: Colors.black)
                            )
                          ]
                      ),
                    ) : nd.noti_type == "comment" ? RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: nd.friend_name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            TextSpan(
                                text: ' added a comment to your post',
                                style: TextStyle(color: Colors.black)
                            )
                          ]
                      ),
                    ) : RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: nd.friend_name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            TextSpan(
                                text: ' invited you in an event',
                                style: TextStyle(color: Colors.black)
                            )
                          ]
                      ),
                    ),
                    trailing: Container(
                      width: 80,
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.topCenter,
                      child: Text(nd.timestamp),
                    ),
                  ),
                );
              },
            ) : Center(child: CircularProgressIndicator());
          },
        ),
      )
      //     : Center(
      //   child: Text(
      //     'There is no a new notification for you yet.',
      //     style: TextStyle(
      //       fontSize: 14,
      //     ),
      //   ),
      // ),
    );
  }
}
