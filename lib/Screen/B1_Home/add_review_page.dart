import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';

import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';


// ignore: must_be_immutable
class AddReviewPage extends StatefulWidget {
  int clubId;
  String clubName;
  String review = "";
  int rating = 1;
  int userId;
  AddReviewPage({this.userId, this.clubId, this.clubName});
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  TextEditingController reviewController;
  FocusNode _focusNode;
  File _image;
  String filename;

  @override
  void initState() {
    reviewController = TextEditingController(text: widget.review);
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  Future selectPhoto() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      if(image != null){
        setState(() {
          _image = image;
          filename = basename(_image.path);
          //uploadImage();
        });
      }      
    });
  }

  updateReview(BuildContext context) async {
    String rev = Uri.encodeComponent(reviewController.text);
    if(_image == null) {
      String url = baseApiURL + "method=add_review&id=$userId&bar_id=${widget.clubId}&rating=${widget.rating}&review=$rev" ;
    
      final response =  await http.Client().get(url);
      print("response = ${response.body}");
    } else {
      var request = http.MultipartRequest('POST', Uri.parse(baseParseURL));
      request.files.add(
        http.MultipartFile.fromBytes(
          'picture',
          _image.readAsBytesSync(),
          filename: _image.path.split("/").last
        )
      );
      request.fields['rating'] = '${widget.rating}';
      request.fields['bar_id'] = '${widget.clubId}';
      request.fields['review'] = '$rev';
      request.fields['user_id'] = '$userId';
      final res = await request.send();
      final respStr = await res.stream.bytesToString();
    }
    _showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    List<int> text = [1,2,3,4,5];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 10.0,
        title: Text("Add Review",
            style: TextStyle(
              fontFamily: "Popins",
              fontSize: 17.0,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Text("Rate your experience",style: TextStyle(fontFamily: "Popins",fontSize: 17.0,)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 20.0, top: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  for ( var i in text )
                  InkWell(   
                    onTap: () {                          
                      setState(() {
                          widget.rating = i;
                      });
                    },                     
                    child: Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        //color: Colors.red[300],
                        color: widget.rating >= i? Colors.black: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: FittedBox(
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                          ),
                        )
                      ),
                    ),
                  ),
                ]
              )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Text("Add Photo",style: TextStyle(fontFamily: "Popins",fontSize: 17.0,)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 20.0, top: 10.0),
              child: Container(
                  height: 100.0,
                  width: 100.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(80.0)),
                      color: Colors.blueAccent,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.1),
                            blurRadius: 10.0,
                            spreadRadius: 4.0)
                      ]),
                  child: _image == null
                      ? new Stack(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 170.0,
                              backgroundImage:
                                  NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png'),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: () {
                                  selectPhoto();
                                },
                                child: Container(
                                  height: 45.0,
                                  width: 45.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0)),
                                    color: Colors.blueAccent,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : new CircleAvatar(
                          backgroundImage: new FileImage(_image),
                          radius: 220.0,
                        ),
                ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Text("Write a review",style: TextStyle(fontFamily: "Popins",fontSize: 17.0,)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Container(
                height: 150.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10.0,
                          color: Colors.black12.withOpacity(0.1)
                      ),
                    ],
                    color: Colors.white,
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: reviewController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    autofocus:false ,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      _focusNode.unfocus();
                    },
                    decoration: new InputDecoration.collapsed(
                      hintText: 'Write here',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60.0, right: 60.0, bottom: 15.0),
              child: InkWell(
                onTap: () {
                  updateReview(context);
                },
                child: Container(
                  height: 50.0,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                        "Submit Review",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins"
                        )
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

_showDialog(BuildContext ctx) {
  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (ctx) {
      return SimpleDialog(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30.0,
                      ))),
              SizedBox(
                width: 10.0,
              )
            ],
          ),
          Container(
              padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
              color: Colors.white,
              child: Icon(
                Icons.check_circle,
                size: 150.0,
                color: Colors.green,
              )),
          Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Success",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22.0),
                ),
              )),
          Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  "Review posted successfully!!",
                  style: TextStyle(fontSize: 17.0),
                ),
              )),
        ],
      );
    }
  );
}