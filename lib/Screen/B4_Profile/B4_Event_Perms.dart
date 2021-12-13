import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tjao/helper/app_config.dart';

class EventPerms extends StatefulWidget{
  int user_id, event_id;

  EventPerms({this.user_id, this.event_id});
  @override
  _EventPermsState createState() => _EventPermsState();
}

List<_Friend> parseFriends(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<_Friend>((json) => _Friend.fromJson(json)).toList();
}

class _EventPermsState extends State<EventPerms> {
  List<int> selectedFriends = List<int>();
  String search = "";
  Map<int, int> guestMap = Map<int, int>();
  Future<List<_Friend>> friends;

  @override
  void initState() {
    super.initState();
    fetchEvent(http.Client());  
    friends = fetchFriends(http.Client());  
  }

  Map<String, String> get headers => {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=UTF-8"
      };

  Future<void> fetchEvent(http.Client client) async {
    String url = baseApiURL + "method=get_events&id=${widget.user_id}&event_id=${widget.event_id}" ;
    
    final response =
      await client.get(url, headers: headers);
      Map<String, dynamic> event = jsonDecode(response.body);

      setState(() {
        String userids = event['userids'];
        String alloweds = event['alloweds'];

        if(userids != ""){
          List<String> arr = userids.split(',');
          List<String> arr1 = alloweds.split(',');

          for(var i = 0; i < arr.length; i++){
            int app = int.parse(arr1[i]);
            int uid = int.parse(arr[i]);
            guestMap.putIfAbsent(uid, () => app);
            if(app > 0){
              selectedFriends.add(uid);
            }
          }
        }
      });
  }

  Future<List<_Friend>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=${widget.user_id}" ;
    final response =
      await client.get(url, headers: headers);
      return compute(parseFriends, response.body);
  }

  updateEvent() async {
    String friends = "";
    for (int i = 0; i < selectedFriends.length; i++) {
      if(friends == ""){
        friends = "${selectedFriends[i]}";
      }else{
        friends = "${friends},${selectedFriends[i]}";
      }
    }

    String url = baseApiURL + "method=add_event&event_id=${widget.event_id}&id=${widget.user_id}&friends=${friends}" ;
    
    final response =
      await http.Client().get(url);

      print("response = ${response.body}");
  }

  void updateFriendList(bool add, int id){
    setState(() {
      if(add){
        selectedFriends.add(id);
      }else{
        selectedFriends.remove(id);
      }
    });
    updateEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text("Manage Event Permissions",
            style: TextStyle(
              fontFamily: "Popins",
              fontSize: 17.0,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  prefixIcon: Icon(Icons.search),
                  labelText: "Search for people...",
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: const BorderSide(
                      color: Color(0xFFeae3e3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: BorderSide(color: Color(0xFFeae3e3)),
                  ),
                ),
                onChanged: (text){
                  setState(() {
                    search = text;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: FutureBuilder<List<_Friend>>(
                future: friends,
                builder: (context, snapshot) {                                              
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? myFriends(
                        list: snapshot.data,
                        notifyParent: updateFriendList,
                        selectedFriends: selectedFriends,
                        search: search,
                        guestMap: guestMap
                      ) : Center(child: CircularProgressIndicator());
                },
              )    
            ),
          ]
        )
      )
    );
  }
}

class myFriends extends StatelessWidget{
  myFriends({this.list, @required this.notifyParent, this.selectedFriends, this.search, this.guestMap});
  final List<_Friend> list;
  final notifyParent;
  final List<int> selectedFriends;
  final String search;
  final Map<int, int> guestMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((friend) {
            return ((friend.req_status > 0 || guestMap[friend.friend_id] != null) && (search == "" || friend.friend_name.toLowerCase().startsWith(search.toLowerCase())))?Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: NetworkImage(friend.friend_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + friend.friend_pic),
                                    fit: BoxFit.cover,),
                                  borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                )
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                height: 25.0,
                                child: Text("${friend.friend_name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  OutlineButton(
                    onPressed: () async{
                      if(selectedFriends.contains(friend.friend_id)){
                        this.notifyParent(false, friend.friend_id);
                      }else{
                        this.notifyParent(true, friend.friend_id);
                      }                      
                    },
                    borderSide: BorderSide(
                      color: Colors.red[200], //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                    padding: EdgeInsets.all(0), 
                    child: (guestMap[friend.friend_id] != null)?Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text((selectedFriends.contains(friend.friend_id))?"Deny":"Allow", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                      ],
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text((selectedFriends.contains(friend.friend_id))?"Remove":"Invite", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                      ],
                    )
                    /*child: (friend.req_status > 0)?Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text((selectedFriends.contains(friend.friend_id))?"Remove":"Invite", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                      ],
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text((selectedFriends.contains(friend.friend_id))?"Deny":"Allow", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                      ],
                    ),*/
                  )
                ]
              ),
            ):Container();
          }).toList(),
      )
    );
  }
}

class _Friend {
  const _Friend({
    @required this.friend_id,
    @required this.req_status,
    @required this.friend_name,
    @required this.friend_pic
  })  : assert(friend_id != null),
        assert(friend_name != null);
  final int friend_id;
  final int req_status;
  final String friend_name;
  final String friend_pic;

  factory _Friend.fromJson(dynamic json){    
    return _Friend(
        friend_id: json['friend_id'] as int,
        req_status: json['req_status'] as int,
        friend_name: json['friend_name'] as String,
        friend_pic: json['friend_pic'] as String
      );
  }
}