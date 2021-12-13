
class Friend {
  final int friend_id;
  final int req_id;
  final int req_sent;
  final int req_status;
  final String friend_name;
  final String friend_pic;
  final int anyone_search;

  Friend({
    this.friend_id,
    this.req_id,
    this.req_sent,
    this.req_status,
    this.friend_name,
    this.friend_pic,
    this.anyone_search
  });

  factory Friend.fromJson(Map<String, dynamic> json){
    return Friend(
        friend_id: json['friend_id'],
        friend_name: json['friend_name'],
        friend_pic: json['friend_pic'],
        req_id: json['req_id'],
        req_sent: json['req_sent'],
        req_status: json['req_status'],
        anyone_search: json['anyone_search']
    );
  }

  Map<String, dynamic> toJson() => {
    'friend_id': friend_id,
    'friend_name': friend_name,
    'friend_pic': friend_pic,
    'req_id': req_id,
    'req_sent': req_sent,
    'req_status': req_status,
    'anyone_search': anyone_search
  };
}