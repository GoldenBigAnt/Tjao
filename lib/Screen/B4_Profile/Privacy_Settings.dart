import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/controller/user_controller.dart';
import 'dart:convert';
import 'dart:async';

import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';

// ignore: must_be_immutable
class PrivacySettings extends StatefulWidget {
  PrivacySettings({Key key}) : super(key: key);
  @override
  PrivacySettingsState createState() => PrivacySettingsState();
}

class PrivacySettingsState extends State<PrivacySettings> {
  int anyone_chat = 0, anyone_search = 0;
  int profile = 0, checkIn = 0, blockUser = 0, reportUser = 0;
  bool chat = false, search = false, _isProfile = false, _isCheckIn = false,  _isBlockUser = false, _isReportUser = false;
  bool _isPrivateText = false;

  Future<void> fetchPrivacy() async {
    await UserController.getUserSetting();

    setState(() {
      userSetting.anyone_chat == 1 ? chat = true : chat = false;
      userSetting.anyone_search == 1 ? search = true : search = false;
      userSetting.profile == 1 ? _isProfile = true : _isProfile = false;
      userSetting.checkIn == 1 ? _isCheckIn = true : _isCheckIn = false;
      userSetting.blockUser == 1 ? _isBlockUser = true : _isBlockUser = false;
      userSetting.reportUser == 1 ? _isReportUser = true : _isReportUser = false;
    });
  }

  updateSettings() async {
    chat == true ? anyone_chat = 1 : anyone_chat = 0;
    search == true ? anyone_search = 1 : anyone_search = 0;
    _isProfile == true ? profile = 1 : profile = 0;
    _isCheckIn == true ? checkIn = 1 : checkIn = 0;
    _isBlockUser == true ? blockUser = 1 : blockUser = 0;
    _isReportUser == true ? reportUser = 1 : reportUser = 0;
    setState(() {
      userSetting.anyone_chat = anyone_chat;
      userSetting.anyone_search = anyone_search;
      userSetting.profile = profile;
      userSetting.checkIn = checkIn;
      userSetting.blockUser = blockUser;
      userSetting.reportUser = reportUser;
    });
    String url = baseApiURL + "method=update_user_privacy&id=$userId&anyone_chat=$anyone_chat&anyone_search=$anyone_search&profile=$profile&checkIn=$checkIn&blockUser=$blockUser&reportUser=$reportUser" ;
    
    await http.Client().get(url);
  }

  @override
  void initState() {
    super.initState();
    fetchPrivacy();
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
            "Privacy Settings",
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
        elevation: 20.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              height: 55.0,
              width: double.infinity,
              color: Colors.grey[200],
              child: Text("Chat", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              constraints: BoxConstraints(
                  maxHeight: double.infinity,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 100.0,
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Everyone can chat with me', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                        Text('If Yes is, selected then anyone can send a message to the user. If NO is, selected then only friends can send a message to the user.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0, left: 10.0),
                    child: Switch(
                      value: chat,
                      onChanged: (value) {
                        setState(() {
                          chat = value;
                        });
                        updateSettings();                           
                      },
                      activeTrackColor: Color(0xFFAD2829),
                      activeColor: Color(0xFFf8c301),
                    ), 
                  )
                ]
              )
            ),
            Container(
              padding: const EdgeInsets.all(15),
              height: 55.0,
              width: double.infinity,
              color: Colors.grey[200],
              child: Text("Search", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              constraints: BoxConstraints(
                  maxHeight: double.infinity,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 100.0,
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Everyone can search me', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                        Text('If Yes, is selected then all users can find me by making a search, if NO is selected, then only friends can search and find me.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0, left: 10.0),
                    child: Switch(
                      value: search,
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                        updateSettings();                           
                      },
                      activeTrackColor: Color(0xFFAD2829),
                      activeColor: Color(0xFFf8c301),
                    ), 
                  )
                ]
              )
            ),
            // Container(
            //   padding: const EdgeInsets.all(15),
            //   height: 55.0,
            //   width: double.infinity,
            //   color: Colors.grey[200],
            //   child: Text("Profile", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            // ),
            // Container(
            //     padding: const EdgeInsets.all(15),
            //     width: double.infinity,
            //     constraints: BoxConstraints(
            //       maxHeight: double.infinity,
            //     ),
            //     child: Column(
            //       children: [
            //         Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               Container(
            //                 width: MediaQuery.of(context).size.width - 100.0,
            //                 constraints: BoxConstraints(
            //                   maxHeight: double.infinity,
            //                 ),
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text('Private Profile', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            //                     Text('If private profile is selected then, above two points will automatically be selected as well. In addition to this:', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //                   ],
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.only(top: 0.0, left: 10.0),
            //                 child: Switch(
            //                   value: _isProfile,
            //                   onChanged: (value) {
            //                     setState(() {
            //                       _isProfile = value;
            //                     });
            //                     updateSettings();
            //                   },
            //                   activeTrackColor: Color(0xFFAD2829),
            //                   activeColor: Color(0xFFf8c301),
            //                 ),
            //               )
            //             ]
            //         ),
            //         _isPrivateText ? Container(
            //           padding: EdgeInsets.only(left: 20),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text('i.	No posts or pictures will be visible to anyone else then friends', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //               Text('ii.	No pictures or posts will be visible on timeline for public, only to friends.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //               Text('iii.	Live Check in will turned off, so it will not be visible to anyone ells then friends, Admin and club Admin.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //               Text('iv.	Profile will be secret – just like Instagram when you have a private profile. No one can see your posts and pictures.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //               Text('v.	Pictures taken on a club once live checked in, will not be posted to the clubs profile page.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700])),
            //
            //             ],
            //           ),
            //         ) : Container(),
            //         GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               _isPrivateText = !_isPrivateText;
            //             });
            //           },
            //           child: Text(_isPrivateText ? 'See less . . .' : 'See more . . .', style: TextStyle(fontWeight: FontWeight.w600)),
            //         )
            //       ],
            //     )
            // ),
            Container(
              padding: const EdgeInsets.all(15),
              height: 55.0,
              width: double.infinity,
              color: Colors.grey[200],
              child: Text("Live check in", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            ),
            Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 100.0,
                        constraints: BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Turn off Live Check in ', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                            Text('No live check ins will happen once entering a club.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 10.0),
                        child: Switch(
                          value: _isCheckIn,
                          onChanged: (value) {
                            setState(() {
                              _isCheckIn = value;
                            });
                            updateSettings();
                          },
                          activeTrackColor: Color(0xFFAD2829),
                          activeColor: Color(0xFFf8c301),
                        ),
                      )
                    ]
                )
            ),
            // Container(
            //   padding: const EdgeInsets.all(15),
            //   height: 55.0,
            //   width: double.infinity,
            //   color: Colors.grey[200],
            //   child: Text("User", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            // ),
            // Container(
            //     padding: const EdgeInsets.all(15),
            //     width: double.infinity,
            //     constraints: BoxConstraints(
            //       maxHeight: double.infinity,
            //     ),
            //     child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: <Widget>[
            //           Container(
            //             width: MediaQuery.of(context).size.width - 100.0,
            //             constraints: BoxConstraints(
            //               maxHeight: double.infinity,
            //             ),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text('Block User', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            //                 Text('The users who is being blocked will not be able to make any contact, see the users live check ins or of find the profile of the user.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))
            //               ],
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.only(top: 0.0, left: 10.0),
            //             child: Switch(
            //               value: _isBlockUser,
            //               onChanged: (value) {
            //                 setState(() {
            //                   _isBlockUser = value;
            //                 });
            //                 updateSettings();
            //               },
            //               activeTrackColor: Color(0xFFAD2829),
            //               activeColor: Color(0xFFf8c301),
            //             ),
            //           )
            //         ]
            //     )
            // ),
            // SizedBox(height: 15,
            // child: Container(
            //   color: Colors.grey[300],
            // ),),
            // Container(
            //     padding: const EdgeInsets.all(15),
            //     width: double.infinity,
            //     constraints: BoxConstraints(
            //       maxHeight: double.infinity,
            //     ),
            //     child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: <Widget>[
            //           Container(
            //             width: MediaQuery.of(context).size.width - 100.0,
            //             constraints: BoxConstraints(
            //               maxHeight: double.infinity,
            //             ),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text('Report User', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            //                 Text('It should be possible to report any users. When this is clicked, a box will come up where you can write a message and describe why you are reporting this user. The message should be received in super admin panel.', style: TextStyle(fontSize: 13.0, color: Colors.grey[700]))
            //               ],
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.only(top: 0.0, left: 10.0),
            //             child: Switch(
            //               value: _isReportUser,
            //               onChanged: (value) {
            //                 setState(() {
            //                   _isReportUser = value;
            //                 });
            //                 updateSettings();
            //               },
            //               activeTrackColor: Color(0xFFAD2829),
            //               activeColor: Color(0xFFf8c301),
            //             ),
            //           )
            //         ]
            //     )
            // ),
          ],
        ),
      )
    );
  }
}