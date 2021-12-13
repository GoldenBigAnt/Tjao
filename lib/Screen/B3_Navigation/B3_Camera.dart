import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';

import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';

// ignore: must_be_immutable
class CameraPage extends StatefulWidget {
  int userId;
  CameraPage({this.userId});
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File _image;
  String filename;
  bool isLoading = false;

  Future selectPhoto(BuildContext context) async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      if(image != null){
        setState(() {
          _image = image;
          filename = basename(_image.path);
          print('selected image: $filename');
          uploadImage(context);
        });
      }      
    });
  }

  Future<void> getimageditor(BuildContext context)  {
    final geteditimage =   Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return new ImageEditorPro(
            appBarColor: Colors.blue,
            bottomBarColor: Colors.blue,
          );
        }
    )).then((geteditimage){
      if(geteditimage != null){
        setState(() {
          isLoading = true;
          _image =  geteditimage;
          filename = basename(_image.path);
          print('selected image: $filename');
          uploadImage(context);
        });
      }
    }).catchError((er){print(er);});

  }

  uploadImage(BuildContext context) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseParseURL));
    request.files.add(
      http.MultipartFile.fromBytes(
        'picture',
        _image.readAsBytesSync(),
        filename: _image.path.split("/").last
      )
    );
    request.fields['user_id'] = '$userId';
    final res = await request.send();
    final respStr = await res.stream.bytesToString();

    if(res.statusCode == 200){
      _showDialog(context);
    }
      
  }

  @override
  Widget build(BuildContext context) {
    if(_image == null){
      selectPhoto(context);
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: IconButton(
          icon: new Icon(Icons.camera_alt, color: Colors.grey),
          onPressed: (){
            selectPhoto(context);
            // getimageditor(context);
          },
        ),  
      )
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
                  "Photo uploaded successfully!!",
                  style: TextStyle(fontSize: 17.0),
                ),
              )),
        ],
      );
    }
  );
}