import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_pay/google_pay.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:tjao/Screen/B5_Payment/Payment.dart';
import 'package:tjao/Screen/B5_Payment/existing_card.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/helper/helper.dart';
import 'package:tjao/helper/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({Key key}) : super(key: key);
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _platformVersion = 'Unknown';
  String _googlePayToken = 'Unknown';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final CreditCard testCard = CreditCard(
    number: '4111111111111111',
    expMonth: 08,
    expYear: 22,
  );

  Future _confirmDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Confirm Payment',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure want to pay \€ 3.99?', style: TextStyle(fontSize: 16, color: Colors.white),),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                              Navigator.of(context).pop();
                              _selectCardDialog(context);
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

  Future _selectCardDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Select Card',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    height: 45,
                    child: RaisedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle, size: 30, color: Colors.white,),
                          SizedBox(width: 20,),
                          Text("Pay via new card", style: TextStyle(fontSize: 18, color: Colors.white),)
                        ],
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        var response = await StripeService.payWithNewCard(amount: '399', currency: 'EUR');
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            duration: new Duration(microseconds: response.success == true ? 2000 : 3000),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.white)
                      ),
                      color: Colors.green[900],
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    width: 300,
                    height: 45,
                    child: RaisedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, size: 30, color: Colors.white,),
                          SizedBox(width: 20,),
                          Text("Pay via existing card", style: TextStyle(fontSize: 18, color: Colors.white),)
                        ],
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExistingCardsPage())
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.white)
                      ),
                      color: Colors.blue[900],
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  addPayment() async {
    onButtonPressed();
    String url = baseApiURL + "method=add_payment&id=$userId&id=3&token=b375f172be1ebd7556320a97c97c82ce&amount=10";

    final response = await http.Client().get(url);

    print("response = ${response.body}");
  }

  // Future<void> startDirectCharge(PaymentMethod paymentMethod) async {
  //   print('Payment charge started');
  //   final http.Response response = await http.post((Uri.parse());
  //   if(response != null) {
  //     final paymentIntent = jsonDecode(response.body);
  //     final status = paymentIntent['paymentIntent']['status'];
  //     final acct = paymentIntent['stripeAccount'];
  //     if(status == 'succeeded') {
  //       print('payment done');
  //     } else {
  //       StripePayment.setStripeAccount(acct);
  //       await StripePayment.confirmPaymentIntent(PaymentIntent(
  //         paymentMethodId: paymentIntent['paymentIntent']['payment_method'],
  //         clientSecret: paymentIntent['paymentIntent']['client_secret']
  //       )).then((PaymentIntentResult paymentIntentResult) async {
  //         final paymentStatus = paymentIntentResult.status;
  //         if (paymentStatus == 'succeeded') {
  //           print('payment done');
  //         }
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    StripeService.init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GooglePay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    await GooglePay.initializeGooglePay("pk_test_H5CJvRiPfCrRS44bZJLu46fM00UjQ0vtRN");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void onButtonPressed() async{
    setState((){_googlePayToken = "Fetching";});
    try {
      await GooglePay.openGooglePaySetup(
          price: "5.0",
          onGooglePaySuccess: onSuccess,
          onGooglePayFailure: onFailure,
          onGooglePayCanceled: onCancelled);

      setState((){_googlePayToken = "Done Fetching";});
    } on PlatformException catch (ex) {
      setState((){_googlePayToken = "Failed Fetching";});
    }

  }

  void onSuccess(String token){
    setState((){_googlePayToken = token;});
    print(_googlePayToken + "--->");
  }

  void onFailure(){
    setState((){_googlePayToken = "Failure";});
  }

  void onCancelled(){
    setState((){_googlePayToken = "Cancelled";});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
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
            "Subscription",
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/img/subscription_banner.jpg'),
                              fit: BoxFit.fitWidth
                          )
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text('Subscribe to get more out of Tjao', style: TextStyle(color: Colors.white, fontSize: 20),),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: width*0.6-20,
                            color: Colors.grey,
                          ),
                          Container(
                            width: width*0.17,
                            alignment: Alignment.center,
                            child: Text('FREE', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            width: width*0.23,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            child: Text('Premium', style: TextStyle(color: Colors.white, fontSize: 16,),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Only see friends on check in lists', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Can not apply to private events', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Can not create private events', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Can not chat with users outside friend list. standard users will neither have possibility to read a chat message which came from an users outside their friend list, neither see their username.', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	All other functions, apart from above mentioned restrictions, will be allowed for standard users.', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	See full check-in lists at clubs and bars', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.cancel_outlined, color: Colors.red,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Apply to private events', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.cancel_outlined, color: Colors.red,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Create Private events', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.cancel_outlined, color: Colors.red,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 10,),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 0.5, color: Colors.grey)
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width*0.6-20,
                            child: Text('•	Chat with users outside friend list', style: TextStyle(color: Colors.black,),),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.17-5,
                            child: Icon(Icons.cancel_outlined, color: Colors.red,),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: width*0.23-5,
                            child: Icon(Icons.check, color: Colors.green,),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: Container(
                  width: 200,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.pink),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                        ),
                        child: Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 16),),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        height: 30,
                        child: Row(
                          children: [
                            Text('\€', style: TextStyle(color: Colors.pink, fontFamily: 'Arial', fontSize: 18),),
                            Text('3.99', style: TextStyle(fontSize: 28, color: Colors.pink, fontFamily: 'Arial'),),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: Text('/Month', style: TextStyle(color: Colors.pink, fontFamily: 'Arial'),),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      GestureDetector(
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.pink[700],
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          alignment: Alignment.center,
                          child: Text("Upgrade", style: TextStyle(color: Colors.white, fontSize: 16,),),
                        ),
                        onTap: () async {
                          _confirmDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30,),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 40, right: 40),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.pink[700],
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink[900].withOpacity(0.5),
                        spreadRadius: 7,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text("Subscripe", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                ),
                onTap: () async {
                  // startPayment();
                  // addPayment();
                  _confirmDialog(context);
                },
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
