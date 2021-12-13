import 'package:flutter/cupertino.dart';

class Message {
  final int id;
  final int from_id;
  final int to_id;
  final String message;
  final String date_time;

  Message({
    this.id,
    this.from_id,
    this.to_id,
    this.message,
    this.date_time,
  });

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
        id: json['id'],
        from_id: json['from_id'],
        to_id: json['to_id'],
        message: json['message'],
        date_time: json['date_time']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'from_id': from_id,
    'to_id': to_id,
    'message': message,
    'date_time': date_time
  };
}