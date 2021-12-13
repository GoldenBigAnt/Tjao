import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tjao/Screen/B1_Event/event_detail_page.dart';
import 'package:tjao/Screen/B1_Event/EventGuests.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/event.dart';
import 'B4_Edit_Event.dart';
import 'package:flutter/gestures.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/Screen/B4_Profile/B4_Profile.dart';

// ignore: must_be_immutable
class ManageEventsPage extends StatefulWidget {
  int userId;

  ManageEventsPage({this.userId});
  _ManageEventsPageState createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  Future<List<Event>> futureData;
  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<Event>> fetchEvents(http.Client client) async {
    String url = baseApiURL + "method=get_events&id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseEvents, response.body);
  }

  void refreshEventList(){
    setState(() {
      futureData = fetchEvents(http.Client());
    });
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchEvents(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)
        ),
        elevation: 0.0,
        title: Text(
          "Manage Events",
          style: TextStyle(
            fontFamily: "Popins",
            fontSize: 17.0,
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: FutureBuilder<List<Event>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? cardDataFirestore(
                    list: snapshot.data,
                    notifyParent: refreshEventList,
                  ) : Center(child: CircularProgressIndicator());
            },
          )
        ),
      )
    );
  }
}

class cardDataFirestore extends StatelessWidget {
  cardDataFirestore({this.list, @required this.notifyParent});

  final List<Event> list;
  final Function() notifyParent;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: list.length,
        itemBuilder: (context, i) {
          String event_name = list[i].event_name;
          String event_type = list[i].event_type;
          String event_date = list[i].event_date;
          String start_time = list[i].start_time;
          String location = list[i].location;
          String city = list[i].city;
          int event_id = list[i].event_id;
          String imageUrl = list[i].imageUrl;
          String description = list[i].description;
          int added_by= list[i].added_by;
          int joined = list[i].joined;
          int approved = list[i].approved;
          int bar_id = list[i].bar_id;
          String created_by = list[i].created_by;
          String bar_name = list[i].bar_name;
          String guests = list[i].guests;

          String pic1 = "";
          String pic2 = "";
          String pic3 = "";

          int joinee1 = 0;
          int joinee2 = 0;
          int joinee3 = 0;

          int rem_guests = 0;

          if(/*event_type == "Private" && */guests != ""){
            List<String> arr = guests.split(',');
            for(var i = 0; i < arr.length; i++){
              List<String> arr1 = arr[i].split("#");
              if(arr1[1] != ""){
                if(pic1 == ""){
                  pic1 = arr1[1];
                  joinee1 = int.parse(arr1[0]);
                }else if(pic2 == ""){
                  pic2 = arr1[1];
                  joinee2 = int.parse(arr1[0]);
                }else if(pic3 == ""){
                  pic3 = arr1[1];
                  joinee3 = int.parse(arr1[0]);
                }else{
                  rem_guests++;
                }
              }else{
                rem_guests++;
              }
            }
          }

          return (list[i].added_by == userId || list[i].joined > 0)?InkWell(
            onTap: () async{
              if(list[i].added_by != userId){
                await Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new EventDetailPage(
                        eventId: event_id,
                        event_type: event_type,
                        event_name: event_name,
                        event_date: event_date,
                        imageUrl: imageUrl,
                        start_time: start_time,
                        location: location,
                        city: city,
                        description: description,

                        added_by: added_by,
                        joined: joined,
                        approved: approved
                      ),
                  transitionDuration: Duration(milliseconds: 600),
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }));
              }else{
                await Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new EditEventPage(
                        eventId: event_id,

                      ),
                  transitionDuration: Duration(milliseconds: 600),
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }));
              }           
              this.notifyParent();
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Stack(
                children: <Widget>[
                  Hero(
                    tag: 'hero-tag-$event_id',
                    child: Material(
                      child: Container(
                        height: 390.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                                image: NetworkImage(baseUploadURL + imageUrl, scale: 1.0),
                                fit: BoxFit.cover
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12.withOpacity(0.1),
                                  spreadRadius: 0.2,
                                  blurRadius: 0.5
                              )
                            ]
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Container(
                      width: 210.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12.withOpacity(0.1),
                              spreadRadius: 0.2,
                              blurRadius: 0.5
                          )
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              event_name,
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              (event_type == "Public" || added_by == userId || (joined > 0 && approved > 0))? "$location\n$city" : city,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              event_date,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45),
                            ),
                            Visibility(
                              visible: (event_type == "Private")? true: false,
                              child: (bar_id > 0)? Text('By: $bar_name',style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),) : RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text :'By: ',
                                          style: TextStyle(fontSize: 14, fontFamily: "Sofia",fontWeight: FontWeight.w400,color: Colors.black)
                                        ),
                                        TextSpan(
                                          style: TextStyle(fontSize: 14, fontFamily: "Sofia",fontWeight: FontWeight.w400,color: Colors.blue),
                                          text: '$created_by',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              if(added_by == userId){
                                                Navigator.of(context).push(PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => new ProfilePage()));
                                              }else{
                                                Navigator.of(context).push(PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => new UserProfilePage(friendId: added_by)));
                                              }
                                            },
                                        ),
                                      ]
                                    )
                                  )
                            ),
                            SizedBox(
                              height: 5.0,
                            ), 
                            Visibility(
                              //visible: (event_type == "Private")? true: false,
                              visible: true,
                              child: Row(
                                children: [
                                  (pic1 != "")? new InkWell(
                                    onTap: () {
                                      if(joinee1 == userId){
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new ProfilePage()));
                                      }else{
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: joinee1)));
                                      }
                                    },
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(baseUploadURL + pic1),
                                            fit: BoxFit.cover,),
                                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                      )
                                    )
                                  ) : Container(),
                                  (pic2 != "")? new InkWell(
                                    onTap: () {
                                      if(joinee2 == userId){
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new ProfilePage()));
                                      }else{
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: joinee2,)));
                                      }
                                    },
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      margin: const EdgeInsets.only(left: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(baseUploadURL + pic2),
                                            fit: BoxFit.cover,),
                                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                      )
                                    )
                                  ) : Container(),
                                  (pic3 != "")? new InkWell(
                                    onTap: () {
                                      if(joinee3 == userId){
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new ProfilePage()));
                                      }else{
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: joinee3,)));
                                      }
                                    },
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      margin: const EdgeInsets.only(left: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(baseUploadURL + pic3),
                                            fit: BoxFit.cover,),
                                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                      )
                                    )
                                  ) : Container(),
                                  (rem_guests > 0)? new InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => new EventGuests(
                                              eventId: event_id,

                                            ),
                                        transitionDuration: Duration(milliseconds: 600),
                                        transitionsBuilder:
                                            (_, Animation<double> animation, __, Widget child) {
                                          return Opacity(
                                            opacity: animation.value,
                                            child: child,
                                          );
                                        }));
                                    },
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      margin: const EdgeInsets.only(left: 5.0),
                                      padding: const EdgeInsets.only(top: 4.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300],
                                            width: 2.0,
                                          ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                      ),
                                      child: Text(
                                        "+$rem_guests",
                                        style: TextStyle(fontSize: 14.0, color: Colors.grey[600],),
                                        textAlign: TextAlign.center,
                                      )
                                    )
                                  ) : Container(),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),             
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ):Container();
        });
  }
}