import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'dart:io';
import 'B4_Event_Perms.dart';

// ignore: must_be_immutable
class EditEventPage extends StatefulWidget{
  int userId, eventId;

  EditEventPage({this.userId, this.eventId});
  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  List<Asset> images = List<Asset>();
  File _image;
  String event_name = "", location = "", city = "", event_date = "", start_time = "", end_time = "", description = "", event_type = "", img_names = "", allow_guest = "";
  int eventType = 0;
  TextEditingController eventNameController, locationController, cityController, descriptionController;
  bool selection_enabled = true;
  int gridRows = 0;
  int oldGridRows = 0;
  List<String> old_images = List<String>();

  @override
  void initState() {
    super.initState();
    fetchEvent(http.Client()); 
  }

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<void> fetchEvent(http.Client client) async {
    String url = baseApiURL + "method=get_events&id=$userId&event_id=${widget.eventId}" ;
    
    final response = await client.get(url, headers: headers);
    Map<String, dynamic> event = jsonDecode(response.body);

    setState(() {
      event_name = event['event_name'];
      event_type = event['event_type'];
      if(event_type == "Private"){
        eventType = 1;
      }
      allow_guest = event['allow_guest'];
      event_date = event['event_date'];
      start_time = event['start_time'];
      end_time = event['end_time'];
      location = event['location'];
      city = event['city'];
      description = event['description'];
      img_names = event['pictures'];

      if(img_names != ""){
        old_images = img_names.split(",");
        oldGridRows = (old_images.length ~/ 3);
        if((old_images.length % 3) > 0){
          oldGridRows = oldGridRows + 1;
        }
      }

      eventNameController = TextEditingController(text: event_name);
      locationController = TextEditingController(text: location);
      cityController = TextEditingController(text: city);
      descriptionController = TextEditingController(text: description);
    });
  }

  cancelEvent() async {
    String url = baseApiURL + "method=cancel_event&id=$userId&event_id=${widget.eventId}" ;
    await http.Client().get(url);
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

    print(res.statusCode);
    print(respStr);

    if(res.statusCode == 200){
      setState(() {
        if(img_names == ""){
          img_names = respStr;
        }else{
          img_names = '${img_names},${respStr}';
        }
        print('img_names: ${img_names}');
      });
    }
  }

  updateEvent() async {
    for (int i = 0; i < images.length; i++) {
      var path2 = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      //var path = await images[i].filePath;
      print(path2);
      var file = await getImageFileFromAsset(path2);      
      _image = file;
      await uploadImage();
    }

    String url = baseApiURL + "method=add_event&event_id=${widget.eventId}&id=$userId&event_type=$event_type&event_name=${Uri.encodeComponent(eventNameController.text)}&address=${Uri.encodeComponent(locationController.text)}&city=${Uri.encodeComponent(cityController.text)}&description=${Uri.encodeComponent(descriptionController.text)}&event_date=${Uri.encodeComponent(event_date)}&start_time=${Uri.encodeComponent(start_time)}&end_time=${Uri.encodeComponent(end_time)}&pictures=$img_names&allow_guest=$allow_guest" ;
    await http.Client().get(url);
  }

  _deleteOldImage(String imgName){
    setState(() {
      img_names = img_names.replaceAll(",$imgName", "");
      img_names = img_names.replaceAll("$imgName,", "");
      img_names = img_names.replaceAll("$imgName", "");
      old_images.remove(imgName);
      oldGridRows = (old_images.length ~/ 3);
      if((old_images.length % 3) > 0){
        oldGridRows = oldGridRows + 1;
      }
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true, 
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
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

  Widget buildOldGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true, 
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      physics: ScrollPhysics(),
      children: List.generate(old_images.length, (index) {
        return Stack(
          children: [
            Container(
              height: 300,
              width: 300,
              child: Image.network(
                baseUploadURL + old_images[index],
                fit: BoxFit.cover
              ),
            ),            
            Container(
              height: 40,
              width: 40,
              color: Colors.red,
              child: IconButton(
                icon: new Icon(Icons.delete_forever, color: Colors.white),
                highlightColor: Colors.white,
                onPressed: (){_deleteOldImage(old_images[index]);},
              ),
            )
          ],
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

  int time_var = 0;

  void callTimePicker() async {
    var time = await getTime();
    setState(() {
      if(time_var == 0)
        start_time = "${time.hour}:${time.minute}";
      else
        end_time = "${time.hour}:${time.minute}";
    });
  }

  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      event_date = "${order.year}-${order.month}-${order.day}";
    });
  }

  Future<TimeOfDay> getTime(){
    return showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
  }

  Future<DateTime> getDate() {
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
        title: Text("Edit Event",
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
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new EventPerms(
                        event_id: widget.eventId,
                        user_id: userId
                      ),
                  transitionDuration: Duration(milliseconds: 600),
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }));
                },
                child: Text("Manage Permissions",style: TextStyle(fontSize: 16.0, color: Color(0xFFAD2829))),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Event Type",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
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
                child: Text("Allow Guests",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
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
                  hintText: 'Please enter event name',
                  labelText: 'Event Name',
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Event Date",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${event_date}",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
                  IconButton(
                    icon: new Icon(Icons.calendar_today_sharp, color: Colors.blue),
                    highlightColor: Colors.blue,
                    onPressed: (){callDatePicker();},
                  ),   
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Start Time",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${start_time}",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
                  IconButton(
                    icon: new Icon(Icons.lock_clock, color: Colors.blue),
                    highlightColor: Colors.blue,
                    onPressed: (){
                      setState(() {
                        time_var = 0;
                      });
                      callTimePicker();
                    },
                  ),   
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("End Time",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${end_time}",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
                  IconButton(
                    icon: new Icon(Icons.lock_clock, color: Colors.blue),
                    highlightColor: Colors.blue,
                    onPressed: (){
                      setState(() {
                        time_var = 1;
                      });
                      callTimePicker();
                    },
                  ),   
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Please enter event location',
                  labelText: 'Add Location',
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'Please enter city',
                  labelText: 'Add City',
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            Visibility (
              visible: (img_names == "")? false:true,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Existing Pictures",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
              ),
            ),
            Visibility (
              visible: (img_names == "")? false:true,
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.34 * oldGridRows,
                child: buildOldGridView()
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Upload New Pictures",style: TextStyle(fontSize: 14.0, color: Colors.black45)),
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
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Write your message here',
                  labelText: 'Message',
                  labelStyle: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
                maxLines: 3
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[              
                  ButtonTheme(
                    minWidth: 100.0,
                    height: 50.0,
                    buttonColor: Color(0xFFAD2829),
                    child: RaisedButton(
                      onPressed: () {
                        updateEvent();
                        _showDialog(context, "Updated");
                      },                  
                      child: Text("Update Event", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 100.0,
                    height: 50.0,
                    buttonColor: Color(0xFFAD2829),
                    child: RaisedButton(
                      onPressed: () {
                        cancelEvent();
                        _showDialog(context, "Cancelled");
                      },                  
                      child: Text("Cancel Event", style: TextStyle(color: Colors.white),),
                    ),
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}

_showDialog(BuildContext ctx, String ev) {
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
                        Navigator.pop(ctx);
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
                  "Event $ev Successfully!!",
                  style: TextStyle(fontSize: 17.0),
                ),
              )),
        ],
      );
    }
  );
}