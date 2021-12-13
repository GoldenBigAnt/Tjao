import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';

import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/message.dart';

// ignore: must_be_immutable
class ChatBoardPage extends StatefulWidget {
  int id, friedId;
  String friendName;
  ChatBoardPage({this.id, this.friedId, this.friendName});
  @override
  ChatBoardPageState createState() => ChatBoardPageState();
}

class ChatBoardPageState extends State<ChatBoardPage> {
  TextEditingController msgController;
  Future<List<Message>> messages;

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

  Future<List<Message>> fetchMessageHistory(http.Client client) async{
    String currentTime = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}";
    String url = baseApiURL + "method=get_chat&from_id=${widget.id}&to_id=${widget.friedId}&curr_time=${Uri.encodeComponent(currentTime)}";
    final response = await client.get(url, headers: headers);
    return compute(parseMessages, response.body);
  }

  sendMessage() async {
    String msg = msgController.text.trim();
    if(msg != "") {
      String url = baseApiURL + "method=add_chat&from_id=${widget.id}&to_id=${widget.friedId}&message=${Uri.encodeComponent(msg)}" ;
      final response = await http.Client().get(url);
      print("response = ${response.body}");
    }   
    msgController.clear();
  }

  @override
  void initState() {
    msgController = TextEditingController(text: "");
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
            widget.friendName,
            style: TextStyle(
              fontFamily: "Popins",
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(5,5,5,60),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/image/chat_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: FutureBuilder<List<Message>>(
              future: messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Container(height: 0.0,);
                return (snapshot.hasData && snapshot.data.length > 0)
                    ? ShowMessageScreen(
                      list: snapshot.data,
                      selfId: widget.id,
                    ) : Container();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width - 65.0,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 20.0,
                            color: Colors.black12.withOpacity(0.3)),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: msgController,
                          minLines: 1,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 500,
                          autofocus:false ,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            
                          },
                          decoration: new InputDecoration.collapsed(
                            hintText: 'Type a message',
                          ),
                        ),
                      )
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      sendMessage();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      height: 50,
                      width: 50,                  
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Icon(
                        Icons.double_arrow_sharp,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    )
                  )
                ],
              ),
            )
          ),
        ],
      )
    );
  }
}

// ignore: must_be_immutable
class ShowMessageScreen extends StatelessWidget{
  ShowMessageScreen({this.list, this.selfId});
  final List<Message> list;
  final int selfId;
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    int prevFromId = 0;
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: ListView.builder(    
        controller: _scrollController,
        reverse: true,
        shrinkWrap: true,              
        scrollDirection: Axis.vertical,
        itemCount: list.length, itemBuilder: (context, index) {
          Message msg = list[index];
          if(msg.from_id == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    color: Colors.blue[50],
                  ),                  
                  height: 30.0,
                  constraints: BoxConstraints(
                    maxWidth: 150,
                    minWidth: 80.0,
                  ),
                  child: Text(msg.message, textAlign: TextAlign.center,)
                )
              ],
            );
          }
          else {
            prevFromId = list[index + 1].from_id;
            return Row(
              mainAxisAlignment: (selfId == msg.from_id) ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: ((msg.message.length * 10.0) + 50.0),
                  margin: (prevFromId == msg.from_id) ? const EdgeInsets.only(top: 3.0):const EdgeInsets.only(top: 10.0),
                  constraints: BoxConstraints(
                      maxHeight: double.infinity,
                      maxWidth: MediaQuery.of(context).size.width - 65.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    color: (selfId == msg.from_id)?Colors.green[50]:Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12.withOpacity(0.2),
                          spreadRadius: 0.2,
                          blurRadius: 0.5)
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top:5.0, left:5.0, right:5.0,bottom:1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxHeight: double.infinity,
                                  maxWidth: MediaQuery.of(context).size.width - 75.0,
                                  minWidth: 50.0
                              ),
                              child: Text(msg.message, softWrap: true,),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(msg.date_time, style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.right,)
                          ],
                        ),                      
                      ],
                    )
                  )
                ),
              ],
            );
          }          
        }
      )
    );
  }
}

