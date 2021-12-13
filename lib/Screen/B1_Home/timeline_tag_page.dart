import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/friend.dart';
import 'package:tjao/model/timeline_tag.dart';
import 'package:http/http.dart' as http;

class TimelineTagPage extends StatefulWidget {
  final int timelineId;
  final List<TimelineTag> tagList;
  TimelineTagPage({Key key, this.timelineId, this.tagList}) : super(key: key);

  @override
  _TimelineTagPageState createState() => _TimelineTagPageState();
}

class _TimelineTagPageState extends State<TimelineTagPage> {
  String tagSearch;
  Future<List<Friend>> friends;

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<Friend>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_club_friends&id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubFriends, response.body);
  }

  addTimelineTag(int friendId) async {
    String url = baseApiURL + "method=add_timeline_tag&user_id=$friendId&friend_id=$userId&timeline_id=${widget.timelineId}";
    await http.get(url);
  }

  goToUserProfilePage(int friendId) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage(friendId: friendId,))
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friends = fetchFriends(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Tags'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  prefixIcon: Icon(Icons.search),
                  labelText: "Search for people...",
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: BorderSide(color: Color(0xFFeae3e3)),
                  ),
                ),
                onChanged: (text){
                  setState(() {
                    tagSearch = text;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: friends,
                builder: (context, snapshot) {
                  return tagSearch.length > 1 ? ListView.builder(
                    itemCount: snapshot.data.length, itemBuilder: (context, index) {
                    Friend friend = snapshot.data[index];
                    return ((friend.anyone_search > 0) && (friend.friend_name.toLowerCase().startsWith(tagSearch.toLowerCase()))) ?
                    ListTile(
                      onTap: () {

                        addTimelineTag(friend.friend_id);
                        showToast(friend.friend_name, Colors.black87);
                      },
                      leading: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: NetworkImage(friend.friend_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + friend.friend_pic),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          )
                      ),
                      title: Text("${friend.friend_name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => new UserProfilePage(friendId: friend.friend_id)
                          ));
                        },
                        child: Container(
                          width: 100,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green[700]),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0) //                 <--- border radius here
                            ),
                          ),
                          child: Text('View Profile', style: TextStyle(color: Colors.green[700]),),
                        ),
                      ),
                    ) : Container(height: 0.0,);
                  },
                  )
                      : ListView.builder(
                    itemCount: widget.tagList.length,
                    itemBuilder: (context, index) {
                      TimelineTag t = widget.tagList[index];
                      return new Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black26, width: 0.5))
                        ),
                        child: ListTile(
                          onTap: () {
                            goToUserProfilePage(t.user_id);
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black12,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(t.user_pic != '' ? baseUploadURL + t.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                              ),
                            ),
                          ),
                          title: Text(
                            t.user_name,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          trailing: Container(
                            width: 80,
                            alignment: Alignment.topCenter,
                            child: Text(
                                t.timestamp
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
