import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:tjao/Screen/Bottom_Nav_Bar/bottomNavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  final int userId;
  final String profilePic;
  final String actualOtp;
  const OtpPage({Key key, this.userId, this.profilePic, this.actualOtp}) : super(key: key);
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String text = '';

  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }

  void _handleSubmitted() async{
    if(text == widget.actualOtp) {
      SharedPreferences prefs;
      prefs = await SharedPreferences.getInstance();
      try {
        if(widget.profilePic != null && widget.profilePic != '')
        prefs.setString("profile_pic", widget.profilePic);
        prefs.setInt("user_id", widget.userId);
        
      } catch (e) {
        print('Error: $e');
        CircularProgressIndicator();
      } finally {
        Navigator.of(context)
            .pushReplacement(
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        new BottomNavBar()
                )
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (BuildContext context) {
          return AlertDialog(
            title: Text("OTP mismatch"),
            content: Text(
                "OTP did not match"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context)
                      .pop();
                },
              )
            ],
          );
        });
    }
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
        child: Center(child: Text(text[position], style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),)),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                title: new Text("OTP"),
              ),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text('Please enter OTP', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400))
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                      maxWidth: 500
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      otpNumberWidget(0),
                                      otpNumberWidget(1),
                                      otpNumberWidget(2),
                                      otpNumberWidget(3),
                                      //otpNumberWidget(4),
                                      //otpNumberWidget(5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            constraints: const BoxConstraints(
                                maxWidth: 500
                            ),
                            child: RaisedButton(
                              onPressed: _handleSubmitted,
                              color: Color(0xFFAD2829),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(14))
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('Confirm', style: TextStyle(color: Colors.white),),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        color: Color(0xFFAD2829),
                                      ),
                                      child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16,),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          NumericKeyboard(
                            onKeyboardTap: _onKeyboardTap,
                            textColor: Color(0xFFAD2829),
                            rightIcon: Icon(
                              Icons.backspace,
                              color: Color(0xFFAD2829),
                            ),
                            rightButtonFn: () {
                              setState(() {
                                text = text.substring(0, text.length - 1);
                              });
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
  }
}