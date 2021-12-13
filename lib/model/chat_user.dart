import 'package:flutter/cupertino.dart';

class ChatUser {
  final int id;
  final int from_id;
  final int to_id;
  final int read_status;
  final String message;
  final String date_time;
  final String user_name;
  final String user_pic;

  ChatUser({
    this.id,
    this.from_id,
    this.to_id,
    this.read_status,
    this.message,
    this.date_time,
    this.user_name,
    this.user_pic,
  });


  factory ChatUser.fromJson(Map<String, dynamic> json){
    return new ChatUser(
        id: json['id'],
        from_id: json['from_id'],
        to_id: json['to_id'],
        read_status: json['read_status'],
        message: json['message'],
        date_time: json['date_time'],
        user_name: json['user_name'],
        user_pic: json['user_pic']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'from_id': from_id,
    'to_id': to_id,
    'read_status': read_status,
    'message': message,
    'date_time': date_time,
    'user_name': user_name,
    'user_pic': user_pic
  };
}