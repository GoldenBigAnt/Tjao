class TimelineTag {
  final int id;
  final int timeline_id;
  final int user_id;
  final String user_name;
  final String user_pic;
  final int friend_id;
  final String friend_name;
  final String friend_pic;
  final String timestamp;

  TimelineTag({
    this.id,
    this.timeline_id,
    this.user_id,
    this.user_name,
    this.user_pic,
    this.friend_id,
    this.friend_name,
    this.friend_pic,
    this.timestamp
  });

  factory TimelineTag.fromJson(Map<String, dynamic> json){
    return new TimelineTag(
        id: json['id'],
        timeline_id: json['timeline_id'],
        user_id: json['user_id'],
        user_name: json['user_name'],
        user_pic: json['user_pic'],
        friend_id: json['friend_id'],
        friend_name: json['friend_name'],
        friend_pic: json['friend_pic'],
        timestamp: json['timestamp']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timeline_id': timeline_id,
    'user_id': user_id,
    'user_name': user_name,
    'user_pic': user_pic,
    'friend_id': friend_id,
    'friend_name': friend_name,
    'friend_pic': friend_pic,
    'timestamp': timestamp
  };
}