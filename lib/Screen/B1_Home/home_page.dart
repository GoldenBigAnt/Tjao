import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:icon_animator/icon_animator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tjao/Screen/B1_Home/notification_data.dart';
import 'package:tjao/Screen/B1_Home/timeline_comment_page.dart';
import 'package:tjao/Screen/B1_Home/timeline_like_page.dart';
import 'package:tjao/Screen/B1_Home/timeline_tag_page.dart';
import 'package:tjao/Screen/B4_Profile/B4_Profile.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/Screen/B4_Profile/chat_notification_page.dart';
import 'package:tjao/controller/chat_notification_controller.dart';
import 'package:tjao/controller/general_notification_controller.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/timeline.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Img;
import 'package:tjao/model/timeline_comment.dart';
import 'package:tjao/model/timeline_like.dart';
import 'package:tjao/model/timeline_tag.dart';

import 'club_profile_page.dart';

class HomePage extends StatefulWidget {
  final int selectedTimelineId;
  HomePage({Key key, this.selectedTimelineId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Timeline>> publicData;
  Future<List<Timeline>> privateData;
  Future<List<Timeline>> selectedTimeline;
  int selectedTimelineId = 0;
  List<bool> _isPublicLikeAnimationIcon = [];
  List<bool> _isPrivateLikeAnimationIcon = [];
  bool _isSelectedLikeAnimationIcon = false;
  Future<List<Friend>> friends;
  File _image;
  String visibility = "Public", _imageUrl = '', _imageName = "", postType = "Public";
  bool _isPost = false, _isTextPost = false, _isTag = false;
  TextEditingController _descriptionController = new TextEditingController(text: "");
  Future<int> unReadMessageCount;
  Future<int>  notificationCount;
  String tagSearch = '';
  int friendId = 0, timeline_Id = 0;
  AutoScrollController controller;
  List<TimelineTag> selectedTagList = [];

  Future<List<Timeline>> fetchPublicTimeline(http.Client client) async {
    _isPublicLikeAnimationIcon.clear();
    String url = baseApiURL + "method=get_timeline&type=Public&id=$userId";
    final response = await client.get(url, headers: headers);
    for(var i = 0; i < parseTimeline(response.body).length; i++) {
      _isPublicLikeAnimationIcon.add(false);
    }
    return compute(parseTimeline, response.body);
  }

  Future<List<Timeline>> fetchPrivateTimeline(http.Client client) async {
    _isPrivateLikeAnimationIcon.clear();
    String url = baseApiURL + "method=get_timeline&type=Private&id=$userId";
    final response = await client.get(url, headers: headers);
    for(var i = 0; i < parseTimeline(response.body).length; i++) {
      setState(() {
        _isPrivateLikeAnimationIcon.add(false);
      });

    }
    return compute(parseTimeline, response.body);
  }

  Future<List<Timeline>> fetchSelectedTimeline() async {
    String url = baseApiURL + "method=get_one_timeline&timeline_id=${widget.selectedTimelineId}";
    final response = await http.get(url, headers: headers);
    return compute(parseTimeline, response.body);
  }

  loadingTimelineData() async {
    if(mounted){
      setState(() {
        publicData = fetchPublicTimeline(http.Client());
        privateData = fetchPrivateTimeline(http.Client());
      });
      new Timer(Duration(seconds: 60), loadingTimelineData);
    }
  }

  void gotoClubProfile(BuildContext context, Timeline club) async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            ClubProfilePage(
                clubId : club.userLiveBarId, clubName: club.clubName,
                address: club.address, bannerImg: club.profileImg, description: club.description,
                upcoming: club.upcoming, offers: club.offers, news: club.news,
                max_allowance: club.max_allowance, rating: club.rating, distance: club.distance,
                visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number,
                latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing
            )
        )
    );
  }

  Future uploadImage() async {
    var request = http.MultipartRequest('POST', Uri.parse(baseParseURL));
    request.files.add(
        http.MultipartFile.fromBytes(
            'picture',
            _image.readAsBytesSync(),
            filename: "timeline_" + _image.path.split("/").last
        )
    );
    final res = await request.send();
    final respStr = await res.stream.bytesToString();

    if(res.statusCode == 200){
      setState(() {
        _imageName = respStr;
        _imageUrl = baseUploadURL + respStr;
        _isPost = true;
      });
    }
  }

  Future getImage(int from) async{
    // ignore: deprecated_member_use
    var imageFile = await ImagePicker.pickImage(source: from == 0 ? ImageSource.camera : ImageSource.gallery);

    final tempDir =await getTemporaryDirectory();
    final path = tempDir.path;

    int rand= new Random().nextInt(100000);

    Img.Image image= Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 500);

    var compressImg= new File("$path/timeline_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));
    _image = compressImg;
    await uploadImage();
  }

  imagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width*0.8,
            padding: EdgeInsets.all(25),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.camera_alt, size: 50,),
                          onTap: (){
                            Navigator.pop(context);
                            getImage(0);
                          },
                        ),
                        Text('Take a Photo', style: TextStyle(color: Colors.black),)
                      ],
                    ),
                    SizedBox(width: 50,),
                    Column(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.folder, size: 50,),
                          onTap: (){
                            Navigator.pop(context);
                            getImage(1);
                          },
                        ),
                        Text('Browse Images', style: TextStyle(color: Colors.black),)
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkAndRequestCameraPermissions() async {
    bool perm = false;
    if (await Permission.camera.request().isGranted) {
      perm = true;
    }else{
      perm = false;
    }

    if(perm){
    }
  }

  addTimeline() async {
    String description = _descriptionController.text.trim();
    String url = baseApiURL + "method=add_timeline&id=$userId&photo=$_imageName&description=$description&visibility=$postType";
    await http.Client().get(url);
    await loadingTimelineData();
    setState(() {
      _descriptionController.clear();
      _isPost = false;
    });
  }

  addTimelineLike(int friendId, int timelineId) async {
    String url = baseApiURL + "method=add_timeline_like&user_id=$friendId&friend_id=$userId&timeline_id=$timelineId&status=1";
    await http.Client().get(url);
    await loadingTimelineData();
  }

  isLikeActive(int type, int index) {
    setState(() {
      if(type == 1) {
        _isPublicLikeAnimationIcon[index] = true;
      } else {
        _isPrivateLikeAnimationIcon[index] = true;
      }
    });
    new Timer(Duration(seconds: 3), () {
      setState(() {
        if(type == 1) {
          _isPublicLikeAnimationIcon[index] = false;
        } else {
          _isPrivateLikeAnimationIcon[index] = false;
        }
      });
    });
  }

  isSelectedLikeActive() {
    setState(() {
      _isSelectedLikeAnimationIcon = true;
    });
    new Timer(Duration(seconds: 3), () {
      setState(() {
        _isSelectedLikeAnimationIcon = false;
      });
    });
  }


  goToTimelineCommentPage(int friendId, int timelineId, List<TimelineComment> commentList) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            TimelineCommentPage(friendId: friendId, timelineId: timelineId, commentList: commentList,))
    );
  }

  goToTimelineLikePage(List<TimelineLike> likeList) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            TimelineLikePage(likeList: likeList,))
    );
  }

  goToTimelineTagPage(int timelineId, List<TimelineTag> tagList) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            TimelineTagPage(timelineId: timelineId, tagList: tagList,))
    );
  }

  goToUserProfilePage(int friendId) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage(friendId: friendId,))
    );
  }

  deleteTimelineDialog(BuildContext context, int timelineId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Confirm delete',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure want to delete?', style: TextStyle(fontSize: 16, color: Colors.black),),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          child: RaisedButton(
                            child: Text("No", style: TextStyle(fontSize: 20, color: Colors.black),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.black)
                            ),
                            color: Colors.white,
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                        SizedBox(width: 30,),
                        Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          child: RaisedButton(
                            child: Text("Yes", style: TextStyle(fontSize: 20, color: Colors.white),),
                            onPressed: () {
                              deleteTimeline(timelineId);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.red)
                            ),
                            color: Colors.red[900],
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  deleteTimeline(int timelineId) async {
    String url = baseApiURL + "method=delete_timeline&timeline_id=$timelineId";
    await http.get(url);
    await loadingTimelineData();
    Navigator.of(context).pop();
  }

  Future<List<Friend>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubFriends, response.body);
  }

  addTimelineTag(int friendId) async {
    String url = baseApiURL + "method=add_timeline_tag&user_id=$friendId&friend_id=$userId&timeline_id=$timeline_Id";
    await http.get(url);
    setState(() {
      tagSearch = '';
      timeline_Id = 0;
    });
    await loadingTimelineData();
  }

  unReadMessageNotification() async {
    if(mounted){
      setState(() {
        unReadMessageCount = ChatNotificationController().unReadMessageCount();
      });
    }
    new Timer(Duration(seconds: 30), unReadMessageNotification);
  }

  generalNotificationData() async {
    if(mounted) {
      setState(() {
        notificationCount = GeneralNotificationController().notificationCount();
      });
    }
    new Timer(Duration(seconds: 30), generalNotificationData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingTimelineData();
    selectedTimelineId = widget.selectedTimelineId;
    if(selectedTimelineId > 0) {
      selectedTimeline = fetchSelectedTimeline();
    }
    unReadMessageNotification();
    generalNotificationData();
    friends = fetchFriends(http.Client());
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
    ));
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  selectedTimelineId == 0 ? Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.add, size: 28,),
                                      onPressed: () {
                                        setState(() {
                                          _isTextPost = true;
                                          _isPost = true;
                                        });
                                      },
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.camera_alt, size: 28,),
                                        onPressed: () {
                                          _isTextPost = false;
                                          imagePickerDialog(context);
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => ChatNotificationPage())
                                                  );
                                              },
                                              icon: ImageIcon(
                                                AssetImage('assets/icon/chat_note.png'),
                                                size: 24,
                                              )
                                            )
                                        ),
                                        FutureBuilder<int> (
                                          future: unReadMessageCount,
                                          builder: (context, snapshot) {
                                            if(snapshot.data == null || snapshot.data == 0) {
                                              return Container(height: 0.0);
                                            } else {
                                              return Positioned(
                                                top: 7,
                                                right: 5,
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
                                    Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: IconButton(
                                              icon: new Icon(Icons.notifications, size: 28,),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => GeneralNotification())
                                                );
                                              }
                                          ),
                                        ),
                                        FutureBuilder<int> (
                                          future: notificationCount,
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null || snapshot.data == 0) {
                                              return Container(height: 0.0);
                                            } else {
                                              return Positioned(
                                                top: 8,
                                                right: 7,
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
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                  width: width*0.5,
                                  child: RaisedButton(
                                    child: Text("Public"),
                                    onPressed: () {
                                      setState(() {
                                        visibility = "Public";
                                        selectedTimelineId = 0;
                                      });
                                    },
                                    color: visibility == "Public" ? Colors.blue[900] : Colors.black12,
                                    textColor: visibility == "Public" ? Colors.white : Colors.blue[900],
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    splashColor: Colors.white,
                                  )
                              ),
                              Container(
                                  width: width*0.5,
                                  child: RaisedButton(
                                    child: Text("Private"),
                                    onPressed: () {
                                      setState(() {
                                        visibility = "Private";
                                        selectedTimelineId = 0;
                                      });
                                    },
                                    color: visibility == "Private" ? Colors.blue[900] : Colors.black12,
                                    textColor: visibility == "Private" ? Colors.white : Colors.blue[900],
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    splashColor: Colors.white,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GeneralNotification()));
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: width*0.7,
                          child: Text(
                            'Timeline',
                            style: TextStyle(
                              fontFamily: "Popins",
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  selectedTimelineId == 0 ?  Expanded(
                      child: FutureBuilder<List<Timeline>>(
                        future: visibility == "Public" ? publicData : privateData,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData ? ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              Timeline t = snapshot.data[index];
                              return Container(
                                width: width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: width,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(
                                                  t.user_name,
                                                  style: TextStyle(fontSize: 11, color: Colors.black),
                                                ),
                                                SizedBox(height: 5,),
                                                InkWell(
                                                  onTap: () {
                                                    if(t.user_id == userId) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => ProfilePage())
                                                      );
                                                    }else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => UserProfilePage(friendId: t.user_id, ))
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                      width: 70.0,
                                                      height: 70.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                              t.user_pic != '' ? baseUploadURL + t.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 9.0,
                                                                color: Colors.red[900]
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                          t.userLiveBarId > 0 ? Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          gotoClubProfile(context, t);
                                                        },
                                                        child: Image.network(
                                                          baseUploadURL + t.profileImg,
                                                          height: 50,
                                                          width: 70,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                      Expanded(
                                                        child: Text(t.clubName , style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                t.photo != '' ? Container(
                                                  child: Text(
                                                    t.des,
                                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ) : Container(height: 0.0,)
                                              ],
                                            ),
                                          )
                                              : t.photo != '' ? Expanded(
                                            child: Text(
                                              t.des,
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                              textAlign: TextAlign.start,
                                            ),
                                          ) : Container()

                                        ],
                                      ),
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        GestureDetector(
                                          onDoubleTap: () {
                                            if(t.like_status == 0) {
                                              setState(() {
                                                t.like_status = 1;
                                                t.active_likes = t.active_likes + 1;
                                              });
                                              addTimelineLike(t.user_id, t.id);
                                              if(visibility == 'Public') {
                                                isLikeActive(1, index);
                                              } else {
                                                isLikeActive(2, index);
                                              }

                                            }
                                            // else {
                                            //   setState(() {
                                            //     t.like_status = 0;
                                            //     t.active_likes = t.active_likes - 1;
                                            //   });
                                            // }
                                          },
                                          child: t.photo != '' ? Container(
                                            width: width,
                                            child: Image.network(
                                                baseUploadURL + t.photo,
                                                fit: BoxFit.fitWidth,
                                                loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null ?
                                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                          : null,
                                                    ),
                                                  );
                                                }
                                            ),
                                          ) : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                                            width: width,
                                            color: Colors.black12,
                                            child: Text(
                                              t.des,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ((visibility == "Public" ? _isPublicLikeAnimationIcon.length : _isPrivateLikeAnimationIcon.length) == snapshot.data.length && (visibility == "Public" ? _isPublicLikeAnimationIcon[index] : _isPrivateLikeAnimationIcon[index])) ? IconAnimator(
                                          icon: Icons.favorite,
                                          finish: SizedBox.shrink(),
                                          loop: 1,
                                          children: [
                                            AnimationFrame(size: 50, color: Colors.pink[600], duration: 100),
                                            AnimationFrame(size: 70, color: Colors.pink[500], duration: 50),
                                            AnimationFrame(size: 80, color: Colors.pink[600], duration: 100),
                                            AnimationFrame(size: 100, color: Colors.pink[700], duration: 500),
                                            AnimationFrame(size: 80, color: Colors.pink[600], duration: 50),
                                          ],
                                        ) : Container(height: 0.0,)
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if(t.like_status == 0) {
                                                      setState(() {
                                                        t.like_status = 1;
                                                        t.active_likes = t.active_likes + 1;
                                                      });
                                                      addTimelineLike(t.user_id, t.id);
                                                      if(visibility == 'Public') {
                                                        isLikeActive(1, index);
                                                      } else {
                                                        isLikeActive(2, index);
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                    t.like_status == 1 ? Icons.favorite : Icons.favorite_border,
                                                    size: 32,
                                                    color: t.like_status == 1 ? Colors.red[800] : Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                t.active_likes != 0 ? InkWell(
                                                  onTap: () {
                                                    goToTimelineLikePage(t.like_list);
                                                  },
                                                  child: Text(t.active_likes.toString(), style: TextStyle(fontSize: 14, color: Colors.black),),
                                                ) : Container(height: 0.0),
                                                SizedBox(width: 15,),
                                                InkWell(
                                                    onTap: () {
                                                      goToTimelineCommentPage(t.user_id, t.id, t.comment_list);
                                                    },
                                                    child: Icon(Icons.chat_sharp, color: t.comment != "" ? Colors.blue[900] : Colors.black, size: 30,)
                                                ),
                                                SizedBox(width: 5,),
                                                t.total_comments != 0 ? Text(t.total_comments.toString(), style: TextStyle(fontSize: 14, color: Colors.black),) : Container(height: 0.0,),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isTag = true;
                                                      friendId = t.user_id;
                                                      timeline_Id = t.id;
                                                      selectedTagList = t.tag_list;
                                                    });
                                                  },
                                                  child: Image.asset('assets/icon/user_group.png', height: 32, ),
                                                ),
                                                SizedBox(width: 5,),
                                                t.user_id  == userId ? InkWell(
                                                  onTap: () {
                                                    deleteTimelineDialog(context, t.id);
                                                  },
                                                  child: Icon(Icons.delete, size: 30,),
                                                ) : Container(height: 0.0,),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    t.comment_list.length > 0 && t.comment_list.length == 1 ?
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: t.comment_list[0].user_name,
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                              ),
                                              TextSpan(
                                                  text: '  ' + t.comment_list[0].comment,
                                                  style: TextStyle(color: Colors.black)
                                              )
                                            ]
                                        ),
                                      ),
                                    ) : t.comment_list.length > 1 ?
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: t.comment_list[0].user_name,
                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                  ),
                                                  TextSpan(
                                                      text: '  ' + t.comment_list[0].comment,
                                                      style: TextStyle(color: Colors.black)
                                                  )
                                                ]
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: t.comment_list[1].user_name,
                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                  ),
                                                  TextSpan(
                                                      text: '  ' + t.comment_list[1].comment,
                                                      style: TextStyle(color: Colors.black)
                                                  )
                                                ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) : Container(height: 0.0,),

                                    Divider(height: 2, color: Colors.black,),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              );
                            },
                          ) : Center(child: CircularProgressIndicator());
                        },
                      )
                  )
                  : Expanded(
                      child: FutureBuilder<List<Timeline>>(
                        future: selectedTimeline,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData ? ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              Timeline t = snapshot.data[index];
                              return Container(
                                width: width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: width,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(
                                                  t.user_name,
                                                  style: TextStyle(fontSize: 11, color: Colors.black),
                                                ),
                                                SizedBox(height: 5,),
                                                InkWell(
                                                  onTap: () {
                                                    if(t.user_id == userId) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => ProfilePage())
                                                      );
                                                    }else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => UserProfilePage(friendId: t.user_id, ))
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                      width: 70.0,
                                                      height: 70.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey,
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                              t.user_pic != '' ? baseUploadURL + t.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 9.0,
                                                                color: Colors.red[900]
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                          t.userLiveBarId > 0 ? Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          gotoClubProfile(context, t);
                                                        },
                                                        child: Image.network(
                                                          baseUploadURL + t.profileImg,
                                                          height: 50,
                                                          width: 70,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                      Expanded(
                                                        child: Text(t.clubName , style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                t.photo != '' ? Container(
                                                  child: Text(
                                                    t.des,
                                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ) : Container(height: 0.0,)
                                              ],
                                            ),
                                          )
                                              : t.photo != '' ? Expanded(
                                            child: Text(
                                              t.des,
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                              textAlign: TextAlign.start,
                                            ),
                                          ) : Container()

                                        ],
                                      ),
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        GestureDetector(
                                          onDoubleTap: () {
                                            if(t.like_status == 0) {
                                              setState(() {
                                                t.like_status = 1;
                                                t.active_likes = t.active_likes + 1;
                                              });
                                              addTimelineLike(t.user_id, t.id);
                                              isSelectedLikeActive();

                                            }
                                          },
                                          child: t.photo != '' ? Container(
                                            width: width,
                                            child: Image.network(
                                                baseUploadURL + t.photo,
                                                fit: BoxFit.fitWidth,
                                                loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null ?
                                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                          : null,
                                                    ),
                                                  );
                                                }
                                            ),
                                          ) : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                                            width: width,
                                            color: Colors.black12,
                                            child: Text(
                                              t.des,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        _isSelectedLikeAnimationIcon ? IconAnimator(
                                          icon: Icons.favorite,
                                          finish: SizedBox.shrink(),
                                          loop: 1,
                                          children: [
                                            AnimationFrame(size: 50, color: Colors.pink[600], duration: 100),
                                            AnimationFrame(size: 70, color: Colors.pink[500], duration: 50),
                                            AnimationFrame(size: 80, color: Colors.pink[600], duration: 100),
                                            AnimationFrame(size: 100, color: Colors.pink[700], duration: 500),
                                            AnimationFrame(size: 80, color: Colors.pink[600], duration: 50),
                                          ],
                                        ) : Container(height: 0.0,)
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if(t.like_status == 0) {
                                                      setState(() {
                                                        t.like_status = 1;
                                                        t.active_likes = t.active_likes + 1;
                                                      });
                                                      addTimelineLike(t.user_id, t.id);
                                                      isSelectedLikeActive();
                                                    }
                                                  },
                                                  child: Icon(
                                                    t.like_status == 1 ? Icons.favorite : Icons.favorite_border,
                                                    size: 32,
                                                    color: t.like_status == 1 ? Colors.red[800] : Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                t.active_likes != 0 ? InkWell(
                                                  onTap: () {
                                                    goToTimelineLikePage(t.like_list);
                                                  },
                                                  child: Text(t.active_likes.toString(), style: TextStyle(fontSize: 14, color: Colors.black),),
                                                ) : Container(height: 0.0),
                                                SizedBox(width: 15,),
                                                InkWell(
                                                    onTap: () {
                                                      goToTimelineCommentPage(t.user_id, t.id, t.comment_list);
                                                    },
                                                    child: Icon(Icons.chat_sharp, color: t.comment != "" ? Colors.blue[900] : Colors.black, size: 30,)
                                                ),
                                                SizedBox(width: 5,),
                                                t.total_comments != 0 ? Text(t.total_comments.toString(), style: TextStyle(fontSize: 14, color: Colors.black),) : Container(height: 0.0,),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isTag = true;
                                                      friendId = t.user_id;
                                                      timeline_Id = t.id;
                                                      selectedTagList = t.tag_list;
                                                    });
                                                  },
                                                  child: Image.asset('assets/icon/user_group.png', height: 32, ),
                                                ),
                                                SizedBox(width: 5,),
                                                t.user_id  == userId ? InkWell(
                                                  onTap: () {
                                                    deleteTimelineDialog(context, t.id);
                                                  },
                                                  child: Icon(Icons.delete, size: 30,),
                                                ) : Container(height: 0.0,),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    t.comment_list.length > 0 && t.comment_list.length == 1 ?
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: t.comment_list[0].user_name,
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                              ),
                                              TextSpan(
                                                  text: '  ' + t.comment_list[0].comment,
                                                  style: TextStyle(color: Colors.black)
                                              )
                                            ]
                                        ),
                                      ),
                                    ) : t.comment_list.length > 1 ?
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: t.comment_list[0].user_name,
                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                  ),
                                                  TextSpan(
                                                      text: '  ' + t.comment_list[0].comment,
                                                      style: TextStyle(color: Colors.black)
                                                  )
                                                ]
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: t.comment_list[1].user_name,
                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                  ),
                                                  TextSpan(
                                                      text: '  ' + t.comment_list[1].comment,
                                                      style: TextStyle(color: Colors.black)
                                                  )
                                                ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) : Container(height: 0.0,),

                                    Divider(height: 2, color: Colors.black,),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              );
                            },
                          ) : Center(child: CircularProgressIndicator());

                        },
                      )
                  ),
                  // new Container(
                  //   padding: EdgeInsets.all(10),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Container(
                  //         child: Row(
                  //           children: [
                  //             Container(
                  //               child: Column(
                  //                 children: [
                  //                   Text(
                  //                     'Cindy Lane',
                  //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //                   ),
                  //                   Image.asset('assets/image/model.png', width: 120, fit: BoxFit.fill,),
                  //                 ],
                  //               ),
                  //             ),
                  //             SizedBox(width: 10,),
                  //             GestureDetector(
                  //               onTap: () {
                  //                 Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(builder: (context) => ClubMainPage())
                  //                 );
                  //               },
                  //               child: Container(
                  //                 child: Column(
                  //                   children: [
                  //                     Image.asset('assets/icon/tjao_club.png', width: 70, fit: BoxFit.fill,),
                  //                     Text(
                  //                       'Tjao Club',
                  //                       style: TextStyle(fontSize: 16,),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 130,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Container(
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/icon/chat_letter.png', height: 35, ),
                  //                   Text('3401', style: TextStyle(fontSize: 12, color: Colors.black),),
                  //                 ],
                  //               ),
                  //             ),
                  //             Container(
                  //               child: Column(
                  //                 children: [
                  //                   Icon(Icons.favorite, size: 35,),
                  //                   Text('3401', style: TextStyle(fontSize: 12, color: Colors.black),),
                  //                 ],
                  //               ),
                  //             ),
                  //             Container(
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/icon/inbox.png', height: 32, ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),

              Visibility(
                visible: _isPost,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.maxFinite,
                    height: height * 0.82,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          _isTextPost ? Container(height: 0.0,)
                              : Container(
                            padding: EdgeInsets.all(10.0),
                            height: 300,
                            width: width,
                            child: Image.network(
                              _imageUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Post Type",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Radio(
                                    value: "Public",
                                    groupValue: postType,
                                    onChanged: (val) {
                                      setState(() {
                                        postType = val;
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13.0),
                                    child: Text(
                                      'Public',
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                  Radio(
                                    value: "Private",
                                    groupValue: postType,
                                    onChanged: (val) {
                                      setState(() {
                                        postType = val;
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13.0),
                                    child: Text(
                                      'Friends only',
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  border: const OutlineInputBorder(),
                                  hintText: 'Write your description here',
                                  labelText: 'Description',
                                  labelStyle: new TextStyle(color: Colors.black, fontSize: 16),
                                ),
                                maxLines: 3
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ButtonTheme(
                                minWidth: double.infinity,
                                height: 45.0,
                                buttonColor: Colors.green[900],
                                child: RaisedButton(
                                  onPressed: () {
                                    addTimeline();
                                  },
                                  child: Text("Add Timeline", style: TextStyle(color: Colors.white),),
                                ),
                              )
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ButtonTheme(
                                minWidth: double.infinity,
                                height: 45.0,
                                buttonColor: Color(0xFFAD2829),
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPost = false;
                                      _isTextPost = false;
                                    });
                                  },
                                  child: Text("Discard", style: TextStyle(color: Colors.white),),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: _isTag,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: double.maxFinite,
                      height: height*0.9,
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
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
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(8.0),
                                    prefixIcon: Icon(Icons.search),
                                    labelText: "Search for people...",
                                    labelStyle: new TextStyle(color: Colors.grey, fontSize: 14.0),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFeae3e3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      borderSide: BorderSide(color: Color(0xFFeae3e3)),
                                    ),
                                  ),
                                  onChanged: (text){
                                    setState(() {
                                      tagSearch = text;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder(
                                  future: friends,
                                  builder: (context, snapshot) {
                                    return tagSearch.length > 1 ? ListView.builder(
                                      itemCount: snapshot.data.length, itemBuilder: (context, index) {
                                        Friend friend = snapshot.data[index];
                                        return ((friend.anyone_search > 0) && (friend.friend_name.toLowerCase().startsWith(tagSearch.toLowerCase()))) ?
                                        ListTile(
                                          onTap: () {
                                            setState(() {
                                              _isTag = false;
                                            });

                                            addTimelineTag(friend.friend_id);
                                            showToast(friend.friend_name, Colors.black87);
                                          },
                                          leading: Container(
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
                                          title: Text("${friend.friend_name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friend.friend_id)
                                              ));
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 35,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.green[700]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0) //                 <--- border radius here
                                                ),
                                              ),
                                              child: Text('View Profile', style: TextStyle(color: Colors.green[700]),),
                                            ),
                                          ),
                                        ) : Container(height: 0.0,);
                                      },
                                    ) : ListView.builder(
                                      itemCount: selectedTagList.length,
                                      itemBuilder: (context, index) {
                                        int i = selectedTagList.length - index - 1;
                                        TimelineTag t = selectedTagList[i];
                                        return new Container(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(color: Colors.black26, width: 0.5))
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              goToUserProfilePage(t.user_id);
                                            },
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black12,
                                                image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(t.friend_pic != '' ? baseUploadURL + t.friend_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                                                ),
                                              ),
                                            ),
                                            title: RichText(
                                              text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: t.user_name,
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                    ),
                                                    TextSpan(
                                                      text: '  tagged  ',
                                                      style: TextStyle(color: Colors.black, )
                                                    ),
                                                    TextSpan(
                                                        text: t.friend_name,
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                                                    )
                                                  ]
                                              ),
                                            ),
                                            trailing: Container(
                                              width: 80,
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                  t.timestamp
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                          Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    tagSearch = '';
                                    _isTag = false;
                                  });
                                },
                                child: Icon(Icons.clear, color: Colors.black,),
                              )
                          )
                        ],
                      )
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
