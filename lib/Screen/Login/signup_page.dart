import 'package:tjao/Library/loader_animation/loader.dart';
import 'package:tjao/Library/loader_animation/dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tjao/helper/helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/app_config.dart';
import 'login_page.dart';
import 'otp_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isSelected = false;
  String filename;
  File tempImage;
  File _image;
  bool isLoading = false;
  bool _isTerm = false;
  String otp;
  String profilePic;
  String country = "Denmark";
  String countryCode = "+45";
  String error;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  String _email, _pass, _name, _city, mobile_no;
  var profilePicUrl, profilePicName = "";
  TextEditingController signupEmailController = new TextEditingController();
  //TextEditingController signupCountryController = new TextEditingController();
  TextEditingController signupMobileController = new TextEditingController();
  TextEditingController signupCityController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController = new TextEditingController();
  List<Country> countryList = Country.getCountryList();
  List<DropdownMenuItem<Country>> _dropdownMenuItems;
  Country _selectedCountry;

  List<DropdownMenuItem<Country>> buildDropdownMenuItems(List countries) {
    List<DropdownMenuItem<Country>> items = List();
    for (Country c in countries) {
      items.add(
        DropdownMenuItem(
          value: c,
          child: Text(c.name),
        ),
      );
    }
    return items;
  }

  // Overriding initState() method to set initial state of Stateful widget
  @override
  void initState(){
    _dropdownMenuItems = buildDropdownMenuItems(countryList);
    _selectedCountry = _dropdownMenuItems[58].value;
    super.initState();
  }

  onChangeDropdownItem(Country selectedCountry) {
    setState(() {
      _selectedCountry = selectedCountry;
      country = _selectedCountry.name;
      countryCode = _selectedCountry.code;
    });
  }
  ///
  /// Response file from image picker
  ///
  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
        } else {}
      });
    } else {}
  }

  ///
  /// Get data from gallery image
  ///
  Future selectPhotoOld() async {
    tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = tempImage;
      filename = basename(_image.path);
      uploadImage();

      retrieveLostData();
    });
  }

  Future selectPhoto() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      if(image != null){
        setState(() {
          _image = image;
          filename = basename(_image.path);
          uploadImage();
        });
      }      
    });
  }

  Future uploadImage() async {
    var request = http.MultipartRequest('POST', Uri.parse(baseApiURL));
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
        profilePicName = respStr;
        profilePicUrl = baseUploadURL + respStr;
      });
    }
  }

   _signUp(BuildContext context) async {
     String url = baseApiURL + "method=signup&email=$_email&password=$_pass&name=${Uri.encodeComponent(_name)}&country=${Uri.encodeComponent(country)}&city=${Uri.encodeComponent(_city)}&mobile_no=$mobile_no&status=pending" ;
     if(profilePicName != null && profilePicName != ''){
       url = baseApiURL + "method=signup&email=$_email&password=$_pass&name=${Uri.encodeComponent(_name)}&country=${Uri.encodeComponent(country)}&city=${Uri.encodeComponent(_city)}&mobile_no=$mobile_no&profile_pic=$profilePicName&status=pending" ;
     }
     final response = await http.Client().get(url);
     print(response.body);

     Map<String, dynamic> user = jsonDecode(response.body);
     setState(() {
       isLoading = false;
       if(user['error'] != null) {
         error = user['error'];
       } else {
         userId = user['user_id'];
         otp = user['otp'];
         if(user['profile_pic'] != null && user['profile_pic'] != ''){
           profilePic = user['profile_pic'];
         }
       }
     });
     if(userId > 0){
       Navigator.of(context).push(PageRouteBuilder(
           pageBuilder: (_, __, ___) => new OtpPage(userId: userId, profilePic: profilePic, actualOtp: otp,)
       ));
     }
  }

  
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  ///
  /// Show password
  ///
  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  ///
  /// Show password
  ///
  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16.0,
        height: 16.0,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.0, color: Colors.black)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
      );

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          width: ScreenUtil().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: true);

    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: isLoading ? Center(
          child: ColorLoader5(
            dotOneColor: Colors.red,
            dotTwoColor: Colors.blueAccent,
            dotThreeColor: Colors.green,
            dotType: DotType.circle,
            dotIcon: Icon(Icons.adjust),
            duration: Duration(seconds: 1),
          )
      )
      : Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                /*Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Image.asset(
                    "assets/image/image_01.png",
                    height: 250.0,
                  ),
                ),*/
                Expanded(
                  child: Container(),
                ),
                //Image.asset("assets/image/image_02.png")
              ],
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Center(
                      child: new Container(
                        width: 150,
                        height: 70,
                        child: new ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Image.asset(
                            'assets/image/logo.png',
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      )
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(80),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.08),
                                offset: Offset(0.0, 15.0),
                                blurRadius: 15.0),
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.01),
                                offset: Offset(0.0, -10.0),
                                blurRadius: 10.0),
                          ]),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 0.0, right: 0.0, top: 0.0),
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 120.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(80.0)),
                                  color: Color(0xFFAD2829),
                                ),
                                child: Center(
                                  child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                          fontSize: ScreenUtil()
                                              .setSp(32),
                                          fontFamily: "Sofia",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: .63
                                      )),
                                ),
                              ),
                              SizedBox(
                                height:
                                    ScreenUtil().setHeight(30),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: 100.0,
                                            width: 100.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            50.0)),
                                                color: Colors.blueAccent,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black12
                                                          .withOpacity(0.1),
                                                      blurRadius: 10.0,
                                                      spreadRadius: 4.0)
                                                ]),
                                            child: _image == null
                                                ? new Stack(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors
                                                                .blueAccent,
                                                        radius: 400.0,
                                                        backgroundImage:
                                                            AssetImage(
                                                          "assets/image/emptyProfilePicture.png",
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: InkWell(
                                                          onTap: () {
                                                            selectPhoto();
                                                          },
                                                          child: Container(
                                                            height: 30.0,
                                                            width: 30.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          50.0)),
                                                              color: Colors
                                                                  .blueAccent,
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                                size: 18.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : new CircleAvatar(
                                                    backgroundImage:
                                                        new FileImage(
                                                            _image),
                                                    radius: 220.0,
                                                  ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            "Profile Picture",
                                            style: TextStyle(
                                                fontFamily: "Sofia",
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text("Name",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize:
                                                ScreenUtil()
                                                    .setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600)),
                                    TextFormField(
                                      validator: (input) {
                                        if (input.isEmpty) {
                                          return 'Please input your name';
                                        }
                                      },
                                      onSaved: (input) => _name = input,
                                      controller: signupNameController,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: TextStyle(
                                          fontFamily: "WorkSofiaSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          FontAwesomeIcons.user,
                                          size: 19.0,
                                          color: Colors.black45,
                                        ),
                                        hintText: "Name",
                                        hintStyle: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: 15.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text("Country",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize:
                                                ScreenUtil()
                                                    .setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600)),
                                    /*TextFormField(
                                      validator: (input) {
                                        if (input.isEmpty) {
                                          return 'Please input your country';
                                        }
                                      },
                                      onSaved: (input) => _country = input,
                                      controller: signupCountryController,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: TextStyle(
                                          fontFamily: "WorkSofiaSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          FontAwesomeIcons.university,
                                          size: 19.0,
                                          color: Colors.black45,
                                        ),
                                        hintText: "Country",
                                        hintStyle: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: 15.0),
                                      ),
                                    ),*/
                                    Container(
                                      padding: const EdgeInsets.only(top: 14.0,),
                                      width: double.infinity,
                                      height: 40.0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          new Icon(
                                                FontAwesomeIcons.university,
                                                size: 19.0,
                                                color: Colors.black45,
                                              ),
                                          SizedBox(width: 15.0),
                                          new Flexible(
                                            child: Theme(
                                              data: ThemeData(
                                                highlightColor: Colors.white,
                                                hintColor: Colors.white,
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: _selectedCountry,
                                                  icon: Icon(Icons.arrow_drop_down),
                                                  iconSize: 30,
                                                  elevation: 16,
                                                  style: TextStyle(color: Colors.black),
                                                  onChanged: onChangeDropdownItem,
                                                  items: _dropdownMenuItems,
                                                ),
                                              )
                                            ),
                                          )
                                        ]
                                      )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                        "Mobile Number",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: ScreenUtil().setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600
                                        )
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 14.0,),
                                      width: double.infinity,
                                      height: 45.0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          new Icon(
                                                FontAwesomeIcons.mobile,
                                                size: 19.0,
                                                color: Colors.black45,
                                              ),
                                          SizedBox(width: 15.0),
                                          new Flexible(
                                            child: Text(
                                                "$countryCode",
                                              style: TextStyle(
                                                fontFamily: "Sofia",
                                                fontSize: 16.0,
                                                letterSpacing: .7
                                              )
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          new Flexible(
                                            child: TextFormField(
                                            // ignore: missing_return
                                            validator: (input) {
                                              if (input.isEmpty) {
                                                return 'Please input your mobile number';
                                              }
                                            },
                                            onSaved: (input) => mobile_no = countryCode + input,
                                            controller: signupMobileController,
                                            keyboardType: TextInputType.number,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            style: TextStyle(
                                                fontFamily: "WorkSofiaSemiBold",
                                                fontSize: 16.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Mobile Number",
                                              hintStyle: TextStyle(
                                                  fontFamily: "Sofia",
                                                  fontSize: 15.0
                                              ),
                                            ),
                                          ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                        "City",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: ScreenUtil().setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600
                                        )
                                    ),
                                    TextFormField(
                                      // ignore: missing_return
                                      validator: (input) {
                                        if (input.isEmpty) {
                                          return 'Please input your city';
                                        }
                                      },
                                      onSaved: (input) => _city = input,
                                      controller: signupCityController,
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization.words,
                                      style: TextStyle(
                                          fontFamily: "WorkSofiaSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.location_city,
                                          size: 22.0,
                                          color: Colors.black45,
                                        ),
                                        hintText: "City",
                                        hintStyle: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: 15.0
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text("Email",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize:
                                                ScreenUtil()
                                                    .setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600)),
                                    TextFormField(
                                      validator: (input) {
                                        if (input.isEmpty) {
                                          return 'Please input your email';
                                        }
                                      },
                                      onSaved: (input) => _email = input,
                                      controller: signupEmailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      style: TextStyle(
                                          fontFamily: "WorkSofiaSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          FontAwesomeIcons.envelope,
                                          color: Colors.black45,
                                          size: 18.0,
                                        ),
                                        hintText: "Email Address",
                                        hintStyle: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text("Password",
                                        style: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize:
                                                ScreenUtil()
                                                    .setSp(30),
                                            letterSpacing: .9,
                                            fontWeight: FontWeight.w600)),
                                    TextFormField(
                                      controller: signupPasswordController,
                                      obscureText: _obscureTextSignup,
                                      validator: (input) {
                                        if (input.isEmpty) {
                                          return 'Please input your password';
                                        } if (input.length<8){
                                            return 'Input more 8 character';
                                        }
                                      },
                                      onSaved: (input) => _pass = input,
                                      style: TextStyle(
                                          fontFamily: "WorkSofiaSemiBold",
                                          fontSize: 16.0,
                                          color: Colors.black45),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          FontAwesomeIcons.lock,
                                          color: Colors.black45,
                                          size: 18.0,
                                        ),
                                        hintText: "Password",
                                        hintStyle: TextStyle(
                                            fontFamily: "Sofia",
                                            fontSize: 16.0),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            _toggleSignup();
                                          },
                                          child: Icon(
                                            FontAwesomeIcons.eye,
                                            size: 15.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),

                                    SizedBox(
                                      height: ScreenUtil()
                                          .setHeight(35),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(20)),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: Colors.blue,
                          value: this._isTerm,
                          onChanged: (bool value) {
                            setState(() {
                              this._isTerm = value;
                            });
                          },
                        ),
                        Text('Accept',style: TextStyle(fontSize: 16.0, fontFamily: "Sofia",), ),
                        SizedBox(width: 10,),
                        GestureDetector(
                          child: Text("Terms & Conditions", style: TextStyle(
                            fontSize: 15, color: Color(0xff007AFF),decoration: TextDecoration.underline,),
                          ),
                          onTap: () async {
                            await launch('https://www.tjaoapp.com/kopi-af-privacy-policy');
                          },
                        )
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setHeight(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 12.0,
                            ),
                            GestureDetector(
                              onTap: _radio,
                              child: radioButton(_isSelected),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                                "Remember me",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Poppins-Medium"
                                ))
                          ],
                        ),
                        Container(
                          width: ScreenUtil().setWidth(330),
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                _isTerm ? Color(0xFFf8c301) : Colors.grey,
                                _isTerm ? Color(0xFFAD2829) : Colors.grey[800]
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFAD2829).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0
                                )
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isTerm ? () async {
                                final formState = _registerFormKey.currentState;
                                if (formState.validate()) {
                                  formState.save();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await _signUp(context);

                                }
                                else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text("Please input all form"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Close"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                              } : null,
                              child: Center(
                                child: Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 18,
                                        letterSpacing: 1.0
                                    )
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(40),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        horizontalLine(),
                        Text("Have Account?",
                            style: TextStyle(
                                fontSize: 13.0, fontFamily: "Sofia")),
                        horizontalLine()
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => LoginPage()));
                          },
                          child: Container(
                            height: 50.0,
                            width: 300.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                              border: Border.all(
                                  color: Color(0xFFAD2829), width: 1.0),
                            ),
                            child: Center(
                              child: Text("Sign In",
                                  style: TextStyle(
                                      color: Color(0xFFAD2829),
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1.4,
                                      fontSize: 15.0,
                                      fontFamily: "Sofia")),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              ),
            )
          ],
      ),
    );
  }
}

class Country {
  int id;
  String name;
  String code;
 
  Country(this.id, this.name, this.code);
 
  static List<Country> getCountryList() {
    return <Country>[
      Country(0,'Aaland Islands','+358'),
      Country(1,'Afghanistan','+93'),
      Country(2,'Albania','+355'),
      Country(3,'Algeria','+213'),
      Country(4,'American Samoa','+1-684'),
      Country(5,'Andorra','+376'),
      Country(6,'Angola','+244'),
      Country(7,'Anguilla','+1-264'),
      Country(8,'Antarctica','+672'),
      Country(9,'Antigua and Barbuda','+1-268'),
      Country(10,'Argentina','+54'),
      Country(11,'Armenia','+374'),
      Country(12,'Aruba','+297'),
      Country(13,'Australia','+61'),
      Country(14,'Austria','+43'),
      Country(15,'Azerbaijan','+994'),
      Country(16,'Bahamas','+1-242'),
      Country(17,'Bahrain','+973'),
      Country(18,'Bangladesh','+880'),
      Country(19,'Barbados','+1-246'),
      Country(20,'Belarus','+375'),
      Country(21,'Belgium','+32'),
      Country(22,'Belize','+501'),
      Country(23,'Benin','+229'),
      Country(24,'Bermuda','+1-441'),
      Country(25,'Bhutan','+975'),
      Country(26,'Bolivia','+591'),
      Country(27,'Bosnia and Herzegowina','+387'),
      Country(28,'Botswana','+267'),
      Country(29,'Bouvet Island','+47'),
      Country(30,'Brazil','+55'),
      Country(31,'British Indian Ocean Territory','+246'),
      Country(32,'Brunei Darussalam','+673'),
      Country(33,'Bulgaria','+359'),
      Country(34,'Burkina Faso','+226'),
      Country(35,'Burundi','+257'),
      Country(36,'Cambodia','+855'),
      Country(37,'Cameroon','+237'),
      Country(38,'Canada','+1'),
      Country(39,'Cape Verde','+238'),
      Country(40,'Cayman Islands','+1-345'),
      Country(41,'Central African Republic','+236'),
      Country(42,'Chad','+235'),
      Country(43,'Chile','+56'),
      Country(44,'China','+86'),
      Country(45,'Christmas Island','+61'),
      Country(46,'Cocos (Keeling) Islands','+61'),
      Country(47,'Colombia','+57'),
      Country(48,'Comoros','+269'),
      Country(49,'Congo Democratic Republic of','+242'),
      Country(50,'Cook Islands','+682'),
      Country(51,'Costa Rica','+506'),
      Country(52,'Cote D\'Ivoire','+225'),
      Country(53,'Croatia','+385'),
      Country(54,'Cuba','+53'),
      Country(55,'Curaçao','+599'),
      Country(56,'Cyprus','+357'),
      Country(57,'Czech Republic','+420'),
      Country(58,'Denmark','+45'),
      Country(59,'Djibouti','+253'),
      Country(60,'Dominica','+1-767'),
      Country(61,'Dominican Republic','+1-809'),
      Country(62,'Ecuador','+593'),
      Country(63,'Egypt','+20'),
      Country(64,'El Salvador','+503'),
      Country(65,'Equatorial Guinea','+240'),
      Country(66,'Eritrea','+291'),
      Country(67,'Estonia','+372'),
      Country(68,'Ethiopia','+251'),
      Country(69,'Falkland Islands (Malvinas)','+500'),
      Country(70,'Faroe Islands','+298'),
      Country(71,'Fiji','+679'),
      Country(72,'Finland','+358'),
      Country(73,'France','+33'),
      Country(74,'French Guiana','+594'),
      Country(75,'French Polynesia','+689'),
      Country(76,'French Southern Territories','+'),
      Country(77,'Gabon','+241'),
      Country(78,'Gambia','+220'),
      Country(79,'Georgia','+995'),
      Country(80,'Germany','+49'),
      Country(81,'Ghana','+233'),
      Country(82,'Gibraltar','+350'),
      Country(83,'Greece','+30'),
      Country(84,'Greenland','+299'),
      Country(85,'Grenada','+1-473'),
      Country(86,'Guadeloupe','+590'),
      Country(87,'Guam','+1-671'),
      Country(88,'Guatemala','+502'),
      Country(89,'Guernsey','+44-1481'),
      Country(90,'Guinea','+224'),
      Country(91,'Guinea-bissau','+245'),
      Country(92,'Guyana','+592'),
      Country(93,'Haiti','+509'),
      Country(94,'Heard Island and McDonald Islands','+011'),
      Country(95,'Honduras','+504'),
      Country(96,'Hong Kong','+852'),
      Country(97,'Hungary','+36'),
      Country(98,'Iceland','+354'),
      Country(99,'India','+91'),
      Country(100,'Indonesia','+62'),
      Country(101,'Iran (Islamic Republic of)','+98'),
      Country(102,'Iraq','+964'),
      Country(103,'Ireland','+353'),
      Country(104,'Isle of Man','+44-1624'),
      Country(105,'Israel','+972'),
      Country(106,'Italy','+39'),
      Country(107,'Ivory Coast','+225'),
      Country(108,'Jamaica','+1-876'),
      Country(109,'Japan','+81'),
      Country(110,'Jersey','+44-1534'),
      Country(111,'Jordan','+962'),
      Country(112,'Kazakhstan','+7'),
      Country(113,'Kenya','+254'),
      Country(114,'Kiribati','+686'),
      Country(115,'Korea, Democratic People\'s Republic of','+850'),
      Country(116,'Kosovo','+383'),
      Country(117,'Kuwait','+965'),
      Country(118,'Kyrgyzstan','+996'),
      Country(119,'Lao People\'s Democratic Republic','+856'),
      Country(120,'Latvia','+371'),
      Country(121,'Lebanon','+961'),
      Country(122,'Lesotho','+266'),
      Country(123,'Liberia','+231'),
      Country(124,'Libya','+218'),
      Country(125,'Liechtenstein','+423'),
      Country(126,'Lithuania','+370'),
      Country(127,'Luxembourg','+352'),
      Country(128,'Macao','+853'),
      Country(129,'Macedonia, The Former Yugoslav Republic of','+389'),
      Country(130,'Madagascar','+261'),
      Country(131,'Malawi','+265'),
      Country(132,'Malaysia','+60'),
      Country(133,'Maldives','+960'),
      Country(134,'Mali','+223'),
      Country(135,'Malta','+356'),
      Country(136,'Marshall Islands','+692'),
      Country(137,'Martinique','+596'),
      Country(138,'Mauritania','+222'),
      Country(139,'Mauritius','+230'),
      Country(140,'Mayotte','+262'),
      Country(141,'Mexico','+52'),
      Country(142,'Micronesia, Federated States of','+691'),
      Country(143,'Moldova','+373'),
      Country(144,'Monaco','+377'),
      Country(145,'Mongolia','+976'),
      Country(146,'Montenegro','+382'),
      Country(147,'Montserrat','+1-664'),
      Country(148,'Morocco','+212'),
      Country(149,'Mozambique','+258'),
      Country(150,'Myanmar','+95'),
      Country(151,'Namibia','+264'),
      Country(152,'Nauru','+674'),
      Country(153,'Nepal','+977'),
      Country(154,'Netherlands','+31'),
      Country(155,'Netherlands Antilles','+599'),
      Country(156,'New Caledonia','+687    '),
      Country(157,'New Zealand','+64'),
      Country(158,'Nicaragua','+505'),
      Country(159,'Niger','+227'),
      Country(160,'Nigeria','+234'),
      Country(161,'Niue','+683'),
      Country(162,'Norfolk Island','+672'),
      Country(163,'Northern Mariana Islands','+1-670'),
      Country(164,'Norway','+47'),
      Country(165,'Oman','+968'),
      Country(166,'Pakistan','+92'),
      Country(167,'Palau','+680'),
      Country(168,'Palestine','+970'),
      Country(169,'Panama','+507'),
      Country(170,'Papua New Guinea','+675'),
      Country(171,'Paraguay','+595'),
      Country(172,'Peru','+51'),
      Country(173,'Philippines','+63'),
      Country(174,'Pitcairn','+64'),
      Country(175,'Poland','+48'),
      Country(176,'Portugal','+351'),
      Country(177,'Puerto Rico','+1-787'),
      Country(178,'Qatar','+974'),
      Country(179,'Reunion','+262'),
      Country(180,'Romania','+40'),
      Country(181,'Russian Federation','+7'),
      Country(182,'Rwanda','+250'),
      Country(183,'Saint Helena, Ascension and Tristan da Cunha','+290'),
      Country(184,'Saint Kitts and Nevis','+1-869'),
      Country(185,'Saint Lucia','+1-758'),
      Country(186,'Saint Vincent and the Grenadines','+1-784'),
      Country(187,'Samoa','+685'),
      Country(188,'San Marino','+378'),
      Country(189,'Sao Tome and Principe','+239'),
      Country(190,'Saudi Arabia','+966'),
      Country(191,'Senegal','+221'),
      Country(192,'Serbia','+381'),
      Country(193,'Seychelles','+248'),
      Country(194,'Sierra Leone','+232'),
      Country(195,'Singapore','+65'),
      Country(196,'Slovakia (Slovak Republic)','+421'),
      Country(197,'Slovenia','+386'),
      Country(198,'Solomon Islands','+677'),
      Country(199,'Somalia','+252'),
      Country(200,'South Africa','+27'),
      Country(201,'South Georgia and the South Sandwich Islands','+500'),
      Country(202,'South Korea','+82'),
      Country(203,'Spain','+34'),
      Country(204,'Sri Lanka','+94'),
      Country(205,'St. Pierre and Miquelon','+508'),
      Country(206,'Sudan','+249'),
      Country(207,'Suriname','+597'),
      Country(208,'Svalbard and Jan Mayen Islands','+47'),
      Country(209,'Swaziland','+268'),
      Country(210,'Sweden','+46'),
      Country(211,'Switzerland','+41'),
      Country(212,'Syrian Arab Republic','+963'),
      Country(213,'Taiwan','+886'),
      Country(214,'Tajikistan','+992'),
      Country(215,'Tanzania, United Republic of','+255'),
      Country(216,'Thailand','+66'),
      Country(217,'Timor-Leste','+670'),
      Country(218,'Togo','+228'),
      Country(219,'Tokelau','+690'),
      Country(220,'Tonga','+676'),
      Country(221,'Trinidad and Tobago','+1-868'),
      Country(222,'Tunisia','+216'),
      Country(223,'Turkey','+90'),
      Country(224,'Turkmenistan','+993'),
      Country(225,'Turks and Caicos Islands','+1-649'),
      Country(226,'Tuvalu','+688'),
      Country(227,'Uganda','+256'),
      Country(228,'Ukraine','+380'),
      Country(229,'United Arab Emirates','+971'),
      Country(230,'United Kingdom','+44'),
      Country(231,'United States','+1'),
      Country(232,'United States Minor Outlying Islands','+246'),
      Country(233,'Uruguay','+598'),
      Country(234,'Uzbekistan','+998'),
      Country(235,'Vanuatu','+678'),
      Country(236,'Vatican City State (Holy See)','+379'),
      Country(237,'Venezuela','+58'),
      Country(238,'Vietnam','+84'),
      Country(239,'Virgin Islands (British)','+1-284'),
      Country(240,'Virgin Islands (U.S.)','+1-340'),
      Country(241,'Wallis and Futuna Islands','+681'),
      Country(242,'Western Sahara','+212'),
      Country(243,'Yemen','+967'),
      Country(244,'Zambia','+260'),
      Country(245,'Zimbabwe','+263'),

    ];
  }
}