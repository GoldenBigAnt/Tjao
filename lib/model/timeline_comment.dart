class TimelineComment {
  final int id;
  final int timeline_id;
  final int user_id;
  final String user_name;
  final String user_pic;
  final String comment;
  final String timestamp;

  TimelineComment({
    this.id,
    this.timeline_id,
    this.user_id,
    this.user_name,
    this.user_pic,
    this.comment,
    this.timestamp
  });

  factory TimelineComment.fromJson(Map<String, dynamic> json){
    return new TimelineComment(
        id: json['id'],
        timeline_id: json['timeline_id'],
        user_id: json['user_id'],
        user_name: json['user_name'],
        user_pic: json['user_pic'],
        comment: json['comment'],
        timestamp: json['timestamp']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timeline_id': timeline_id,
    'user_id': user_id,
    'user_name': user_name,
    'user_pic': user_pic,
    'comment': comment,
    'timestamp': timestamp
  };
}