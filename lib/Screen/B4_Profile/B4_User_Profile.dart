
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:tjao/Screen/B1_Home/club_profile_page.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/club.dart';
import 'package:tjao/model/user_review.dart';
import 'package:tjao/model/user_photo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_board_page.dart';
import 'view_image.dart';

// ignore: must_be_immutable
class UserProfilePage extends StatefulWidget {
  int friendId;
  UserProfilePage({this.friendId});
  @override
  UserProfilePageState createState() => UserProfilePageState();
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
          pageBuilder: (_, ___, ____) =>
              new ClubProfilePage(clubId : club.club_id, clubName: club.clubName, address: club.address, bannerImg: club.bannerImg, description: club.description, upcoming: club.upcoming, offers: club.offers, news: club.news, max_allowance: club.max_allowance, rating: club.rating, distance: club.distance, visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number, latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing)
      )
  );
}

class UserProfilePageState extends State<UserProfilePage> {
  Future<List<UserReview>> reviews;
  Future<List<UserPhoto>> photos;
  Future<List<ClubModel>> clubs;
  int age = 0, req_id = 0, req_sent = 0, req_status = 0;
  String email = "", name = "", country = "", city = "", gender = "", sexual = "", status = "", height = "", hobbies = "";
  String photoProfile = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
  int friendCount = 0;
  int eventCount = 0;
  int anyoneChat = 1;
  
  Map<String, String> get headers => {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=UTF-8"
  };

  Future<void> fetchProfile(http.Client client) async {
    String url = baseApiURL + "method=get_profile&id=${widget.friendId}&user_id=$userId" ;
    
    final response = await client.get(url, headers: headers);
    Map<String, dynamic> user = jsonDecode(response.body);

    setState(() {
      anyoneChat = user['anyone_chat'];
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
      req_id = user['req_id'];
      req_sent = user['req_sent'];
      req_status = user['req_status'];
      if(user['profile_pic'] != ''){
        photoProfile = baseUploadURL + user['profile_pic'];
      }else{
        photoProfile = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png';
      }
    });
  }  

  Future<List<UserReview>> fetchClubReviews(http.Client client) async{
    String url = baseApiURL + "method=get_user_reviews&id=${widget.friendId}";
    final response = await client.get(url, headers: headers);
    return compute(parseUserReviews, response.body);
  }

  Future<List<UserPhoto>> fetchClubPhotos(http.Client client) async{
    String url = baseApiURL + "method=get_user_photos&id=${widget.friendId}";
    final response = await client.get(url, headers: headers);
    return compute(parsePhotos, response.body);
  }

  Future<List<ClubModel>> fetchVisitHistory(http.Client client) async{
    String url = baseApiURL + "method=get_visit_history&id=${widget.friendId}";
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  addFriend() async {
    String url = baseApiURL + "method=add_friend&id=$userId&friend_id=${widget.friendId}";
    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  respondFriendRequest(int resp) async {
    String url = baseApiURL + "method=respond_friend_request&id=$req_id&resp=$resp";
    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  @override
  void initState() {
    super.initState(); 
    fetchProfile(http.Client());
    reviews = fetchClubReviews(http.Client());
    photos = fetchClubPhotos(http.Client());
    clubs = fetchVisitHistory(http.Client());
  }
  
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Pics'),
    Tab(text: 'Reviews'),
    Tab(text: 'Visits'),
  ];

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
            name,
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
        elevation: 0.0,
        actions: (email != "" && anyoneChat > 0)?<Widget>[
          new IconButton(icon: new Icon(Icons.chat), onPressed: (){
            Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (_, ___, ____) =>
                    new ChatBoardPage(friedId: widget.friendId, id : userId, friendName: name)
            ));
          })
        ]:null,
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
                                width: 50.0,
                                height: 20.0,
                                child: Text("$friendCount", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                            ),
                            Container(
                                width: 50.0,
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
                                width: 45.0,
                                height: 20.0,
                                child: Text("$eventCount", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                            ),
                            Container(
                                width: 45.0,
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
                Builder(
                  builder: (context) {
                    if (req_id == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: FlatButton(
                          onPressed: () async {
                            await addFriend();
                            fetchProfile(http.Client());
                          },
                          color:  Colors.white,  
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
                              Text("Add Friend"),
                            ],
                          ),
                        )        
                      );
                    } else if (req_status == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: FlatButton(
                          onPressed: () async {
                            await respondFriendRequest(-3);
                            fetchProfile(http.Client());
                          },
                          color:  Colors.white,  
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
                              Text("Unfriend"),
                            ],
                          ),
                        )        
                      );
                    } else if (req_sent == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: FlatButton(
                          onPressed: () async {
                            await respondFriendRequest(-2);
                            fetchProfile(http.Client());
                          },
                          color:  Colors.white,  
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
                              Text("Cancel Request"),
                            ],
                          ),
                        )        
                      );
                    } else if (req_sent == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: FlatButton(
                          onPressed: () async {
                            await respondFriendRequest(1);
                            fetchProfile(http.Client());
                          },
                          color:  Colors.white,  
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
                              Text("Accept"),
                            ],
                          ),
                        )        
                      );
                    } else return null;
                  }
                ),
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
                                        ) : Center(child: CircularProgressIndicator());
                                  },
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
        ]
      )
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

class ClubPhotoScreen extends StatelessWidget{
  ClubPhotoScreen({this.list});
  final List<UserPhoto> list;

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
  ClubReviewScreen({this.list});
  final List<UserReview> list;

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
                      ));
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


