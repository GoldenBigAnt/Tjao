import 'package:flutter/cupertino.dart';

class UserPhoto {
  final int id;
  final String name;

  UserPhoto({
    this.id,
    this.name
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json){
    return new UserPhoto(
        id: json['id'] as int,
        name: json['name'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name
  };
}