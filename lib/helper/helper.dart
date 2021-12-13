
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tjao/model/chat_user.dart';
import 'package:tjao/model/club.dart';
import 'package:tjao/model/club_review.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/live_club_friend.dart';
import 'package:tjao/model/message.dart';
import 'package:tjao/model/notification.dart';
import 'package:tjao/model/timeline.dart';
import 'package:tjao/model/user.dart';
import 'package:tjao/model/user_review.dart';
import 'package:tjao/model/user_photo.dart';
import 'package:tjao/model/event.dart';
import 'package:tjao/model/user_setting.dart';

int userId = 0;
bool location_permission_granted = false;
List<ChatUser> missedMessageList = [];
List<NotificationData> notificationDataList = [];
UserSetting userSetting = new UserSetting();

Map<String, String> get headers => {
  "Content-Type": "application/json; charset=utf-8",
  "Accept": "application/json; charset=UTF-8"
};

List<Timeline> parseTimeline(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Timeline>((json) => Timeline.fromJson(json)).toList();
}

List<ClubModel> parseClubs(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ClubModel>((json) => ClubModel.fromJson(json)).toList();
}

List<Friend> parseClubFriends(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Friend>((json) => Friend.fromJson(json)).toList();
}

List<LiveClubFriend> parseLiveClubFriends(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<LiveClubFriend>((json) => LiveClubFriend.fromJson(json)).toList();
}

List<User> parseMyFriend(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}

List<UserReview> parseUserReviews(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<UserReview>((json) => UserReview.fromJson(json)).toList();
}

List<ClubReview> parseClubReviews(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ClubReview>((json) => ClubReview.fromJson(json)).toList();
}

List<UserPhoto> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<UserPhoto>((json) => UserPhoto.fromJson(json)).toList();
}

List<ChatUser> parseChatUser(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();
}

List<Message> parseMessages(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Message>((json) => Message.fromJson(json)).toList();
}

List<Event> parseEvents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Event>((json) => Event.fromJson(json)).toList();
}

void showToast(String msg, Color color) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: color,
      textColor: Colors.white
  );
}