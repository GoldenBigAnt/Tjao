class NotificationData {
  final int id;
  final String noti_type;
  final int user_id;
  final String user_name;
  final String user_pic;
  final int event_id;
  final int timeline_id;
  final String timeline_photo;
  final String timeline_des;
  final int friend_id;
  final String friend_name;
  final String friend_pic;
  final String comment;
  final int noti_status;
  final String timestamp;

  NotificationData({
    this.id,
    this.noti_type,
    this.user_id,
    this.user_name,
    this.user_pic,
    this.event_id,
    this.timeline_id,
    this.timeline_photo,
    this.timeline_des,
    this.friend_id,
    this.friend_name,
    this.friend_pic,
    this.comment,
    this.noti_status,
    this.timestamp
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return new NotificationData(
      id: json['id'],
      noti_type: json['noti_type'],
      user_id: json['user_id'],
      user_name: json['user_name'],
      user_pic: json['user_pic'],
      event_id: json['event_id'],
      timeline_id: json['timeline_id'],
      timeline_photo: json['timeline_photo'],
      timeline_des: json['timeline_des'],
      friend_id: json['friend_id'],
      friend_name: json['friend_name'],
      friend_pic: json['friend_pic'],
      comment: json['comment'],
      noti_status: json['noti_status'],
      timestamp: json['timestamp']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'noti_type': noti_type,
    'user_id': user_id,
    'user_name': user_name,
    'user_pic': user_pic,
    'event_id': event_id,
    'timeline_id': timeline_id,
    'timeline_photo': timeline_photo,
    'timeline_des': timeline_des,
    'friend_id': friend_id,
    'friend_name': friend_name,
    'friend_pic': friend_pic,
    'comment': comment,
    'noti_status': noti_status,
    'timestamp': timestamp
  };

}