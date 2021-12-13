import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tjao/helper/app_config.dart';
import 'event_detail_page.dart';
import 'EventGuests.dart';
import 'package:tjao/Screen/B4_Profile/B4_Add_Event.dart';
import 'package:flutter/gestures.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/Screen/B4_Profile/B4_Profile.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/event.dart';

///
/// Intro if user open first apps
///
// ignore: must_be_immutable
class EventPage extends StatefulWidget {
  int userId;

  EventPage({this.userId});
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
          builder: (context) => EventHome()
      ),
    );
  }
}

// ignore: must_be_immutable
class EventHome extends StatefulWidget {
  int userId;
  EventHome({this.userId});

  _EventHomeState createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  GlobalKey _profileShowCase = GlobalKey();
  GlobalKey _searchShowCase = GlobalKey();
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  Future<List<Event>> futureData;
  String eventType = "";
  String profilePic = "";
  bool loadImage = true;

  bool _connection = true;

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<Event>> fetchEvents(http.Client client) async {
    String url = baseApiURL + "method=get_events&id=$userId";
    if(eventType == "private") {
      url = baseApiURL + "method=get_private_events&id=$userId";
    } else if(eventType == "public") {
      url = baseApiURL + "method=get_public_events&id=$userId";
    }
    final response = await client.get(url, headers: headers);
    return compute(parseEvents, response.body);
  }

  Future<Null> _function() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState(() {
      if (prefs.getString("profile_pic") != null) {
        profilePic = prefs.getString("profile_pic");
      } 
    });
  }

  void refreshEventList(){
    setState(() {
      futureData = fetchEvents(http.Client());
    });
  }

  ///
  /// Check connectivity
  ///
  @override
  void initState() {
    connectivity = new Connectivity();
    subscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          _connection = false;
        });
      }
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        loadImage = false;
      });
    });
    // TODO: implement initState
    super.initState();
    _function();
    futureData = fetchEvents(http.Client());
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Widget _search = Container(
    height: 45.0,
    width: double.infinity,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5.0,
              spreadRadius: 0.0)
        ]),
    child: Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: Color(0xFFAD2829),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            "Find on event",
            style: TextStyle(
                fontFamily: "Sofia",
                fontWeight: FontWeight.w400,
                color: Colors.black45,
                fontSize: 16.0),
          )
        ],
      ),
    ),
  );

  Widget build(BuildContext context) {
    SharedPreferences preferences;

    displayShowcase() async {
      preferences = await SharedPreferences.getInstance();
      bool showcaseVisibilityStatus = preferences.getBool("showShowcase");

      if (showcaseVisibilityStatus == null) {
        preferences.setBool("showShowcase", false).then((bool success) {
          if (success)
            print("Successfull in writing showShowcase");
          else
            print("some bloody problem occured");
        });

        return true;
      }

      return false;
    }

    displayShowcase().then((status) {
      if (status) {
        ShowCaseWidget.of(context).startShowCase([
          _profileShowCase,
          _searchShowCase,
        ]);
      }
    });

    return KeysToBeInherited(
      profileShowCase: _profileShowCase,
      searchShowCase: _searchShowCase,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: new IconButton(
            icon: new Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              await Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, __, ___) => new AddEventPage()
              ));
              refreshEventList();
            },
          ),
          title: Text(
            "Events",
            style: TextStyle(
              fontFamily: "Sofia",
              fontWeight: FontWeight.w800,
              fontSize: 28.0,
              letterSpacing: 1.5,
              color: Colors.black
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            PhotoProfileShowcase(

              profilePic: profilePic,
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  InkWell(
                      onTap: () {
                      },
                      child: SearchShowcase()
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,                  
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Builder(
                          builder: (context) {
                          return OutlineButton(
                            onPressed: () {
                              setState(() {
                                eventType = "public";
                                futureData = fetchEvents(http.Client());
                              });
                            },
                            borderSide: BorderSide(
                              color: eventType == "public" ? Color(0xFFad2829) : Colors.grey,
                              style: BorderStyle.solid, //Style of the border
                              width: 1.0, //width of the border
                            ),
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: Color(0xFFad2829),
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Text("Public", style: TextStyle(color: eventType == "public" ? Color(0xFFad2829) : Colors.grey)),
                              ],
                            ),
                          );
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 5),
                        child: Builder(
                          builder: (context) {
                          return OutlineButton(
                            onPressed: () {
                              setState(() {
                                eventType = "private";
                                futureData = fetchEvents(http.Client());
                              });
                            },
                            borderSide: BorderSide(
                              color: eventType == "private" ? Color(0xFFad2829) : Colors.grey, //Color of the border
                              style: BorderStyle.solid, //Style of the border
                              width: 1.0, //width of the border
                            ),
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: Color(0xFFad2829),
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Text("Private", style: TextStyle(color: eventType == "private" ? Color(0xFFad2829) : Colors.grey)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ]
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Popular Events",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: "Sofia",
                              fontSize: 17.0
                          )
                      ),
                      InkWell(
                          onTap: () {
                            setState(() {
                              eventType = "";
                              futureData = fetchEvents(http.Client());
                            });
                            /*Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    new allPopularEvents()));*/
                          },
                          child: Text(
                              "View all",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Sofia",
                                  color: Color(0xFFAD2829)
                              )
                          )
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: FutureBuilder<List<Event>>(
                        //future: fetchEvents(http.Client()),
                        future: futureData,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? EventDataScreen(

                                list: snapshot.data,
                                notifyParent: refreshEventList,
                              ) : Center(child: CircularProgressIndicator());
                        },
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PhotoProfileShowcase extends StatelessWidget {
  int userId;
  String profilePic;

  PhotoProfileShowcase({this.userId, this.profilePic});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 9.0),
        child: InkWell(
            onTap: () {
            },
            child: Showcase(
              key: KeysToBeInherited.of(context).profileShowCase,
              description: "Photo Profile",
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    image: DecorationImage(
                        image: NetworkImage(
                            profilePic != null ? baseUploadURL + profilePic
                            : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png"),
                        fit: BoxFit.cover
                    )
                ),
              ),
            )),
      ),
    ]);
  }
}

class SearchShowcase extends StatelessWidget {
  const SearchShowcase({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: KeysToBeInherited.of(context).searchShowCase,
      description: "Click Here To Search Events",
      child: Container(
        height: 45.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5.0,
                  spreadRadius: 0.0)
            ]),
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: Color(0xFFAD2829),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "Find on event",
                style: TextStyle(
                    fontFamily: "Sofia",
                    fontWeight: FontWeight.w400,
                    color: Colors.black45,
                    fontSize: 16.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _loadingDataHeader(BuildContext context) {
  return ListView.builder(
    shrinkWrap: true,
    primary: false,
    itemCount: 8,
    itemBuilder: (context, i) {
      return cardHeaderLoading(context);
    },
  );
}

// ignore: must_be_immutable
class EventDataScreen extends StatelessWidget {
  int userId;
  final List<Event> list;
  final Function() notifyParent;
  EventDataScreen({this.userId, this.list, @required this.notifyParent});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: list.length,
        itemBuilder: (context, i) {
          String eventName = list[i].event_name;
          String eventType = list[i].event_type;
          String eventDate = list[i].event_date;
          String startTime = list[i].start_time;
          String location = list[i].location;
          String city = list[i].city;
          int eventId = list[i].event_id;
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

          return InkWell(
            onTap: () async{
              await Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new EventDetailPage(
                        eventId: eventId,
                        event_type: eventType,
                        event_name: eventName,
                        event_date: eventDate,
                        imageUrl: imageUrl,
                        start_time: startTime,
                        location: location,
                        city: city,
                        description: description,

                        added_by: added_by,
                        joined: joined,
                        approved: approved
                  ),
                  transitionDuration: Duration(milliseconds: 600),
                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }
              ));
              this.notifyParent();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: <Widget>[
                  Hero(
                    tag: 'hero-tag-$eventId',
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
                              eventName,
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              (eventType == "Public" || added_by == userId || (joined > 0 && approved > 0))? "$location\n$city" : city,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              eventDate,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45
                              ),
                            ),
                            Visibility(
                              visible: (eventType == "Private")? true: false,
                              child: (bar_id > 0) ? Text(
                                'By: $bar_name',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Sofia",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black
                                ),
                              ) : RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text :'By: ',
                                          style: TextStyle(fontSize: 14, fontFamily: "Sofia",fontWeight: FontWeight.w400,color: Colors.black)
                                        ),
                                        TextSpan(
                                          text: '$created_by',
                                          style: TextStyle(fontSize: 14, fontFamily: "Sofia",fontWeight: FontWeight.w400,color: Colors.blue),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              if(added_by == userId){
                                                Navigator.of(context).push(PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => new ProfilePage()
                                                ));
                                              }else{
                                                Navigator.of(context).push(PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => new UserProfilePage(friendId: added_by,)
                                                ));
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
                                          pageBuilder: (_, __, ___) => new ProfilePage()
                                        ));
                                      }else{
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: joinee1,)
                                        ));
                                      }
                                    },
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(baseUploadURL + pic1),
                                            fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                      )
                                    )
                                   ) : Container(),
                                  (pic2 != "")? new InkWell(
                                    onTap: () {
                                      if(joinee2 == userId){
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new ProfilePage()
                                        ));
                                      }else{
                                        Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: joinee2,)
                                        ));
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
                                            fit: BoxFit.cover,
                                        ),
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
                                              eventId: eventId,

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
          );
        });
  }
}

Widget cardHeaderLoading(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0),
    child: Container(
      height: 390.0,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.grey[300],
          boxShadow: [
            BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                spreadRadius: 0.2,
                blurRadius: 0.5)
          ]),
      child: Shimmer.fromColors(
        baseColor: Colors.black38,
        highlightColor: Colors.white,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Container(
                height: 210.0,
                width: 180.0,
                decoration: BoxDecoration(color: Colors.black12, boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      spreadRadius: 0.2,
                      blurRadius: 0.5)
                ]),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 18.0,
                        width: 130.0,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: 13.0,
                      ),
                      Container(
                        height: 15.0,
                        width: 105.0,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: 13.0,
                      ),
                      Container(
                        height: 15.0,
                        width: 105.0,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.black45,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.black45,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.black45,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class KeysToBeInherited extends InheritedWidget {
  final GlobalKey profileShowCase;
  final GlobalKey searchShowCase;
  final GlobalKey joinShowCase;

  KeysToBeInherited({
    this.profileShowCase,
    this.searchShowCase,
    this.joinShowCase,
    Widget child,
  }) : super(child: child);

  static KeysToBeInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KeysToBeInherited>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}


