import 'package:flutter/material.dart';
import 'package:tjao/Screen/B1_Home/add_review_page.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'dart:io';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/club_review.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/user_photo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tjao/Screen/B4_Profile/view_image.dart';

// ignore: must_be_immutable
class ClubProfilePage extends StatefulWidget {
  int clubId, userId, max_allowance, rating, visitors, live_friends;
  String clubName, address, bannerImg, description, upcoming, offers, news, phone_number, bar_timing;
  double distance, latitude, longitude;

  ClubProfilePage({
    this.userId,
    this.clubId,
    this.clubName,
    this.address,
    this.bannerImg,
    this.description,
    this.upcoming,
    this.offers,
    this.news,
    this.max_allowance,
    this.rating,
    this.distance,
    this.visitors,
    this.live_friends,
    this.phone_number,
    this.latitude,
    this.longitude,
    this.bar_timing
  });
  _ClubProfilePageState createState() => _ClubProfilePageState();
}

class _ClubProfilePageState extends State<ClubProfilePage> {
  List<Asset> images = List<Asset>();
  File _image;
  Future<List<ClubReview>> reviews;
  Future<List<UserPhoto>> photos;
  Future<List<Friend>> friends;

  ScrollController _scrollController;
  bool fixedScroll;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Overview'),
    Tab(text: 'Photos'),
    Tab(text: 'Reviews'),
    Tab(text: 'Live Check-ins'),
  ];

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<ClubReview>> fetchClubReviews(http.Client client) async{
    String url = baseApiURL + "method=get_club_reviews&id=${widget.clubId}" ;
    final response = await client.get(url, headers: headers);
    return compute(parseClubReviews, response.body);
  }

  Future<List<UserPhoto>> fetchClubPhotos(http.Client client) async{
    String url = baseApiURL + "method=get_club_photos&id=${widget.clubId}" ;
    final response = await client.get(url, headers: headers);
    return compute(parsePhotos, response.body);
  }

  Future<List<Friend>> fetchLiveCheckins(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId&bar_id=${widget.clubId}" ;
    final response = await client.get(url, headers: headers);
    return compute(parseClubFriends, response.body);
  }

  Future<void> checkAndRequestCameraPermissions() async {
    bool perm = false;
    if (await Permission.camera.request().isGranted) {
      perm = true;
    }else{
      perm = false;
    }

    if(perm){
      loadAssets();
    }
  }

  void refreshFriendList(){
    setState(() {
      friends = fetchLiveCheckins(http.Client());
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#ad2829",
          actionBarTitle: "Select Photos",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {

    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      getFileList();
    });
  }

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  uploadImage() async {
    var request = http.MultipartRequest('POST', Uri.parse(baseApiURL));
    request.files.add(
        http.MultipartFile.fromBytes(
            'picture',
            _image.readAsBytesSync(),
            filename: _image.path.split("/").last
        )
    );
    request.fields['bar_id'] = '${widget.clubId}';
    request.fields['user_id'] = '$userId';
    final res = await request.send();
    final respStr = await res.stream.bytesToString();
  }

  void getFileList() async {
    for (int i = 0; i < images.length; i++) {
      var path2 = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      var file = await getImageFileFromAsset(path2);
      _image = file;
      await uploadImage();
    }
    setState(() {
      photos = fetchClubPhotos(http.Client());
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    reviews = fetchClubReviews(http.Client());
    photos = fetchClubPhotos(http.Client());
    friends = fetchLiveCheckins(http.Client());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(microseconds: 300),
      curve: Curves.ease,
    );

  }

  _makingPhoneCall() async {
    String url = 'tel:${widget.phone_number}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> text = [1,2,3,4,5];
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
            children: <Widget>[
              NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: double.infinity,
                                  height: 250,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(baseUploadURL + widget.bannerImg, scale: 0.5),
                                          fit: BoxFit.fitWidth
                                        ),
                                      )
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
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
                                                      color: widget.rating >= i? Colors.black: Colors.black12,
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
                                                  child: Text("${widget.rating}.0", style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),),
                                                ),
                                              ]
                                          )
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 10.0),
                                        child: Text("${widget.visitors} / ${widget.max_allowance}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w500),),
                                      )
                                    ]
                                ),
                              ),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: FutureBuilder<List<ClubReview>>(
                                          future: reviews,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) print(snapshot.error);
                                            return snapshot.hasData
                                                ? Text("${snapshot.data.length} REVIEWS", style: TextStyle(fontSize: 12.0),) : Text("0 REVIEWS", style: TextStyle(fontSize: 12.0),);
                                          },
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: Text("VISITING / ALLOWANCE", style: TextStyle(fontSize: 12.0),),
                                    ),
                                  ]
                              ),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: Text("${widget.live_friends} friends checked in", style: TextStyle(fontSize: 12.0),),
                                    ),
                                  ]
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Text(widget.clubName, style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.w600),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(widget.address, style: TextStyle(fontSize: 14.0, color: Colors.black45),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0, bottom: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context).size.width*0.8,
                                          child: RichText(
                                            text: TextSpan(
                                              text: "Open time - ",
                                              style: TextStyle(color: Colors.blueAccent[100], fontSize: 14, fontFamily: 'popins'),
                                              children: <TextSpan>[
                                                TextSpan(text: '${widget.bar_timing}', style: TextStyle(color: Colors.black26)),
                                              ],
                                            ),
                                          )
                                      ),
                                      IconButton(
                                        icon: new Icon(Icons.call, color: Colors.red[400]),
                                        highlightColor: Colors.pink,
                                        onPressed: () {
                                          _makingPhoneCall();
                                        },
                                      ),
                                    ]
                                ),
                              ),
                            ]
                        ),
                      ),
                    ];
                  },
                  body: DefaultTabController(
                      length: myTabs.length,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.80,
                          child: Column(
                              children: <Widget>[
                                TabBar(
                                    isScrollable: true,
                                    tabs: myTabs
                                ),
                                Expanded(
                                    child: TabBarView(
                                        children: <Widget>[
                                          Container(
                                              width: double.infinity,
                                              child: Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                                  child: SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(widget.description, style: TextStyle(height: 1.5,fontSize: 14.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 20,
                                                          ),
                                                          Text("UPCOMING EVENTS", style: TextStyle(letterSpacing: 3.0, fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 15,
                                                          ),
                                                          Text(widget.upcoming, style: TextStyle(height: 1.5,fontSize: 14.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 20,
                                                          ),
                                                          Text("OFFERS", style: TextStyle(letterSpacing: 3.0, fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 15,
                                                          ),
                                                          Text(widget.offers, style: TextStyle(height: 1.5,fontSize: 14.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 20,
                                                          ),
                                                          Text("NEWS", style: TextStyle(letterSpacing: 3.0, fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 15,
                                                          ),
                                                          Text(widget.news, style: TextStyle(height: 1.5,fontSize: 14.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 20,
                                                          ),
                                                          Text("ADDRESS", style: TextStyle(letterSpacing: 3.0, fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.black87),),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 15,
                                                          ),
                                                          Text(widget.address, style: TextStyle(height: 1.5, fontSize: 14.0, color: Colors.black87,)),
                                                          SizedBox(
                                                            width: double.infinity,
                                                            height: 20,
                                                          ),
                                                          FlatButton(
                                                            textColor: const Color(0xFFad2829),
                                                            onPressed: () async{
                                                              var uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&mode=d");
                                                              if (await canLaunch(uri.toString())) {
                                                                await launch(uri.toString());
                                                              } else {
                                                                throw 'Could not launch ${uri.toString()}';
                                                              }
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start, // Replace with a Row for horizontal icon + text
                                                              children: <Widget>[
                                                                Icon(new IconData(0xe142, fontFamily: 'MaterialIcons'), color: Colors.red[200],),
                                                                Text("  Get Directions", style: TextStyle(height: 1.5, fontSize: 14.0, color: Colors.red[400],)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  )
                                              )
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 10, top: 10),
                                                    width: 150.0,
                                                    child: OutlineButton(
                                                      onPressed: () {
                                                        checkAndRequestCameraPermissions();
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
                                                          Icon(Icons.camera, color: Colors.red[200],),
                                                          Text("Add Photos", style: TextStyle(color: Colors.red[200])),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(bottom: 5.0, top: 10.0),
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Container(
                                                        color: Colors.white,
                                                        width: double.infinity,
                                                        height: 60,
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Container(
                                                                margin: const EdgeInsets.only(left: 10, top: 10),
                                                                width: 130.0,
                                                                height: 40,
                                                                child: OutlineButton(
                                                                  onPressed: () async {
                                                                    await Navigator.of(context).push(PageRouteBuilder(
                                                                        pageBuilder: (_, __, ___) => new AddReviewPage(

                                                                            clubId: widget.clubId,
                                                                            clubName: widget.clubName
                                                                        )));
                                                                    // update review section here
                                                                    setState(() {
                                                                      reviews = fetchClubReviews(http.Client());
                                                                      photos = fetchClubPhotos(http.Client());
                                                                    });
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
                                                                      Icon(Icons.star, color: Colors.red[200],),
                                                                      Text("Add Review", style: TextStyle(color: Colors.red[200])),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ]
                                                        )
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(bottom: 0.0),
                                                        child: FutureBuilder<List<ClubReview>>(
                                                          future: reviews,
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) print(snapshot.error);
                                                            return snapshot.hasData
                                                                ? ClubReviewScreen(

                                                              list: snapshot.data,
                                                            ) : Center(child: CircularProgressIndicator());
                                                          },
                                                        )
                                                    )
                                                  ]
                                              ),
                                            ),
                                          ),
                                          Container(
                                              width: double.infinity,
                                              child: SingleChildScrollView(
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                                          child: Text("My friends", style: new TextStyle(fontSize: 14, color: Colors.grey),textAlign: TextAlign.left,),
                                                        ),
                                                        Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: FutureBuilder<List<Friend>>(
                                                              future: friends,
                                                              builder: (context, snapshot) {
                                                                if (snapshot.hasError) return Center(child: CircularProgressIndicator());
                                                                else if (snapshot.hasData && snapshot.data.length ==0)
                                                                  return Padding(
                                                                    padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                                                    child: Text(
                                                                      "There is no your friend in this club here now",
                                                                      style: new TextStyle(
                                                                          fontSize: 14,
                                                                          color: Colors.black
                                                                      ),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  );
                                                                return snapshot.hasData
                                                                    ? MyFriendScreen(
                                                                  list: snapshot.data,
                                                                  notifyParent: refreshFriendList,
                                                                ) : Center(child: CircularProgressIndicator());
                                                              },
                                                            )
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                                          child: Text("Club other members", style: new TextStyle(fontSize: 14, color: Colors.grey),textAlign: TextAlign.left,),
                                                        ),
                                                        Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: FutureBuilder<List<Friend>>(
                                                              future: friends,
                                                              builder: (context, snapshot) {
                                                                if (snapshot.hasError) return Center(child: CircularProgressIndicator());
                                                                else if (snapshot.hasData && snapshot.data.length == 0)
                                                                  return Padding(
                                                                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                                                      child: Text(
                                                                        "There is no any live-member in this club now",
                                                                        style: new TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.black
                                                                        ),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                  );
                                                                return snapshot.hasData
                                                                    ? MyRequestScreen(
                                                                  list: snapshot.data,
                                                                  notifyParent: refreshFriendList,
                                                                ) : Center(child: CircularProgressIndicator());
                                                              },
                                                            )
                                                        ),
                                                      ]
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
              ),
              Positioned(
                  top: 35,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 7,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back),
                    ),
                  )
              ),
            ]
        )
    );
  }
}

class ClubPhotoScreen extends StatelessWidget{
  final List<UserPhoto> list;
  ClubPhotoScreen({this.list});

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
                    pageBuilder: (_, __, ___) => ViewImageScreen(imgUrl: baseUploadURL + photo.name,)));
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

// ignore: must_be_immutable
class ClubReviewScreen extends StatelessWidget{
  ClubReviewScreen({this.userId, this.list});
  final List<ClubReview> list;
  int userId;


  @override
  Widget build(BuildContext context) {
    List<int> text = [1,2,3,4,5];
    return Padding(
        padding: EdgeInsets.only(bottom: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.map<Widget>((rev) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: rev.added_by,)));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
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
                                              image: NetworkImage(rev.added_by_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + rev.added_by_pic),
                                              fit: BoxFit.cover,),
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
                                        child: Text(rev.added_by_name, style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
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

                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )
    );
  }
}

class MyFriendScreen extends StatelessWidget{
  MyFriendScreen({this.list, @required this.notifyParent});
  final List<Friend> list;
  final Function() notifyParent;

  viewFriendProfile(int friendId, BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friendId,)
    ));
  }

  addFriend(int friendId) async {
    String url = baseApiURL + "method=add_friend&id=$userId&friend_id=$friendId" ;

    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  respondFriendRequest(int id, int resp) async {
    String url = baseApiURL + "method=respond_friend_request&id=$id&resp=$resp" ;

    final response = await http.Client().get(url);
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
                                          fit: BoxFit.cover,
                                        ),
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
                        Builder(
                            builder: (context) {
                              return OutlineButton(
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
                              );
                            }
                        ),
                      ]
                  ),
                )
            );
            else
              return Container(height: 0.0,);
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
        pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friendId,)
    ));
  }

  addFriend(int friendId) async {
    String url = baseApiURL + "method=add_friend&id=$userId&friend_id=$friendId" ;

    final response = await http.Client().get(url);
    print("response = ${response.body}");
  }

  respondFriendRequest(int id, int resp) async {
    String url = baseApiURL + "method=respond_friend_request&id=$id&resp=$resp" ;

    final response = await http.Client().get(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.map<Widget>((friend) {
            if(friend.req_status != 1)
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
                                            fit: BoxFit.cover,
                                          ),
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
                          Builder(
                              builder: (context) {
                                if (friend.req_id == 0) {
                                  return OutlineButton(
                                    onPressed: () async{
                                      await addFriend(friend.friend_id);
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
                                        Text("Add Friend", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                                      ],
                                    ),
                                  );
                                }
                                else if (friend.req_status == 1) {
                                  return OutlineButton(
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
                                  );
                                }
                                else if (friend.req_sent == 1) {
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
                                    padding: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Text("Cancel Request", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                                      ],
                                    ),
                                  );
                                }
                                else if (friend.req_sent == 0) {
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
                                }
                                else return null;
                              }
                          ),
                        ]
                    ),
                  )
              );
            else
              return Container(height: 0.0,);
          }).toList(),
        )
    );
  }
}