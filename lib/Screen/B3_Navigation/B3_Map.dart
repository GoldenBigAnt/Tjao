import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:tjao/Screen/B1_Home/club_profile_page.dart';
import 'package:tjao/Screen/B4_Profile/B4_My_Friends.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/club.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/live_club_friend.dart';
import 'package:tjao/model/pin_information.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// ignore: must_be_immutable
class MapPage extends StatefulWidget {
  int userId;
  MapPage({this.userId});

  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _controller;
  LatLng _center = LatLng(55.676098, 12.568337);
  MapType _currentMapType = MapType.normal;
  Future<List<ClubModel>> clubDataList;
  Future<List<Friend>> friendList;
  List<LiveClubFriend> liveClubFriends = [];
  Iterable markers = [];
  List<ClubModel> clubs;
  ClubModel markedClub;
  Location _location = Location();
  BitmapDescriptor pinLocationIcon;
  final int targetWidth = 60;
  Map<String, BitmapDescriptor> markerMap = Map<String, BitmapDescriptor>();
  double pinPillPosition = -100;
  int liveFriendsCount = 0;
  bool _isLiveFriends = false;

  ClubPinInfo currentlySelectedPin = ClubPinInfo(
      clubId: 0,
      clubName: '',
      address: '',
      rating: 0.0,
      image: '',
      location: LatLng(0, 0),
      latLng: '',
      visitors: 0,
      liveFriends: 0
  );
  List<ClubModel> clubData;

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };


  Future<List<ClubModel>> fetchClubs(http.Client client) async {
    String url = baseApiURL + "method=get_clubs&type=nearest&user_id=$userId";
    final response = await client.get(url, headers: headers);
    List results = jsonDecode(response.body);
    clubData = parseClubs(response.body);
    Iterable _markers = Iterable.generate(results.length + 1, (index) {
      if(index == results.length) {
        if(markerMap != null && markerMap['person_marker'] != null) {
          return Marker(markerId: MarkerId("marker$index"),position: _center, visible: true, icon: markerMap['person_marker']);
        } else {
          return Marker(markerId: MarkerId("marker$index"),position: _center, visible: true);
        }
      } else {
        Map result = results[index];
        double lat = result["latitude"] as double;
        double lng = result["longitude"] as double;
        String clubName = result["club_name"] as String;
        String address = result["address"] as String;
        LatLng latLngMarker = LatLng(lat, lng);
        String category = result["category"] as String;
        String catMarkerKey = category.toLowerCase() + "_marker";
        if(markerMap != null && markerMap[catMarkerKey] != null){
          return Marker(
            markerId: MarkerId("marker$index"),
            position: latLngMarker,
            visible: true,
            icon: markerMap[catMarkerKey],
            infoWindow: InfoWindow(
                title: clubName,
                snippet: address,
                onTap: (){

                }
            ),
            onTap: () {
              pinPillPosition = 0;
              currentlySelectedPin = ClubPinInfo(
                  clubId: result['club_id'],
                  clubName: result['club_name'],
                  address: result['address'],
                  rating: result['rating'].toDouble(),
                  image: baseUploadURL + result['profile_image'],
                  location: LatLng(result['latitude'], result['longitude']),
                  latLng: result['lat_lng'],
                  visitors: result['visitors'],
                  liveFriends: result['live_friends']
              );
              changeCurrentClubData(index);
            }
          );
        } else {
          return Marker(
            markerId: MarkerId("marker$index"),
            position: latLngMarker,
            visible: true,
            infoWindow: InfoWindow(
                title: clubName,
                snippet: address,
                onTap: (){
                }
            ),
            onTap: () {
              pinPillPosition = 0;
              changeCurrentClubData(index);
            }
          );
        }
      }
    });
    setState(() {
      markers = _markers;
    });
    Future<List<ClubModel>> list = compute(parseClubs, response.body);
    setState(() async {
      clubs = await list;
    });
    return list;
  }

  Future<List<Friend>> fetchFriends(http.Client client, int clubId) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId&bar_id=$clubId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubFriends, response.body);
  }

  fetchLiveClubFriends(http.Client client) async {
    String url = baseApiURL + "method=get_live_friends&id=$userId";
    final response = await client.get(url, headers: headers);
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    if(mounted){
      setState(() {
        liveClubFriends = parsed.map<LiveClubFriend>((json) => LiveClubFriend.fromJson(json)).toList();
      });
    }
  }

  void liveFriends() async {
    liveClubFriends.clear();
    await fetchLiveClubFriends(http.Client());
    setState(() {
      if(liveClubFriends.length > 0) {
        liveFriendsCount = liveClubFriends.length;
      }
    });
    new Timer(Duration(milliseconds: 30000), liveFriends);
  }

  Future<void> fetchMarkers(http.Client client) async{
    Map<String, BitmapDescriptor> markMap = Map<String, BitmapDescriptor>();
    String url = baseApiURL + "method=get_markers" ;
    final response = await client.get(url, headers: headers);
    Map<String, dynamic> json = jsonDecode(response.body);
    for (var entry in json.entries) {
      String key = entry.key;
      String value = entry.value.toString();
      final File markerImageFile = await DefaultCacheManager().getSingleFile( baseUploadURL + value);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
      final ui.Codec imageCodec = await ui.instantiateImageCodec(
        markerImageBytes,
        targetWidth: 110,
        targetHeight: 150
      );
      final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();
      final ByteData byteData = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
      markMap.putIfAbsent(key, () => icon);
    }

    setState(() {
      markerMap = markMap;
    });
  }

  void changeCurrentClubData(int index){
    if(clubs != null && clubs.length > index){
      ClubModel c = clubs[index];
      setState(() {
        markedClub = c;
        refreshFriendList();
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> checkAndRequestLocationPermissions() async {
    bool perm = false;
    if (await perm_handler.Permission.location.request().isGranted) {
      perm = true;
    }else{
      perm = false;
    }
    if(perm){
      var userLocation = await Location().getLocation();
      if(userLocation != null){
        setState(() {
          _center = LatLng(userLocation.latitude, userLocation.longitude);
          Timer(Duration(milliseconds: 500), () async {
            await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 15)));
          });
        });
      }
    }
  }

  void setCustomMapPin() async {
    /*BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100, 100)), 'assets/icon/girlcallcenter.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });*/
    final File markerImageFile = await DefaultCacheManager().getSingleFile("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSy63Bh4xKDLPFAkO_gFz3iT2k-omfo87X_pQ&usqp=CAU");
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    final ui.Codec imageCodec = await ui.instantiateImageCodec(
      markerImageBytes,
      targetWidth: targetWidth,
    );
    final ui.FrameInfo frameInfo = await imageCodec.getNextFrame();
    final ByteData byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
    pinLocationIcon = BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
  }

  void gotoClubProfile(BuildContext context, int clubId) async {
    int i = clubData.indexWhere((element) => element.club_id == clubId);
    ClubModel club = clubData[i];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
        ClubProfilePage(
            clubId : club.club_id, clubName: club.clubName,
            address: club.address, bannerImg: club.bannerImg, description: club.description,
            upcoming: club.upcoming, offers: club.offers, news: club.news,
            max_allowance: club.max_allowance, rating: club.rating, distance: club.distance,
            visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number,
            latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing
       )
      )
    );

  }


  @override
  void initState() {
    //setCustomMapPin();
    fetchMarkers(http.Client());
    super.initState();
    checkAndRequestLocationPermissions();
    friendList = fetchFriends(http.Client(), 0);
    liveFriends();
    Timer(Duration(milliseconds: 5000), () async {
      clubDataList = fetchClubs(http.Client());
    });
  }

  void refreshFriendList(){
    setState(() {
      if(markedClub != null){
        friendList = fetchFriends(http.Client(), markedClub.club_id);
      }else{
        friendList = fetchFriends(http.Client(), 0);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Stack(
            children: [
              GoogleMap(
                markers: Set.from(
                  markers,
                ),
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 15.0,
                ),
                mapType: _currentMapType,
                myLocationEnabled: true,
                onTap: (LatLng location) {
                  setState(() {
                    pinPillPosition = -100;
                  });
                },
              ),
              AnimatedPositioned(
                  bottom: pinPillPosition, right: 0, left: 0,
                  duration: Duration(milliseconds: 200),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          margin: EdgeInsets.all(10),
                          height: 90,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    blurRadius: 20,
                                    offset: Offset.zero,
                                    color: Colors.grey
                                )]
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    gotoClubProfile(context, currentlySelectedPin.clubId);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              blurRadius: 10,
                                              offset: Offset.zero,
                                              color: Colors.green
                                          )]
                                    ),
                                    child: ClipOval(
                                      child: currentlySelectedPin.image != '' ? Image.network(currentlySelectedPin.image, fit: BoxFit.cover,)
                                          : Image.asset('assets/img/club_banner.jpg'),
                                    ),
                                  ),
                                ),                                 // first widget
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'visitors: ' + currentlySelectedPin.visitors.toString(),
                                            style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                           'friends: ' + currentlySelectedPin.liveFriends.toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RatingBarIndicator(
                                              rating: currentlySelectedPin.rating,
                                              itemBuilder: (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.yellow[900],
                                              ),
                                              itemCount: 5,
                                              itemSize: 17.0,
                                              unratedColor: Colors.grey,
                                              direction: Axis.horizontal,
                                            ),
                                            SizedBox(width: 5,),
                                            Text(currentlySelectedPin.rating.toString(), style: TextStyle(fontSize: 12, color: Colors.black), textAlign: TextAlign.end,)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 15, right: 20),
                                      child: IconButton(
                                          icon: Icon(Icons.person_search_sharp, color: Colors.blue, size: 50,),
                                          onPressed: currentlySelectedPin.liveFriends > 0 ? () {
                                            Navigator.of(context).push(PageRouteBuilder(
                                                pageBuilder: (_, __, ___) => new FriendListPage(clubId: currentlySelectedPin.clubId,)
                                            ));
                                          } : null
                                      ),
                                    ),
                                    currentlySelectedPin.liveFriends > 0 ? Positioned(
                                      top: 22,
                                      right: 20,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: Text(
                                          currentlySelectedPin.liveFriends.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ) : Container(height: 0.0,)
                                  ],
                                ),
                              ]
                          )
                      )  // end of Container
                  )  // end of Align
              ),
              Positioned(
                top: 25,
                left: 15,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _currentMapType = _currentMapType == MapType.normal
                              ? MapType.satellite
                              : MapType.normal;
                        });
                      },
                      heroTag: 'btn1',
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 95,
                left: 15,
                  child: GestureDetector(
                    onTap: liveFriendsCount > 0 ? () {
                      setState(() {
                        _isLiveFriends = !_isLiveFriends;
                      });
                    } : null,
                    child: Container(
                      alignment: Alignment.center,
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.indigo[900],
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 7,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Icon(Icons.notifications, size: 40, color: Colors.white,),
                          Positioned(
                            left: 15,
                            top: 2,
                            child: liveFriendsCount > 0 ? Container(
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Text(
                                liveFriendsCount.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12
                                ),
                              ),
                            ) : Container(height: 0.0,),
                          )
                        ],
                      ),
                    ),
                  )
              ),
              Visibility(
                visible: _isLiveFriends,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.80,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)
                        ),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7.0,
                              color: Colors.black38
                          )
                        ]
                    ),
                    child: Stack(
                      children: [
                        ListView.separated(
                          itemCount: liveClubFriends.length,
                          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, color: Colors.black,),
                          itemBuilder: (context, index) {
                            LiveClubFriend friend = liveClubFriends[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserProfilePage(friendId: friend.friend_id))
                                );
                              },
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black12,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(friend.friend_pic != '' ? baseUploadURL + friend.friend_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                                  ),
                                ),
                              ),
                              title: Text(friend.friend_name),
                              subtitle: Text("I'm on ${friend.clubName}"),
                              trailing: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          ClubProfilePage(
                                              clubId : friend.club_id, clubName: friend.clubName,
                                              address: friend.address, bannerImg: friend.profileImg, description: friend.description,
                                              upcoming: friend.upcoming, offers: friend.offers, news: friend.news,
                                              max_allowance: friend.max_allowance, rating: friend.rating, distance: friend.distance,
                                              visitors: friend.visitors, live_friends: friend.live_friends, phone_number: friend.phone_number,
                                              latitude: friend.latitude, longitude: friend.longitude, bar_timing: friend.bar_timing
                                          )
                                      )
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black12,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(baseUploadURL + friend.profileImg, scale: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isLiveFriends = false;
                              });
                            },
                            child: Icon(Icons.clear, color: Colors.black,),
                          )
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}