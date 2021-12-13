import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/friend.dart';

class SearchUserPage extends StatefulWidget{
  SearchUserPage({Key key}) : super(key: key);

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}


class _SearchUserPageState extends State<SearchUserPage> {
  Future<List<Friend>> friends;
  String search = "";

  @override
  void initState() {
    super.initState();
    friends = fetchFriends(http.Client());  
  }

  Map<String, String> get headers => {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=UTF-8"
  };

  Future<List<Friend>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId" ;
    final response = await client.get(url, headers: headers);
    return compute(parseClubFriends, response.body);
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
        elevation: 10.0,
        title: Text(
            "Search Users",
            style: TextStyle(
              fontFamily: "Popins",
              fontSize: 17.0,
            )
        ),
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
              child: FutureBuilder<List<Friend>>(
                future: friends,
                builder: (context, snapshot) {                                              
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? MyFriendScreen(
                        list: snapshot.data,
                        search: search,
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

class MyFriendScreen extends StatelessWidget{
  MyFriendScreen({this.list, this.search});
  final List<Friend> list;
  final String search;

  viewFriendProfile(int friendId, BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friendId)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((friend) {
            return ((friend.anyone_search > 0) && (search == "" || friend.friend_name.toLowerCase().startsWith(search.toLowerCase())))? Padding(
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
                      viewFriendProfile(friend.friend_id, context);                    
                    },
                    borderSide: BorderSide(
                      color: Colors.red[200], //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                    padding: EdgeInsets.all(0),  
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text("View Profile", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                      ],
                    )
                  )
                ]
              ),
            ) : Container();
          }).toList(),
      )
    );
  }
}