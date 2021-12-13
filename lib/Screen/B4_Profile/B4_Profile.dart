import 'dart:async';

import 'package:tjao/Screen/B1_Home/notification_data.dart';
import 'package:tjao/Screen/B4_Profile/chat_notification_page.dart';
import 'package:tjao/Screen/B4_Profile/update_profile_page.dart';
import 'package:tjao/Screen/B5_Payment/Subscription.dart';
import 'package:tjao/Screen/Login/chose_login_singup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjao/controller/chat_notification_controller.dart';
import 'package:tjao/controller/general_notification_controller.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/chat_user.dart';
import 'package:tjao/model/club.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/user_review.dart';
import 'package:tjao/model/user_photo.dart';
import 'B4_About_Apps.dart';
import 'B4_Call_Center.dart';
import 'B4_Add_Event.dart';
import 'view_image.dart';
import 'B4_Manage_Events.dart';
import 'chat_summary_page.dart';
import 'Privacy_Settings.dart';
import 'B4_Search_User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:tjao/Screen/B1_Home/club_profile_page.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

/// Custom Font
var _txt = TextStyle(
  color: Colors.black,
  fontFamily: "Sans",
);

/// Get _txt and custom value of Variable for Name User
var _txtName = _txt.copyWith(fontWeight: FontWeight.w700, fontSize: 17.0);

/// Get _txt and custom value of Variable for Edit text
var _txtEdit = _txt.copyWith(color: Colors.black26, fontSize: 15.0);

/// Get _txt and custom value of Variable for Category Text
var _txtCategory = _txt.copyWith(
    fontSize: 14.5, color: Colors.black54, fontWeight: FontWeight.w500);

void gotoClubProfile(BuildContext context, ClubModel club, int userId){
  Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (_, ___, ____) => new ClubProfilePage(
              clubId : club.club_id, clubName: club.clubName, address: club.address,
              bannerImg: club.bannerImg, description: club.description, upcoming: club.upcoming,
              offers: club.offers, news: club.news, max_allowance: club.max_allowance,
              rating: club.rating, distance: club.distance, visitors: club.visitors,
              live_friends: club.live_friends, phone_number: club.phone_number,
              latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing
          )
      )
  );
}

class _ProfilePageState extends State<ProfilePage> {
  Future<List<UserReview>> reviews;
  Future<List<UserPhoto>> photos;
  Future<List<Friend>> friendList;
  Future<List<ClubModel>> clubs;
  bool menuShown = false;
  bool covidPositive = false;
  int age = 0;
  int friendCount = 0;
  int eventCount = 0;
  int missedMessageCount = 0;
  String email = "", name = "", country = "", city = "", gender = "", sexual = "", status = "", height = "", hobbies = "";
  String photoProfile = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
  Future<int> unReadMessages;
  Future<int> notificationCount;

  ///
  /// Function for if user logout all preferences can be deleted
  ///
  _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  Future<void> fetchProfile(http.Client client) async {
    String url = baseApiURL + "method=get_profile&id=$userId" ;
    
    final response = await client.get(url, headers: headers);
    Map<String, dynamic> user = jsonDecode(response.body);

      setState(() {
        friendCount = user['friend_count'];
        eventCount = user['event_count'];
        email = user['email'];
        name = user['name'];
        country = user['country'];
        city = user['city'];
        gender = user['gender'];
        sexual = user['sexual_orientation'];
        status = user['marital_status'];
        age = user['age'];
        height = user['height'];
        hobbies = user['hobbies'];
        if(user['covid_flag'] > 0){
          covidPositive = true;
        }
        if(user['profile_pic'] != '') {
          photoProfile = baseUploadURL + user['profile_pic'];
        } else {
          photoProfile = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png';
        }
      });
  }

  Future<List<UserReview>> fetchClubReviews(http.Client client) async{
    String url = baseApiURL + "method=get_user_reviews&id=$userId" ;
    final response = await client.get(url, headers: headers);
    return compute(parseUserReviews, response.body);
  }

  Future<List<UserPhoto>> fetchClubPhotos(http.Client client) async{
    String url = baseApiURL + "method=get_user_photos&id=$userId" ;
    final response = await client.get(url, headers: headers);
    return compute(parsePhotos, response.body);
  }

  Future<List<Friend>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId" ;
    final response = await client.get(url, headers: headers);
      setState(() {
        // friendCount = 0;
      });
      List results = jsonDecode(response.body);
      for(Map result in results){
        int req_id = result['req_id'] as int;
        int req_status = result['req_status'] as int;
        if(req_id > 0 && req_status == 1){
          setState(() {
            // friendCount++;
          });
        }
      }
      return compute(parseClubFriends, response.body);
  }

  Future<List<ClubModel>> fetchVisitHistory(http.Client client) async{
    String url = baseApiURL + "method=get_visit_history&id=$userId" ;
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  updateCovidFlag() async {
    int flag = 0;
    if(covidPositive == true){
      flag = 1;
    }
    String url = baseApiURL + "method=change_covid_flag&id=$userId&covid_flag=$flag" ;
    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  unReadMessageNotification() async {
    if(mounted){
      setState(() {
        unReadMessages = ChatNotificationController().unReadMessageCount();
      });
      new Timer(Duration(seconds: 60), unReadMessageNotification);
    }

  }

  generalNotificationData() async {
    if(mounted){
      setState(() {
        notificationCount = GeneralNotificationController().notificationCount();
      });
      new Timer(Duration(seconds: 60), generalNotificationData);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile(http.Client());
    reviews = fetchClubReviews(http.Client());
    photos = fetchClubPhotos(http.Client());
    friendList = fetchFriends(http.Client());
    clubs = fetchVisitHistory(http.Client());
    unReadMessageNotification();
    generalNotificationData();
  }

  void refreshPhotosReviews(){
    setState(() {
      reviews = fetchClubReviews(http.Client());
      photos = fetchClubPhotos(http.Client());
    });
  }

  void refreshFriendList(){
    setState(() {
      friendList = fetchFriends(http.Client());
    });
  }

  void _showHideMenu(){
    setState(() {
      menuShown = !menuShown;
    });
  }
  
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Pics'),
    Tab(text: 'Reviews'),
    Tab(text: 'Friends'),
    Tab(text: 'Visits'),
  ];

  showAlertCovidDialog(BuildContext context, bool value) {  // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
         Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed:  () {
        setState(() {
          covidPositive = value;
          print(covidPositive);
          Navigator.of(context).pop();
          updateCovidFlag();
        });        
      },
    );  // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Confirm"),
      content: value ? Text("Are you sure you want to report a covid case? You need to turn off when you have passed covid infections.")
                : Text("Are you sure you have passed covid infections?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );  // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _editButton = new Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
            child: FlatButton(
              onPressed: () async {
                    await Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new UpdateProfilePage(
                              country: country,
                              city: city,
                              name: name,
                              photoProfile: photoProfile,
                              id: userId,
                              age: age,
                              sexual: sexual,
                              status: status,
                              gender: gender,
                              height: height,
                              hobbies: hobbies,
                            )));
                    fetchProfile(http.Client());
                  },
              color:  Colors.green,
              shape: new RoundedRectangleBorder(side: BorderSide(
                  color: Colors.black12,
                  width: 1,
                  style: BorderStyle.solid
                ), 
                borderRadius: new BorderRadius.circular(4.0)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Text("Edit Profile", style: TextStyle(color: Colors.white),),
                ],
              ),
            )        
          );
    
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        automaticallyImplyLeading: true,
          leading: new IconButton(
            icon: new Icon(Icons.chat, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(pageBuilder: (_, ___, ____) =>
                        new ChatSummaryPage(id : userId)
              ));
            },
          ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            name,
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
        elevation: 10.0,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatNotificationPage())
              );
            },
            child: Stack(
              children: [
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: 5),
                    child: ImageIcon(
                      AssetImage('assets/icon/chat_note.png'),
                      size: 22,
                    )
                ),
                FutureBuilder<int> (
                  future: unReadMessages,
                  builder: (context, snapshot) {
                    if(snapshot.data == null || snapshot.data == 0) {
                      return Container(height: 0.0);
                    } else {
                      return Positioned(
                        top: 10,
                        right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GeneralNotification())
              );
            },
            child: Stack(
              children: [
                Container(
                    alignment: Alignment.center,
                    child: new Icon(Icons.notifications, size: 28,),
                ),
                FutureBuilder<int> (
                  future: notificationCount,
                  builder: (context, snapshot) {
                    if(snapshot.data == null || snapshot.data == 0) {
                      return Container(height: 0.0);
                    } else {
                      return Positioned(
                        top: 10,
                        right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: _showHideMenu
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                width: 90.0,
                                height: 90.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  image: DecorationImage(
                                      image: NetworkImage(photoProfile),
                                      fit: BoxFit.cover
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 7.0,
                                        color: Colors.green
                                    )
                                  ]
                                )
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 55.0,
                                height: 20.0,
                                child: Text('$friendCount', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),)
                            ),
                            Container(
                                width: 55.0,
                                height: 25.0,
                                child: Text("Friends", textAlign: TextAlign.center,style: TextStyle(fontSize: 14.0),),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 60.0,
                                height: 20.0,
                                child: FutureBuilder<List<UserReview>>(
                                  future: reviews,
                                  builder: (context, snapshot) {                                              
                                    if (snapshot.hasError) print(snapshot.error);
                                    return snapshot.hasData
                                        ? Text("${snapshot.data.length}", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),) : Text("0", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),);
                                  },
                                )
                            ),
                            Container(
                                width: 60.0,
                                height: 25.0,
                                child: Text("Reviews", textAlign: TextAlign.center,style: TextStyle(fontSize: 14.0),),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 55.0,
                                height: 20.0,
                                child: Text("$eventCount", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                            ),
                            Container(
                                width: 55.0,
                                height: 25.0,
                                child: Text("Events", textAlign: TextAlign.center,style: TextStyle(fontSize: 14.0),),
                            ),
                          ],
                        ),
                      )                    
                    ]
                  ),                  
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                      Text((height == "")?"$age years":"$age years / $height", textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                      Text("$status / $sexual", textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                      Text("$city, $country", textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                      Text((hobbies == "")?"No hobbies":"$hobbies", textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text('I am COVID+', style: TextStyle(fontWeight: FontWeight.w700))
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 10.0),
                        child: Switch(
                          value: covidPositive,
                          onChanged: (value) {
                            showAlertCovidDialog(context, value);
                          },
                          activeTrackColor: Color(0xFFAD2829),
                          activeColor: Color(0xFFf8c301),
                        ), 
                      )
                    ]
                  )
                ),
                _editButton,
                DefaultTabController(
                  length: myTabs.length,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: Column(
                      children: <Widget>[
                        TabBar(
                          tabs: myTabs
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[
                              SingleChildScrollView(
                                child: FutureBuilder<List<UserPhoto>>(
                                  future: photos,
                                  builder: (context, snapshot) {                                              
                                    if (snapshot.hasError) print(snapshot.error);
                                    return snapshot.hasData
                                        ? ClubPhotoScreen(
                                          list: snapshot.data,
                                        ) : Center(child: CircularProgressIndicator());
                                  },
                                ) 
                              ),
                              SingleChildScrollView(
                                child: FutureBuilder<List<UserReview>>(
                                  future: reviews,
                                  builder: (context, snapshot) {                                              
                                    if (snapshot.hasError) print(snapshot.error);
                                    return snapshot.hasData
                                        ? ClubReviewScreen(
                                          list: snapshot.data,
                                          notifyParent: refreshPhotosReviews,
                                        ) : Center(child: CircularProgressIndicator());
                                  },
                                ) 
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: OutlineButton(
                                        onPressed: () async {
                                          await Navigator.of(context).push(PageRouteBuilder(
                                              pageBuilder: (_, __, ___) => new SearchUserPage()
                                          ));
                                          refreshFriendList();
                                        },
                                        borderSide: BorderSide(
                                          color: Colors.red[200], //Color of the border
                                          style: BorderStyle.solid, //Style of the border
                                          width: 0.8, //width of the border
                                        ),
                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                        padding: EdgeInsets.all(8.0),   
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                                          children: <Widget>[
                                            Icon(Icons.search_sharp, color: Colors.red,),
                                            Text("Find a Friend", style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                      child: Text("Pending Requests", style: new TextStyle(fontSize: 14, color: Colors.grey),textAlign: TextAlign.left,),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: FutureBuilder<List<Friend>>(
                                        future: friendList,
                                        builder: (context, snapshot) {                                              
                                          if (snapshot.hasError) print(snapshot.error);
                                          return snapshot.hasData
                                              ? MyRequestScreen(
                                                list: snapshot.data,
                                                notifyParent: refreshFriendList,
                                              ) : Center(child: CircularProgressIndicator());
                                        },
                                      )   
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                      child: Text("Friends", style: new TextStyle(fontSize: 14, color: Colors.grey),textAlign: TextAlign.left,),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: FutureBuilder<List<Friend>>(
                                        future: friendList,
                                        builder: (context, snapshot) {                                              
                                          if (snapshot.hasError) print(snapshot.error);
                                          return snapshot.hasData
                                              ? MyFriendScreen(
                                                list: snapshot.data,
                                                notifyParent: refreshFriendList,
                                              ) : Center(child: CircularProgressIndicator());
                                        },
                                      )   
                                    ),
                                  ]  
                                )
                              ), 
                              Container(
                                color: Colors.grey[300],
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 0.0),
                                    child: FutureBuilder<List<ClubModel>>(
                                      future: clubs,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) print(snapshot.error);

                                        return snapshot.hasData
                                            ? ClubVisitHistory(

                                              list: snapshot.data,
                                            ) : Center(child: CircularProgressIndicator());
                                      },
                                    )
                                  )
                                )
                              )
                            ]
                          )
                        )
                      ]
                    )
                  )
                )
              ]
            )
          ),
          Visibility (
            visible: menuShown,	
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)
                    ),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 7.0,
                          color: Colors.black38
                      )
                    ]
                  ),
                child: SingleChildScrollView(
                  child: Column(
                    /// Setting Category List
                    children: <Widget>[
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       top: 25.0, left: 85.0, right: 30.0),
                      //   child: Divider(
                      //     color: Colors.black12,
                      //     height: 2.0,
                      //   ),
                      // ),
                      // Category(
                      //   txt: "Subscription",
                      //   padding: 30.0,
                      //   image: "assets/icon/subscriptions.png",
                      //   tap: () {
                      //     _showHideMenu();
                      //     Navigator.of(context).push(PageRouteBuilder(
                      //         pageBuilder: (_, __, ___) => new SubscriptionScreen()
                      //     ));
                      //   },
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       top: 15.0, left: 85.0, right: 30.0),
                      //   child: Divider(
                      //     color: Colors.black12,
                      //     height: 2.0,
                      //   ),
                      // ),
                      // Category(
                      //   txt: "Transaction History",
                      //   padding: 30.0,
                      //   image: "assets/icon/subscriptions.png",
                      //   tap: () {
                      //     _showHideMenu();
                      //     // Navigator.of(context).push(PageRouteBuilder(
                      //     //     pageBuilder: (_, __, ___) => new TxnList(user_id: widget.user_id,)));
                      //   },
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: "Add Event",
                        padding: 30.0,
                        image: "assets/icon/add_event.png",
                        tap: () async{
                          _showHideMenu();
                          await Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new AddEventPage()));

                              fetchProfile(http.Client());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: "Manage Events",
                        padding: 30.0,
                        image: "assets/icon/favorites.png",
                        tap: () async{
                          _showHideMenu();
                          await Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new ManageEventsPage()
                          ));
                          fetchProfile(http.Client());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: "Search Users",
                        padding: 30.0,
                        image: "assets/icon/search_user.png",
                        tap: () {
                          _showHideMenu();
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new SearchUserPage()
                          ));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: "Privacy Settings",
                        padding: 30.0,
                        image: "assets/icon/setting.png",
                        tap: () {
                          _showHideMenu();
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new PrivacySettings()
                          ));
                        },
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      category(
                        txt: "My Coupons & Offers",
                        padding: 30.0,
                        image: "assets/icon/offer.png",
                        tap: () {
                          
                        },
                      ),*/
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: "Contact",
                        padding: 30.0,
                        image: "assets/icon/callcenter.png",
                        tap: () {
                          _showHideMenu();
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new CallCenterPage()
                          ));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        padding: 38.0,
                        txt: " Terms of use",
                        image: "assets/icon/aboutapp.png",
                        tap: () async {
                          await launch('https://www.tjaoapp.com/kopi-af-privacy-policy');
                          _showHideMenu();
                          // Navigator.of(context).push(PageRouteBuilder(
                          //     pageBuilder: (_, __, ___) => new AboutApp()
                          // ));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Category(
                        txt: " Logout",
                        padding: 30.0,
                        image: "assets/icon/logout.png",
                        tap: () {
                          _logout();
                          Navigator.of(context).pushReplacement(PageRouteBuilder(
                                      pageBuilder: (_, ___, ____) => new ChoseLogin()
                          ));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 85.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 20.0)),
                    ],
                  ),
                )
              ),
            ),
          ) 
        ]
      )
    );
  }
}

class ClubPhotoScreen extends StatelessWidget{
  final List<UserPhoto> list;
  ClubPhotoScreen({
    this.list
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        shrinkWrap: true, 
        physics: ScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: list.map<Widget>((photo) {
          return new InkWell(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => ViewImageScreen(imgUrl: baseUploadURL + photo.name,)
              ));
            },
            child: Image.network(
              baseUploadURL + photo.name,
              fit: BoxFit.cover
            ),
          );
        }).toList(),
      )
    );
  }
}

class ClubReviewScreen extends StatelessWidget{
  final List<UserReview> list;
  final Function() notifyParent;
  ClubReviewScreen({
    this.list, @required this.notifyParent
  });

  @override
  Widget build(BuildContext context) {
    List<int> text = [1,2,3,4,5];
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((rev) {
            return InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, ___, ____) =>
                        new ClubProfilePage(userId: rev.added_by, clubId : rev.bar_id, clubName: rev.bar_name, address: rev.bar_address, bannerImg: rev.bar_pic, description: rev.bar_description, upcoming: rev.bar_upcoming_events, offers: rev.bar_offers, news: rev.bar_news, max_allowance: rev.max_allowance, rating: rev.bar_rating, distance: rev.distance, visitors: rev.visitors, live_friends: rev.live_friends, phone_number: rev.phone_number, latitude: rev.latitude, longitude: rev.longitude, bar_timing: rev.bar_timing)
                  )
                );
                this.notifyParent();
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.black12,
                          width: double.infinity,
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topCenter,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image: NetworkImage(rev.bar_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + rev.bar_pic),
                                              fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        height: 25.0,
                                        child: Text(rev.bar_name, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ),                  
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              for ( var i in text )
                              Container(
                                margin: const EdgeInsets.only(left: 5.0),
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  //color: Colors.red[300],
                                  color: rev.rating >= i? Colors.black: Colors.black12,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                ),
                                child: FittedBox(
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10.0),
                                child: Text("${rev.rating}.0", style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                              ),
                            ]
                          ),                  
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(rev.review)
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(rev.posted_time, textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0, color: Colors.grey),),                                            
                              Container(
                                width: 20.0,
                                height: 20.0,
                                child: FittedBox(
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.black,
                                  ),
                                )
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              )
            );
          }).toList(),
      )
    );
  }
}

/// Component category class to set list
// ignore: must_be_immutable
class Category extends StatelessWidget {
  String txt, image;
  GestureTapCallback tap;
  double padding;

  Category({this.txt, this.image, this.tap, this.padding});

  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: padding),
                  child: Image.asset(
                    image,
                    height: 25.0,
                  ),
                ),
                Text(
                  txt,
                  style: _txtCategory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ClubVisitHistory extends StatelessWidget {
  int userId;
  ClubVisitHistory({this.userId, this.list});

  final List<ClubModel> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: list.length,
        itemBuilder: (context, i) {
          CardTypeConst cardType = list[i].cardType;

          return InkWell(
            onTap: () {
              
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: (cardType == CardTypeConst.standard)
                  ? ClubItem(club: list[i])
                  : cardType == CardTypeConst.tappable
                      ? ClubItem(club: list[i])
                      : ClubItem(club: list[i]),
            ),
          );
        });
  }
}

class ClubItem extends StatelessWidget {
  const ClubItem({Key key, @required this.club, this.shape})
      : assert(club != null),
        super(key: key);

  // This height will allow for all the Card's content to fit comfortably within the card.
  static const height = 360.0;
  final ClubModel club;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: Card(
                // This ensures that the Card's children are clipped correctly.
                clipBehavior: Clip.antiAlias,
                shape: shape,
                child: InkWell(
                  onTap: () {
                    gotoClubProfile(context, club, userId);
                  },
                  // Generally, material cards use onSurface with 12% opacity for the pressed state.
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  // Generally, material cards do not have a highlight overlay.
                  highlightColor: Colors.transparent,
                  child: ClubContent(club: club),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubContent extends StatelessWidget {
  const ClubContent({Key key, @required this.club})
      : assert(club != null),
        super(key: key);

  final ClubModel club;

  _getDirection() async { 
     var uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${club.latitude},${club.longitude}&mode=d");
      if (await canLaunch(uri.toString())) {
          await launch(uri.toString());
      } else {
          throw 'Could not launch ${uri.toString()}';
      }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline5.copyWith(color: Colors.white);
    final descriptionStyle = theme.textTheme.subtitle1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 184,
          child: Stack(
            children: [
              Positioned.fill(
                // In order to have the ink splash appear above the image, you
                // must use Ink.image. This allows the image to be painted as
                // part of the Material and display ink effects above it. Using
                // a standard Image will obscure the ink splash.
                child: Ink.image(
                  image: NetworkImage(baseUploadURL + club.bannerImg, scale: 1.0),
                  fit: BoxFit.fitWidth,
                  child: Container(),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    club.clubName,
                    style: titleStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: descriptionStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This array contains the three line description on each card
                // demo.
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    club.description,
                    style: descriptionStyle.copyWith(color: Colors.black54, fontSize: 14),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.location_pin, size: 18, color: Colors.black54,)
                      ),
                      TextSpan(
                        text: club.address,
                        style: descriptionStyle.copyWith(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                //Text(club.address),
              ],
            ),
          ),
        ),
        if (club.cardType == CardTypeConst.standard)
          // share, explore buttons
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                textColor: const Color(0xFFad2829),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('Share'),
              ),
              FlatButton(
                textColor: const Color(0xFFad2829),
                onPressed: () {
                  _getDirection();
                },
                child: const Text('Get Direction'),
              ),
            ],
          ),
      ],
    );
  }
}

class MyFriendScreen extends StatelessWidget{
  final List<Friend> list;
  final Function() notifyParent;
  MyFriendScreen({this.list, @required this.notifyParent});

  viewFriendProfile(int friendId, BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friendId)
    ));
  }

  respondFriendRequest(int id, int resp) async {
    String url = baseApiURL + "method=respond_friend_request&id=$id&resp=$resp";
    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((friend) {
          if(friend.req_id > 0 && friend.req_status == 1)
            return InkWell(
              onTap: () async {
                await viewFriendProfile(friend.friend_id, context);
                this.notifyParent();
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(friend.friend_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + friend.friend_pic),
                                      fit: BoxFit.cover,),
                                    borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                  )
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  height: 25.0,
                                  child: Text("${friend.friend_name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    OutlineButton(
                      onPressed: () async{
                        await respondFriendRequest(friend.req_id, -3);
                        this.notifyParent();
                      },
                      borderSide: BorderSide(
                        color: Colors.red[200], //Color of the border
                        style: BorderStyle.solid, //Style of the border
                        width: 0.8, //width of the border
                      ),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                      padding: EdgeInsets.all(0),  
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                        children: <Widget>[
                          Text("Unfriend", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                        ],
                      ),
                    ),
                  ]
                ),
              )                  
            );
          else
            return Container();
        }).toList(),
      )
    );
  }
}

class MyRequestScreen extends StatelessWidget{
  MyRequestScreen({this.list, @required this.notifyParent});
  final List<Friend> list;
  final Function() notifyParent;

  viewFriendProfile(int friendId, BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friendId)
    ));
  }

  respondFriendRequest(int id, int resp) async {
    String url = baseApiURL + "method=respond_friend_request&id=$id&resp=$resp" ;
    
    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((friend) {
          if(friend.req_id > 0 && friend.req_status < 1)
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await viewFriendProfile(friend.friend_id, context);
                        this.notifyParent();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: NetworkImage(friend.friend_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + friend.friend_pic),
                                        fit: BoxFit.cover,),
                                      borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                    )
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 25.0,
                                  child: Text("${friend.friend_name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                        builder: (context) {
                          if (friend.req_sent == 1) {
                            return OutlineButton(
                              onPressed: () async{
                                await respondFriendRequest(friend.req_id, -2);
                                this.notifyParent();
                              },
                              borderSide: BorderSide(
                                color: Colors.red[200], //Color of the border
                                style: BorderStyle.solid, //Style of the border
                                width: 0.8, //width of the border
                              ),
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  Text("Cancel Request", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                                ],
                              ),
                            );
                          } else if (friend.req_sent == 0) {
                            return OutlineButton(
                              onPressed: () async{
                                await respondFriendRequest(friend.req_id, 1);
                                this.notifyParent();
                              },
                              borderSide: BorderSide(
                                color: Colors.red[200], //Color of the border
                                style: BorderStyle.solid, //Style of the border
                                width: 0.8, //width of the border
                              ),
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                              padding: EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  Text("Accept", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                                ],
                              ),
                            );
                          } else return null;
                        }
                    ),
                  ]
              ),
            );
          else
            return Container();
        }).toList(),
      )
    );
  }
}