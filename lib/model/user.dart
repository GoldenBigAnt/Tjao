
class User {
  final int id;
  final String name;
  final String first_name;
  final String last_name;
  final String email;
  final String mobile_number;
  final String gender;
  final String profile_pic;
  final String country;
  final int covid_flag;
  final int age;
  final String city;
  final String sexual_orientation;
  final String marital_status;
  final String height;
  final String hobbies;
  final int req_id;

  User({
    this.id,
    this.name,
    this.first_name,
    this.last_name,
    this.email,
    this.mobile_number,
    this.gender,
    this.profile_pic,
    this.country,
    this.covid_flag,
    this.age,
    this.city,
    this.sexual_orientation,
    this.marital_status,
    this.height,
    this.hobbies,
    this.req_id
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
        id: json['id'],
        name: json['name'],
        first_name: json['first_name'],
        last_name: json['last_name'],
        email: json['email'],
        mobile_number: json['mobile_number'],
        gender: json['gender'],
        profile_pic: json['profile_pic'],
        country: json['country'],
        covid_flag: json['covid_flag'],
        age: json['age'],
        city: json['city'],
        sexual_orientation: json['sexual_orientation'],
        marital_status: json['marital_status'],
        height: json['height'],
        hobbies: json['hobbies'],
        req_id: json['req_id']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'first_name': first_name,
    'last_name': last_name,
    'email': email,
    'mobile_number': mobile_number,
    'gender': gender,
    'profile_pic': profile_pic,
    'country': country,
    'covid_flag': covid_flag,
    'age': age,
    'city': city,
    'sexual_orientation': sexual_orientation,
    'marital_status': marital_status,
    'height': height,
    'hobbies': hobbies,
    'req_id': req_id
  };
}