class UserSetting {
  final int id;
  final int user_id;
  int anyone_chat;
  int anyone_search;
  int profile;
  int checkIn;
  int blockUser;
  int reportUser;
  final int status;
  final String timestamp;

  UserSetting({
    this.id,
    this.user_id,
    this.anyone_chat,
    this.anyone_search,
    this.profile,
    this.checkIn,
    this.blockUser,
    this.reportUser,
    this.status,
    this.timestamp
  });

  factory UserSetting.fromJson(Map<String, dynamic> json){
    return new UserSetting(
        id: json['id'],
        user_id: json['user_id'],
        anyone_chat: json['anyone_chat'],
        anyone_search: json['anyone_search'],
        profile: json['profile'],
        checkIn: json['checkIn'],
        blockUser: json['blockUser'],
        reportUser: json['reportUser'],
        status: json['status'],
        timestamp: json['timestamp']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': user_id,
    'anyone_chat': anyone_chat,
    'anyone_search': anyone_search,
    'profile': profile,
    'checkIn': checkIn,
    'blockUser': blockUser,
    'reportUser': reportUser,
    'status': status,
    'timestamp': timestamp
  };
}