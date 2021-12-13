import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tjao/Screen/B1_Home/home_page.dart';
import 'package:tjao/Screen/Bottom_Nav_Bar/bottomNavBar.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/timeline_comment.dart';
import 'package:http/http.dart' as http;

class TimelineCommentPage extends StatefulWidget {
  final int friendId;
  final int timelineId;
  final List<TimelineComment> commentList;
  TimelineCommentPage({Key key, this.friendId, this.timelineId, this.commentList}) : super(key: key);

  @override
  _TimelineCommentPageState createState() => _TimelineCommentPageState();
}

class _TimelineCommentPageState extends State<TimelineCommentPage> {
  bool _isWritting = false;
  TextEditingController _textController = new TextEditingController();
  List<TimelineComment> commentList = [];
  String commentText;

  addTimelineComment() async {
    String url = baseApiURL + "method=add_timeline_comment&user_id=${widget.friendId}&friend_id=$userId&timeline_id=${widget.timelineId}&comment=$commentText";
    await http.Client().get(url);
    setState(() {
      _isWritting = false;
      _textController.clear();
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar())
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Comments',
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: widget.commentList.length,
              itemBuilder: (context, index) {
                int i = widget.commentList.length - index - 1;
                TimelineComment c = widget.commentList[i];
                return new Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black26, width: 0.5))
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(c.user_pic != '' ? baseUploadURL + c.user_pic : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                        ),
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: c.user_name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            TextSpan(
                                text: '  ' + c.comment,
                                style: TextStyle(color: Colors.black)
                            )
                          ]
                      ),
                    ),
                    trailing: Container(
                      width: 80,
                      alignment: Alignment.topCenter,
                      child: Text(
                        c.timestamp
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 50,
                  padding: EdgeInsets.only(bottom: 10),
                  decoration: new BoxDecoration(color: Theme.of(context).cardColor),
                  child: new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new Row(
                      children: <Widget>[
                        new Flexible(
                          child: new Container(
                            margin: EdgeInsets.only(left: 10),
                            padding: EdgeInsets.only(left: 20, top: 8, right: 20, bottom: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            ),
                            child: new TextField(
                              controller: _textController,
                              onChanged: (String messageText) {
                                setState(() {
                                  commentText = messageText;
                                  if(messageText.length > 4) {
                                    _isWritting = true;
                                  } else {
                                    _isWritting = false;
                                  }
                                });
                              },
                              maxLines: null,
                              decoration: new InputDecoration.collapsed(hintText: "Add a comment"),
                              style: TextStyle(fontSize: 16),
                              onTap: () {
                              },
                            ),
                          ),
                        ),
                        new Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: IconButton(
                            icon: new Icon(Icons.send, color: _isWritting ? Colors.blue[800] : Colors.grey[700],),
                            onPressed: _isWritting ? () {
                              addTimelineComment();
                            } : null,
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ),

          ],
        ),
      ),
    );
  }
}
