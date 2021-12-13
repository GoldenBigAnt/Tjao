import 'package:flutter/cupertino.dart';

class UserReview {
  final int id;
  final int added_by;
  final int bar_id;
  final int rating;
  final int bar_rating;
  final double distance;
  final double latitude;
  final double longitude;
  final String phone_number;
  final String open_time;
  final String bar_timing;
  final int visitors;
  final int live_friends;
  final String review;
  final String bar_name;
  final String bar_pic;
  final String posted_time;
  final int max_allowance;
  final String bar_address;
  final String bar_description;
  final String bar_upcoming_events;
  final String bar_offers;
  final String bar_news;
  final String category;

  UserReview({
     this.id,
     this.added_by,
     this.bar_id,
     this.rating,
     this.bar_rating,
     this.distance,
     this.latitude,
     this.longitude,
     this.phone_number,
     this.bar_timing,
     this.visitors,
     this.live_friends,
     this.review,
     this.bar_name,
     this.bar_pic,
     this.posted_time,
     this.max_allowance,
     this.bar_address,
     this.bar_description,
     this.bar_upcoming_events,
     this.bar_offers,
     this.bar_news,
     this.category,
     this.open_time,
  });

  factory UserReview.fromJson(Map<String, dynamic> json){
    return UserReview(
      id: json['id'],
      added_by: json['added_by'],
      bar_id: json['bar_id'],
      rating: json['rating'],
      review: json['review'],
      bar_name: json['bar_name'],
      bar_rating: json['bar_rating'],
      bar_pic: json['bar_pic'],
      bar_address: json['bar_address'],
      bar_description: json['bar_description'],
      bar_upcoming_events: json['bar_upcoming_events'],
      bar_offers: json['bar_offers'],
      bar_news: json['bar_news'],
      max_allowance: json['max_allowance'],
      category: json['category'],
      distance: json['distance'],
      visitors: json['visitors'],
      live_friends: json['live_friends'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phone_number: json['phone_number'],
      open_time: json['open_time'],
      bar_timing: json['bar_timing'],
      posted_time: json['posted_time'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'added_by': added_by,
    'bar_id': bar_id,
    'rating': rating,
    'review': review,
    'bar_name': bar_name,
    'bar_rating': bar_rating,
    'bar_pic': bar_pic,
    'bar_address': bar_address,
    'bar_description': bar_description,
    'bar_upcoming_events': bar_upcoming_events,
    'bar_offers': bar_offers,
    'bar_news': bar_news,
    'max_allowance': max_allowance,
    'category': category,
    'distance': distance,
    'visitors': visitors,
    'live_friends': live_friends,
    'latitude': latitude,
    'longitude': longitude,
    'phone_number': phone_number,
    'open_time': open_time,
    'bar_timing': bar_timing,
    'posted_time': posted_time,
  };
}