import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClubPinInfo {
  int clubId;
  String clubName;
  String address;
  double rating;
  String image;
  LatLng location;
  String latLng;
  int visitors;
  int liveFriends;

  ClubPinInfo({
    this.clubId,
    this.clubName,
    this.address,
    this.rating,
    this.image,
    this.location,
    this.latLng,
    this.visitors,
    this.liveFriends,
  });
}