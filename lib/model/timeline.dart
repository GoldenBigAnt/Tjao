import 'package:tjao/model/timeline_comment.dart';
import 'package:tjao/model/timeline_like.dart';
import 'package:tjao/model/timeline_tag.dart';

class Timeline {
  final int id;
  final String photo;
  final String des;
  final String visibility;
  final int status;
  final String timestamp;
  int active_likes;
  int like_status;
  int total_comments;
  String comment;
  List<TimelineComment> comment_list;
  List<TimelineLike> like_list;
  List<TimelineTag> tag_list;
  final int user_id;
  final String user_name;
  final String user_pic;
  final int userLiveBarId;
  final String clubName;
  final String address;
  final String profileImg;
  final String description;
  final String upcoming;
  final String offers;
  final String news;
  final int max_allowance;
  final int rating;
  final double distance;
  final int visitors;
  final int live_friends;
  final double latitude;
  final double longitude;
  final String phone_number;
  final String bar_timing;
  final int boundary_meters;
  final String category;
  final String open_time;

  Timeline({
    this.id,
    this.photo,
    this.des,
    this.visibility,
    this.status,
    this.timestamp,
    this.active_likes,
    this.like_status,
    this.total_comments,
    this.comment,
    this.comment_list,
    this.like_list,
    this.tag_list,
    this.user_id,
    this.user_name,
    this.user_pic,
    this.userLiveBarId,
    this.clubName,
    this.address,
    this.profileImg,
    this.description,
    this.upcoming,
    this.offers,
    this.news,
    this.max_allowance,
    this.rating,
    this.distance,
    this.visitors,
    this.live_friends,
    this.latitude,
    this.longitude,
    this.phone_number,
    this.bar_timing,
    this.boundary_meters,
    this.category,
    this.open_time,
  });

  factory Timeline.fromJson(Map<String, dynamic> json){
    var commentData = [];
    List<TimelineComment> commentList = [];
    if(json['comment_list'] != null) {
      commentData = json['comment_list'] as List;
      commentList = commentData.map((e) => TimelineComment.fromJson(e)).toList();
    }
    var likeData = [];
    List<TimelineLike> likeList = [];
    if(json['like_list'] != null) {
      likeData = json['like_list'] as List;
      likeList = likeData.map((e) => TimelineLike.fromJson(e)).toList();
    }
    var tagData = [];
    List<TimelineTag> tagList = [];
    if(json['tag_list'] != null) {
      tagData = json['tag_list'] as List;
      tagList = tagData.map((e) => TimelineTag.fromJson(e)).toList();
    }
    return Timeline(
        id: json['id'],
        photo: json['photo'],
        des: json['des'],
        visibility: json['visibility'],
        status: json['status'],
        timestamp: json['timestamp'],
        active_likes: json['active_likes'],
        like_status: json['like_status'],
        total_comments: json['total_comments'],
        comment: json['comment'],
        comment_list: commentList,
        like_list: likeList,
        tag_list: tagList,
        user_id: json['user_id'],
        user_name: json['user_name'],
        user_pic: json['user_pic'],
        userLiveBarId: json['userLiveBarId'],
        visitors: json['visitors'],
        live_friends: json['live_friends'],
        address: json['address'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        phone_number: json['phone_number'],
        rating: json['rating'],
        boundary_meters: json['boundary_meters'],
        max_allowance: json['max_allowance'],
        category: json['category'],
        clubName: json['club_name'],
        description: json['description'],
        upcoming: json['upcoming_events'],
        offers: json['offers'],
        news: json['news'],
        profileImg: json['profile_image'],
        open_time: json['open_time'],
        bar_timing: json['bar_timing'],
        distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo': photo,
    'des': des,
    'visibility': visibility,
    'status': status,
    'timestamp': timestamp,
    'active_likes': active_likes,
    'like_status': like_status,
    'total_comments': total_comments,
    'comment': comment,
    'user_id': user_id,
    'user_name': user_name,
    'user_pic': user_pic,
    'userLiveBarId': userLiveBarId,
    'visitors': visitors,
    'live_friends': live_friends,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'phone_number': phone_number,
    'rating': rating,
    'boundary_meters': boundary_meters,
    'max_allowance': max_allowance,
    'category': category,
    'club_name': clubName,
    'description': description,
    'upcoming_events': upcoming,
    'offers': offers,
    'news': news,
    'profile_image': profileImg,
    'open_time': open_time,
    'bar_timing': bar_timing,
    'distance': distance,
  };
}



