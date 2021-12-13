// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:icon_animator/icon_animator.dart';
// import 'package:tjao/Screen/B4_Profile/B4_Profile.dart';
// import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
// import 'package:tjao/helper/app_config.dart';
// import 'package:tjao/helper/helper.dart';
// import 'package:tjao/model/timeline.dart';
// import 'package:http/http.dart' as http;
//
// import 'club_profile_page.dart';
//
// class TimelinePage extends StatefulWidget {
//   final int selectedTimelineId;
//   TimelinePage({Key key, this.selectedTimelineId}) : super(key: key);
//
//   @override
//   _TimelinePageState createState() => _TimelinePageState();
// }
//
// class _TimelinePageState extends State<TimelinePage> {
//   Future<List<Timeline>> selectedTimeline;
//   bool _isSelectedLikeAnimationIcon = false;
//
//   Future<List<Timeline>> fetchSelectedTimeline() async {
//     String url = baseApiURL + "method=get_one_timeline&timeline_id=${widget.selectedTimelineId}";
//     final response = await http.get(url, headers: headers);
//     return compute(parseTimeline, response.body);
//   }
//
//   void gotoClubProfile(BuildContext context, Timeline club) async {
//     Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) =>
//             ClubProfilePage(
//                 clubId : club.userLiveBarId, clubName: club.clubName,
//                 address: club.address, bannerImg: club.profileImg, description: club.description,
//                 upcoming: club.upcoming, offers: club.offers, news: club.news,
//                 max_allowance: club.max_allowance, rating: club.rating, distance: club.distance,
//                 visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number,
//                 latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing
//             )
//         )
//     );
//   }
//
//   addTimelineLike(int friendId, int timelineId) async {
//     String url = baseApiURL + "method=add_timeline_like&user_id=$friendId&friend_id=$userId&timeline_id=$timelineId&status=1";
//     await http.Client().get(url);
//   }
//
//   isSelectedLikeActive() {
//     setState(() {
//       _isSelectedLikeAnimationIcon = true;
//     });
//     new Timer(Duration(seconds: 3), () {
//       setState(() {
//         _isSelectedLikeAnimationIcon = false;
//       });
//     });
//   }
//
//   goToTimelineCommentPage(int friendId, int timelineId, List<TimelineComment> commentList) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) =>
//             TimelineCommentPage(friendId: friendId, timelineId: timelineId, commentList: commentList,))
//     );
//   }
//
//   goToTimelineLikePage(List<TimelineLike> likeList) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) =>
//             TimelineLikePage(likeList: likeList,))
//     );
//   }
//
//   goToTimelineTagPage(int timelineId, List<TimelineTag> tagList) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) =>
//             TimelineTagPage(timelineId: timelineId, tagList: tagList,))
//     );
//   }
//
//   goToUserProfilePage(int friendId) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => UserProfilePage(friendId: friendId,))
//     );
//   }
//
//   deleteTimelineDialog(BuildContext context, int timelineId) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             backgroundColor: Colors.white,
//             title: Text(
//               'Confirm delete',
//               style: TextStyle(color: Colors.black),
//               textAlign: TextAlign.center,
//             ),
//             content: Container(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Are you sure want to delete?', style: TextStyle(fontSize: 16, color: Colors.black),),
//                   SizedBox(height: 20,),
//                   Container(
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 40,
//                           child: RaisedButton(
//                             child: Text("No", style: TextStyle(fontSize: 20, color: Colors.black),),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                                 side: BorderSide(color: Colors.black)
//                             ),
//                             color: Colors.white,
//                             padding: EdgeInsets.all(8.0),
//                           ),
//                         ),
//                         SizedBox(width: 30,),
//                         Container(
//                           width: 100,
//                           height: 40,
//                           alignment: Alignment.center,
//                           child: RaisedButton(
//                             child: Text("Yes", style: TextStyle(fontSize: 20, color: Colors.white),),
//                             onPressed: () {
//                               deleteTimeline(timelineId);
//                             },
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                                 side: BorderSide(color: Colors.red)
//                             ),
//                             color: Colors.red[900],
//                             padding: EdgeInsets.all(8.0),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//     );
//   }
//
//   deleteTimeline(int timelineId) async {
//     String url = baseApiURL + "method=delete_timeline&timeline_id=$timelineId";
//     await http.get(url);
//     Navigator.of(context).pop();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     selectedTimeline = fetchSelectedTimeline();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Timeline'),
//       ),
//       body: Container(
//           child: FutureBuilder<List<Timeline>>(
//             future: selectedTimeline,
//             builder: (context, snapshot) {
//               if (snapshot.hasError) print(snapshot.error);
//
//               return snapshot.hasData ? ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (context, index) {
//                   Timeline t = snapshot.data[index];
//                   return Container(
//                     width: width,
//                     child: Column(
//                       children: [
//                         Container(
//                           width: width,
//                           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//                           child: Row(
//                             children: [
//                               Container(
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       t.user_name,
//                                       style: TextStyle(fontSize: 11, color: Colors.black),
//                                     ),
//                                     SizedBox(height: 5,),
//                                     InkWell(
//                                       onTap: () {
//                                         if(t.user_id == userId) {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(builder: (context) => ProfilePage())
//                                           );
//                                         }else {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(builder: (context) => UserProfilePage(friendId: t.user_id, ))
//                                           );
//                                         }
//                                       },
//                                       child: Container(
//                                           width: 70.0,
//                                           height: 70.0,
//                                           decoration: BoxDecoration(
//                                               color: Colors.grey,
//                                               image: DecorationImage(
//                                                 image: NetworkImage(
//                                                   t.user_pic != '' ? baseUploadURL + t.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
//                                                 ),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                               borderRadius: BorderRadius.all(Radius.circular(75.0)),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                     blurRadius: 9.0,
//                                                     color: Colors.red[900]
//                                                 )
//                                               ]
//                                           )
//                                       ),
//                                     ),
//
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 20,),
//                               t.userLiveBarId > 0 ? Expanded(
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       child: Row(
//                                         children: [
//                                           InkWell(
//                                             onTap: () {
//                                               gotoClubProfile(context, t);
//                                             },
//                                             child: Image.network(
//                                               baseUploadURL + t.profileImg,
//                                               height: 50,
//                                               width: 70,
//                                               fit: BoxFit.fill,
//                                             ),
//                                           ),
//                                           SizedBox(width: 10,),
//                                           Expanded(
//                                             child: Text(t.clubName , style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(height: 10,),
//                                     t.photo != '' ? Container(
//                                       child: Text(
//                                         t.des,
//                                         style: TextStyle(fontSize: 12, color: Colors.black),
//                                         textAlign: TextAlign.start,
//                                       ),
//                                     ) : Container(height: 0.0,)
//                                   ],
//                                 ),
//                               )
//                                   : t.photo != '' ? Expanded(
//                                 child: Text(
//                                   t.des,
//                                   style: TextStyle(fontSize: 12, color: Colors.black),
//                                   textAlign: TextAlign.start,
//                                 ),
//                               ) : Container()
//
//                             ],
//                           ),
//                         ),
//                         Stack(
//                           alignment: Alignment.center,
//                           children: <Widget>[
//                             GestureDetector(
//                               onDoubleTap: () {
//                                 if(t.like_status == 0) {
//                                   setState(() {
//                                     t.like_status = 1;
//                                     t.active_likes = t.active_likes + 1;
//                                   });
//                                   addTimelineLike(t.user_id, t.id);
//                                   isSelectedLikeActive();
//                                 }
//                               },
//                               child: t.photo != '' ? Container(
//                                 width: width,
//                                 child: Image.network(
//                                     baseUploadURL + t.photo,
//                                     fit: BoxFit.fitWidth,
//                                     loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
//                                       if (loadingProgress == null) return child;
//                                       return Center(
//                                         child: CircularProgressIndicator(
//                                           value: loadingProgress.expectedTotalBytes != null ?
//                                           loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
//                                               : null,
//                                         ),
//                                       );
//                                     }
//                                 ),
//                               ) : Container(
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//                                 width: width,
//                                 color: Colors.black12,
//                                 child: Text(
//                                   t.des,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             _isSelectedLikeAnimationIcon ? IconAnimator(
//                               icon: Icons.favorite,
//                               finish: SizedBox.shrink(),
//                               loop: 1,
//                               children: [
//                                 AnimationFrame(size: 50, color: Colors.pink[600], duration: 100),
//                                 AnimationFrame(size: 70, color: Colors.pink[500], duration: 50),
//                                 AnimationFrame(size: 80, color: Colors.pink[600], duration: 100),
//                                 AnimationFrame(size: 100, color: Colors.pink[700], duration: 500),
//                                 AnimationFrame(size: 80, color: Colors.pink[600], duration: 50),
//                               ],
//                             ) : Container(height: 0.0,)
//                           ],
//                         ),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         if(t.like_status == 0) {
//                                           setState(() {
//                                             t.like_status = 1;
//                                             t.active_likes = t.active_likes + 1;
//                                           });
//                                           addTimelineLike(t.user_id, t.id);
//                                           isSelectedLikeActive();
//                                         }
//                                       },
//                                       child: Icon(
//                                         t.like_status == 1 ? Icons.favorite : Icons.favorite_border,
//                                         size: 32,
//                                         color: t.like_status == 1 ? Colors.red[800] : Colors.black,
//                                       ),
//                                     ),
//                                     SizedBox(width: 5,),
//                                     t.active_likes != 0 ? InkWell(
//                                       onTap: () {
//                                         goToTimelineLikePage(t.like_list);
//                                       },
//                                       child: Text(t.active_likes.toString(), style: TextStyle(fontSize: 14, color: Colors.black),),
//                                     ) : Container(height: 0.0),
//                                     SizedBox(width: 15,),
//                                     InkWell(
//                                         onTap: () {
//                                           goToTimelineCommentPage(t.user_id, t.id, t.comment_list);
//                                         },
//                                         child: Icon(Icons.chat_sharp, color: t.comment != "" ? Colors.blue[900] : Colors.black, size: 30,)
//                                     ),
//                                     SizedBox(width: 5,),
//                                     t.total_comments != 0 ? Text(t.total_comments.toString(), style: TextStyle(fontSize: 14, color: Colors.black),) : Container(height: 0.0,),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           _isTag = true;
//                                           friendId = t.user_id;
//                                           timeline_Id = t.id;
//                                           selectedTagList = t.tag_list;
//                                         });
//                                       },
//                                       child: Image.asset('assets/icon/user_group.png', height: 32, ),
//                                     ),
//                                     SizedBox(width: 5,),
//                                     t.user_id  == userId ? InkWell(
//                                       onTap: () {
//                                         deleteTimelineDialog(context, t.id);
//                                       },
//                                       child: Icon(Icons.delete, size: 30,),
//                                     ) : Container(height: 0.0,),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         t.comment_list.length > 0 && t.comment_list.length == 1 ?
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           alignment: Alignment.centerLeft,
//                           child: RichText(
//                             text: TextSpan(
//                                 children: [
//                                   TextSpan(
//                                       text: t.comment_list[0].user_name,
//                                       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
//                                   ),
//                                   TextSpan(
//                                       text: '  ' + t.comment_list[0].comment,
//                                       style: TextStyle(color: Colors.black)
//                                   )
//                                 ]
//                             ),
//                           ),
//                         ) : t.comment_list.length > 1 ?
//                         Container(
//                           alignment: Alignment.centerLeft,
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 text: TextSpan(
//                                     children: [
//                                       TextSpan(
//                                           text: t.comment_list[0].user_name,
//                                           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
//                                       ),
//                                       TextSpan(
//                                           text: '  ' + t.comment_list[0].comment,
//                                           style: TextStyle(color: Colors.black)
//                                       )
//                                     ]
//                                 ),
//                               ),
//                               SizedBox(height: 5,),
//                               RichText(
//                                 text: TextSpan(
//                                     children: [
//                                       TextSpan(
//                                           text: t.comment_list[1].user_name,
//                                           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
//                                       ),
//                                       TextSpan(
//                                           text: '  ' + t.comment_list[1].comment,
//                                           style: TextStyle(color: Colors.black)
//                                       )
//                                     ]
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ) : Container(height: 0.0,),
//
//                         Divider(height: 2, color: Colors.black,),
//                         SizedBox(height: 10,),
//                       ],
//                     ),
//                   );
//                 },
//               ) : Center(child: CircularProgressIndicator());
//
//             },
//           )
//       ),
//     );
//   }
// }
