class Event {
  final int event_id;
  final String event_type;
  final String event_name;
  final String event_date;
  final String start_time;
  final String location;
  final String city;
  final String imageUrl;
  final String description;
  final int added_by;
  final int joined;
  final int approved;
  final int bar_id;
  final String created_by;
  final String bar_name;
  final String guests;

  Event({
    this.event_id,
    this.event_type,
    this.event_name,
    this.event_date,
    this.start_time,
    this.location,
    this.city,
    this.imageUrl,
    this.description,
    this.added_by,
    this.joined,
    this.approved,
    this.bar_id,
    this.created_by,
    this.bar_name,
    this.guests
  });

  factory Event.fromJson(Map<String, dynamic> json){
    return Event(
      event_id: json['event_id'],
      bar_id: json['bar_id'],
      event_type: json['event_type'],
      event_name: json['event_name'],
      event_date: json['event_date'],
      start_time: json['start_time'],
      location: json['location'],
      city: json['city'],
      added_by: json['added_by'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      created_by: json['created_by'],
      bar_name: json['bar_name'],
      guests: json['guests'],
      joined: json['joined'],
      approved: json['approved']
    );
  }

  Map<String, dynamic> toJson() => {
    'event_id': event_id,
    'event_type': event_type,
    'event_name': event_name,
    'event_date': event_date,
    'start_time': start_time,
    'location': location,
    'city': city,
    'imageUrl': imageUrl,
    'description': description,
    'added_by': added_by,
    'joined': joined,
    'approved': approved,
    'bar_id': bar_id,
    'created_by': created_by,
    'bar_name': bar_name,
    'guests': guests
  };
}