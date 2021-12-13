
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'dart:io';

import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/user.dart';

// ignore: must_be_immutable
class AddEventPage extends StatefulWidget{
  int userId;
  AddEventPage({this.userId});
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  List<Asset> images = List<Asset>();
  File _image;
  TextEditingController eventNameController, locationController, cityController, descriptionController;
  int eventType = 0;
  String event_type = "Public";
  String allow_guest = "Yes";
  String img_names = "";
  bool selection_enabled = true;
  int gridRows = 0;
  Future<List<User>> friends;
  List<int> selectedFriends = List<int>();
  String search = "";

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController(text: "");
    locationController = TextEditingController(text: "");
    cityController = TextEditingController(text: "");
    descriptionController = TextEditingController(text: "");
    friends = fetchFriends(http.Client());
  }
  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };
  Future<List<User>> fetchFriends(http.Client client) async{
    String url = baseApiURL + "method=get_my_friends&id=$userId" ;
    final response = await client.get(url, headers: headers);
    return compute(parseMyFriend, response.body);
  }

  Future<void> checkAndRequestCameraPermissions() async {
    bool perm = false;
    if (await Permission.camera.request().isGranted) {
      perm = true;
    }else{
      perm = false;
    }

    if(perm){
      loadAssets();
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#ad2829",
          actionBarTitle: "Select Photos",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {

    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      getFileList();
    });
  }

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  void getFileList() async {
    if(images.length > 0){
      setState(() {
        selection_enabled = false;
        if(images.length > 3){
          gridRows = 2;
        }else{
          gridRows = 1;
        }
      });
    }else{
      gridRows = 0;
    }
  }

  addEvent() async {
    for (int i = 0; i < images.length; i++) {
      var path2 = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      //var path = await images[i].filePath;
      print(path2);
      var file = await getImageFileFromAsset(path2);
      _image = file;
      await uploadImage();
    }

    String friends = "";
    for (int i = 0; i < selectedFriends.length; i++) {
      if(friends == ""){
        friends = "${selectedFriends[i]}";
      }else{
        friends = "$friends,${selectedFriends[i]}";
      }
    }

    String url = baseApiURL + "method=add_event&id=$userId&event_type=$event_type&event_name=${Uri.encodeComponent(eventNameController.text)}&address=${Uri.encodeComponent(locationController.text)}&city=${Uri.encodeComponent(cityController.text)}&description=${Uri.encodeComponent(descriptionController.text)}&event_date=${Uri.encodeComponent(finalDate)}&start_time=${Uri.encodeComponent(startTime)}&end_time=${Uri.encodeComponent(endTime)}&pictures=$img_names&allow_guest=$allow_guest&friends=$friends";
    await http.Client().get(url);
  }

  Future uploadImage() async {
    var request = http.MultipartRequest('POST', Uri.parse(baseParseURL));
    request.files.add(
        http.MultipartFile.fromBytes(
            'picture',
            _image.readAsBytesSync(),
            filename: _image.path.split("/").last
        )
    );
    final res = await request.send();
    final respStr = await res.stream.bytesToString();

    if(res.statusCode == 200){
      setState(() {
        if(img_names == ""){
          img_names = respStr;
        }else{
          img_names = '$img_names,$respStr';
        }
      });
    }
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      eventType = value;
      if(value == 0){
        event_type = "Public";
        allow_guest = "Yes";
      }else{
        event_type = "Private";
      }
    });
  }

  String finalDate = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  String startTime = "${DateTime.now().hour}:${DateTime.now().minute}";
  String endTime = "${DateTime.now().hour}:${DateTime.now().minute}";

  int time_var = 0;

  void callTimePicker(BuildContext context) async {
    var time = await getTime(context);
    setState(() {
      if(time_var == 0)
        startTime = "${time.hour}:${time.minute}";
      else
        endTime = "${time.hour}:${time.minute}";
    });
  }

  void callDatePicker(BuildContext context) async {
    var order = await getDate(context);
    setState(() {
      finalDate = "${order.year}-${order.month}-${order.day}";
    });
  }

  Future<TimeOfDay> getTime(BuildContext  context){
    return showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
  }

  Future<DateTime> getDate(BuildContext context) {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
  }

  void updateFriendList(bool add, int id){
    setState(() {
      if(add){
        selectedFriends.add(id);
      }else{
        selectedFriends.remove(id);
      }
    });
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
          title: Text("Add Event",
            style: TextStyle(
                fontFamily: "Sofia",
                fontWeight: FontWeight.w800,
                fontSize: 28.0,
                letterSpacing: 1.5,
                color: Colors.black
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /*SizedBox(
              height: 30.0,
            ),*/
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Event Type",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: eventType,
                            onChanged: (val) {
                              handleRadioValueChanged(val);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              'Public',
                              style: new TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black
                              ),
                            ),
                          ),
                          Radio(
                            value: 1,
                            groupValue: eventType,
                            onChanged: (val) {
                              handleRadioValueChanged(val);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              'Private',
                              style: new TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Visibility(
                    visible: eventType > 0? true: false,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("Allow Guests",style: TextStyle(fontSize: 14.0, color: Colors.black)),
                    ),
                  ),
                  Visibility(
                      visible: eventType > 0? true: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: "Yes",
                            groupValue: allow_guest,
                            onChanged: (val) {
                              setState(() {
                                allow_guest = val;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              'Yes',
                              style: new TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          Radio(
                            value: "No",
                            groupValue: allow_guest,
                            onChanged: (val) {
                              setState(() {
                                allow_guest = val;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              'No',
                              style: new TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: eventNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        hintText: 'Please enter event name',
                        labelText: 'Event Name',
                        labelStyle: new TextStyle(color: Colors.black, fontSize: 16),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Event Date",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          Container(
                            child: Row(
                              children: [
                                Text("${finalDate}",style: TextStyle(fontSize: 14.0, color: Colors.black)),
                                IconButton(
                                  icon: new Icon(Icons.calendar_today_sharp, color: Colors.blue),
                                  highlightColor: Colors.blue,
                                  onPressed: (){callDatePicker(context);},
                                ),
                              ],
                            ),
                          ),

                        ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Start Time",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          Container(
                            child: Row(
                              children: [
                                Text("${startTime}",style: TextStyle(fontSize: 14.0, color: Colors.black)),
                                IconButton(
                                  icon: new Icon(Icons.lock_clock, color: Colors.blue),
                                  highlightColor: Colors.blue,
                                  onPressed: (){
                                    setState(() {
                                      time_var = 0;
                                    });
                                    callTimePicker(context);
                                  },
                                ),
                              ],
                            ),
                          )

                        ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("End Time",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                          Container(
                            child: Row(
                              children: [
                                Text("${endTime}",style: TextStyle(fontSize: 14.0, color: Colors.black)),
                                IconButton(
                                  icon: new Icon(Icons.lock_clock, color: Colors.blue),
                                  highlightColor: Colors.blue,
                                  onPressed: (){
                                    setState(() {
                                      time_var = 1;
                                    });
                                    callTimePicker(context);
                                  },
                                ),
                              ],
                            ),
                          )

                        ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        hintText: 'Please enter event location',
                        labelText: 'Add Location',
                        labelStyle: new TextStyle(color: Colors.black, fontSize: 16),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                    child: TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        hintText: 'Please enter city',
                        labelText: 'Add City',
                        labelStyle: new TextStyle(color: Colors.black, fontSize: 16),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Upload Event Pictures",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      width: 100,
                      child: OutlineButton(
                        onPressed: () {
                          checkAndRequestCameraPermissions();
                        },
                        borderSide: BorderSide(
                          color: Colors.grey, //Color of the border
                          style: BorderStyle.solid, //Style of the border
                          width: 0.8, //width of the border
                        ),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Text("Browse..", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.width * 0.34 * gridRows,
                      child: buildGridView()
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Invite Contacts",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        prefixIcon: Icon(Icons.search),
                        labelText: "Search for friends...",
                        labelStyle: new TextStyle(color: Colors.black, fontSize: 16.0),
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
                      child: FutureBuilder<List<User>>(
                        future: friends,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);
                          return snapshot.hasData
                              ? MyFriendScreen(
                            list: snapshot.data,
                            notifyParent: updateFriendList,
                            selectedFriends: selectedFriends,
                            search: search,
                          ) : Center(child: CircularProgressIndicator());
                        },
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Write your message here',
                          labelText: 'Message',
                          labelStyle: new TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        maxLines: 3
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ButtonTheme(
                        minWidth: double.infinity,
                        height: 50.0,
                        buttonColor: Color(0xFFAD2829),
                        child: RaisedButton(
                          onPressed: () {
                            addEvent();
                            _showDialog(context);
                          },
                          child: Text("Add Event", style: TextStyle(color: Colors.white),),
                        ),
                      )
                  ),
                  SizedBox(height: 20,)
                ]
            )
        )
    );
  }
}


class MyFriendScreen extends StatelessWidget{
  MyFriendScreen({this.list, @required this.notifyParent, this.selectedFriends, this.search});
  final List<User> list;
  final notifyParent;
  final List<int> selectedFriends;
  final String search;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.map<Widget>((friend) {
            return (search == "" || friend.name.toLowerCase().startsWith(search.toLowerCase()))?Padding(
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
                                      image: NetworkImage(friend.profile_pic == ''? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png': baseUploadURL + friend.profile_pic),
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
                                child: Text("${friend.name}", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w700),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    OutlineButton(
                      onPressed: () async{
                        if(selectedFriends.contains(friend.id)){
                          this.notifyParent(false, friend.id);
                        }else{
                          this.notifyParent(true, friend.id);
                        }
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
                          Text((selectedFriends.contains(friend.id))?"Remove":"Invite", style: TextStyle(fontSize: 12, color: Colors.red[200])),
                        ],
                      ),
                    )
                  ]
              ),
            ):Container();
          }).toList(),
        )
    );
  }
}

_showDialog(BuildContext ctx) {
  showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
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
                    "Event Added Successfully!!",
                    style: TextStyle(fontSize: 17.0),
                  ),
                )),
          ],
        );
      }
  );
}