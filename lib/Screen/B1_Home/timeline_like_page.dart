import 'package:flutter/material.dart';
import 'package:tjao/Screen/B4_Profile/B4_User_Profile.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/model/timeline_like.dart';
import 'package:tjao/model/timeline_tag.dart';

class TimelineLikePage extends StatefulWidget {
  final List<TimelineLike> likeList;
  TimelineLikePage({Key key, this.likeList}) : super(key: key);

  @override
  _TimelineLikePageState createState() => _TimelineLikePageState();
}

class _TimelineLikePageState extends State<TimelineLikePage> {

  goToUserProfilePage(int friendId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage(friendId: friendId,))
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Likes'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: widget.likeList.length,
          itemBuilder: (context, index) {
            int i = widget.likeList.length - index - 1;
            TimelineLike t = widget.likeList[i];
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
        ),
      ),
    );
  }
}
