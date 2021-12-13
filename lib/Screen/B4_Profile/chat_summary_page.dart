import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/chat_user.dart';
import 'dart:convert';
import 'dart:async';
import 'chat_board_page.dart';

// ignore: must_be_immutable
class ChatSummaryPage extends StatefulWidget {
  int id;
  ChatSummaryPage({this.id});
  @override
  ChatSummaryPageState createState() => ChatSummaryPageState();
}


class ChatSummaryPageState extends State<ChatSummaryPage> {
  Future<List<ChatUser>> messages;
  ScrollController _scrollController = new ScrollController();

  updateMessageList(){
    if(mounted){
      setState(() {
        messages = fetchMessageHistory(http.Client());
      });
      new Timer(Duration(milliseconds: 30000), updateMessageList);
    }
  }

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<ChatUser>> fetchMessageHistory(http.Client client) async{
    String currentTime = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}";
    // print(['-----------', Uri.encodeComponent(currentTime)]);

    String url = baseApiURL + "method=get_chat_users&id=${widget.id}&curr_time=${Uri.encodeComponent(currentTime)}";
    final response = await client.get(url, headers: headers);
    return compute(parseChatUser, response.body);
  }

  void deleteMessage(BuildContext context, http.Client client, int fromId, int toId) async {
    String url = baseApiURL + "method=delete_chat&from_id=$fromId&to_id=$toId";
    await client.get(url, headers: headers);
    setState(() {
      messages = fetchMessageHistory(http.Client());
    });
    Navigator.of(context).pop();
  }


  Future _moreDetailDialog(BuildContext context, int fromId, int toId, String userName) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Which would you like to select?',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("View", style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                            PageRouteBuilder(
                                pageBuilder: (_, ___, ____) =>
                                new ChatBoardPage(friedId: toId, id : fromId, friendName: userName)));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.orange,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("Delete conversation", style: TextStyle(fontSize: 18, color: Colors.white),),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _deleteConfirmDialog(context, http.Client(), fromId, toId);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.red[900],
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.white)
                      ),
                      color: Colors.black,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
          );
        }
    );
  }

  Future _deleteConfirmDialog(BuildContext context,  http.Client client, int fromId, int toId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Confirm delete',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure want to delete?', style: TextStyle(fontSize: 16, color: Colors.white),),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          child: RaisedButton(
                            child: Text("No", style: TextStyle(fontSize: 20, color: Colors.white),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.white)
                            ),
                            color: Colors.black,
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                        SizedBox(width: 30,),
                        Container(
                          width: 100,
                          height: 40,
                          child: RaisedButton(
                            child: Text("Yes", style: TextStyle(fontSize: 20, color: Colors.white),),
                            onPressed: () {
                              deleteMessage(context, client, fromId, toId);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.white)
                            ),
                            color: Colors.red[900],
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateMessageList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            "Message Board",
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
        elevation: 10.0,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<ChatUser>>(
          future: messages,
          builder: (context, snapshot) {
            List<ChatUser> list = snapshot.data;
            if (snapshot.hasError) print(snapshot.error);

            return (snapshot.hasData && snapshot.data.length > 0)
                ? ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: list.length, itemBuilder: (context, index) {
                  ChatUser msg = list[index];
                  return InkWell(
                      onTap: () async{
                        await Navigator.of(context).push(
                            PageRouteBuilder(
                                pageBuilder: (_, ___, ____) =>
                                new ChatBoardPage(friedId: msg.to_id, id : msg.from_id, friendName: msg.user_name)
                            ));
                      },
                      onLongPress: () {
                        _moreDetailDialog(context, msg.from_id, msg.to_id, msg.user_name);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                image: DecorationImage(
                                  image: NetworkImage(msg.user_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + msg.user_pic),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                              )
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
                            padding: const EdgeInsets.only(bottom: 10.0, top: 7.0),
                            width: MediaQuery.of(context).size.width - 80.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                                border: Border (bottom: BorderSide(width: 1.0, color: Colors.grey[300]))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (msg.read_status == 0) ? new Container(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width - 145,
                                      ),
                                      child: new Text(
                                        '${msg.user_name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ) : new Container(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width - 145,
                                      ),
                                      child: new Text(
                                        '${msg.user_name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: new Container(
                                        padding: new EdgeInsets.only(top: 5.0),
                                        child: new Text(
                                          msg.date_time,
                                          overflow: TextOverflow.ellipsis,
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Roboto',
                                              color: Colors.grey[600]
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                (msg.read_status == 0) ? Flexible(
                                  child: new Container(
                                    padding: new EdgeInsets.only(top: 5.0),
                                    child: new Text(
                                      msg.message,
                                      overflow: TextOverflow.ellipsis,
                                      style: new TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ) : Flexible(
                                  child: new Container(
                                    padding: new EdgeInsets.only(top: 5.0),
                                    child: new Text(
                                      msg.message,
                                      overflow: TextOverflow.ellipsis,
                                      style: new TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.grey[600]
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  );
                }
            ) : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ShowSummaryScreen extends StatelessWidget{
  ShowSummaryScreen({this.list, @required this.notifyParent});
  final List<ChatUser> list;
  final notifyParent;
  ScrollController _scrollController = new ScrollController();

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  void deleteMessage(BuildContext context, http.Client client, int fromId, int toId) async {
    String url = baseApiURL + "method=delete_chat&from_id=$fromId&to_id=$toId";
    await client.get(url, headers: headers);
    Navigator.of(context).pop();
  }


  Future _moreDetailDialog(BuildContext context, int fromId, int toId, String userName) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Which would you like to select?',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("View", style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                            PageRouteBuilder(
                                pageBuilder: (_, ___, ____) =>
                                new ChatBoardPage(friedId: toId, id : fromId, friendName: userName)));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.orange,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("Delete conversation", style: TextStyle(fontSize: 18, color: Colors.white),),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _deleteConfirmDialog(context, http.Client(), fromId, toId);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.red[900],
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: 300,
                    height: 40,
                    child: RaisedButton(
                      child: Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.white)
                      ),
                      color: Colors.black,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
          );
        }
    );
  }

  Future _deleteConfirmDialog(BuildContext context,  http.Client client, int fromId, int toId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Confirm delete',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure want to delete?', style: TextStyle(fontSize: 16, color: Colors.white),),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          child: RaisedButton(
                            child: Text("No", style: TextStyle(fontSize: 20, color: Colors.white),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.white)
                            ),
                            color: Colors.black,
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                        SizedBox(width: 30,),
                        Container(
                          width: 100,
                          height: 40,
                          child: RaisedButton(
                            child: Text("Yes", style: TextStyle(fontSize: 20, color: Colors.white),),
                            onPressed: () {
                              deleteMessage(context, client, fromId, toId);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.white)
                            ),
                            color: Colors.red[900],
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: list.length, itemBuilder: (context, index) {
        ChatUser msg = list[index];
      return InkWell(
          onTap: () async{
            await Navigator.of(context).push(
                PageRouteBuilder(
                    pageBuilder: (_, ___, ____) =>
                    new ChatBoardPage(friedId: msg.to_id, id : msg.from_id, friendName: msg.user_name)
                ));
            this.notifyParent();
          },
          onLongPress: () {
            _moreDetailDialog(context, msg.from_id, msg.to_id, msg.user_name);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    image: DecorationImage(
                      image: NetworkImage(msg.user_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + msg.user_pic),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  )
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
                padding: const EdgeInsets.only(bottom: 10.0, top: 7.0),
                width: MediaQuery.of(context).size.width - 80.0,
                height: 60.0,
                decoration: BoxDecoration(
                    border: Border (bottom: BorderSide(width: 1.0, color: Colors.grey[300]))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (msg.read_status == 0) ? new Container(
                          padding: const EdgeInsets.only(right: 3.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 145,
                          ),
                          child: new Text(
                            '${msg.user_name}',
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ) : new Container(
                          padding: const EdgeInsets.only(right: 3.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 145,
                          ),
                          child: new Text(
                            '${msg.user_name}',
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Flexible(
                          child: new Container(
                            padding: new EdgeInsets.only(top: 5.0),
                            child: new Text(
                              msg.date_time,
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.grey[600]
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    (msg.read_status == 0) ? Flexible(
                      child: new Container(
                        padding: new EdgeInsets.only(top: 5.0),
                        child: new Text(
                          msg.message,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ) : Flexible(
                      child: new Container(
                        padding: new EdgeInsets.only(top: 5.0),
                        child: new Text(
                          msg.message,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.grey[600]
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      );
    }
    );
  }
}