import 'package:flutter/cupertino.dart';

class ClubReview {
  final int id;
  final int added_by;
  final int bar_id;
  final int rating;
  final String review;
  final String added_by_name;
  final String added_by_pic;
  final String posted_time;

  ClubReview({
     this.id,
     this.added_by,
     this.bar_id,
     this.rating,
     this.review,
     this.added_by_name,
     this.added_by_pic,
     this.posted_time
  });

  factory ClubReview.fromJson(Map<String, dynamic> json){
    return new ClubReview(
        id: json['id'],
        added_by: json['added_by'],
        bar_id: json['bar_id'],
        rating: json['rating'],
        review: json['review'],
        added_by_name: json['added_by_name'],
        added_by_pic: json['added_by_pic'],
        posted_time: json['posted_time']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'added_by': added_by,
    'bar_id': bar_id,
    'rating': rating,
    'review': review,
    'added_by_name': added_by_name,
    'added_by_pic': added_by_pic,
    'posted_time': posted_time
  };
}