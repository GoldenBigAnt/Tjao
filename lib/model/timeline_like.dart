class TimelineLike {
  final int id;
  final int timeline_id;
  final int user_id;
  final String user_name;
  final String user_pic;
  final int status;
  final String timestamp;

  TimelineLike({
    this.id,
    this.timeline_id,
    this.user_id,
    this.user_name,
    this.user_pic,
    this.status,
    this.timestamp
  });

  factory TimelineLike.fromJson(Map<String, dynamic> json){
    return new TimelineLike(
        id: json['id'],
        timeline_id: json['timeline_id'],
        user_id: json['user_id'],
        user_name: json['user_name'],
        user_pic: json['user_pic'],
        status: json['status'],
        timestamp: json['timestamp']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timeline_id': timeline_id,
    'user_id': user_id,
    'user_name': user_name,
    'user_pic': user_pic,
    'status': status,
    'timestamp': timestamp
  };
}