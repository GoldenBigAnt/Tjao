
class LiveClubFriend {
  final int friend_id;
  final String friend_name;
  final String friend_pic;
  final int req_id;
  final int req_sent;
  final int req_status;
  final int anyone_search;
  final int club_id;
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

  LiveClubFriend({
    this.friend_id,
    this.friend_name,
    this.friend_pic,
    this.req_id,
    this.req_sent,
    this.req_status,
    this.anyone_search,
    this.club_id,
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

  factory LiveClubFriend.fromJson(Map<String, dynamic> json){
    return new LiveClubFriend(
      friend_id: json['friend_id'],
      friend_name: json['friend_name'],
      friend_pic: json['friend_pic'],
      req_id: json['req_id'],
      req_sent: json['req_sent'],
      req_status: json['req_status'],
      anyone_search: json['anyone_search'],
      club_id: json['club_id'],
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
    'friend_id': friend_id,
    'friend_name': friend_name,
    'friend_pic': friend_pic,
    'req_id': req_id,
    'req_sent': req_sent,
    'req_status': req_status,
    'anyone_search': anyone_search,
    'club_id': club_id,
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