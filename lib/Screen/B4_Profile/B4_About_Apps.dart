import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget {
  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {

  static var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Application",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.black54,
              fontFamily: "Gotik"
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF6991C7)),
        elevation: 10.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Divider(
                  height: 0.5,
                  color: Colors.black12,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Privacy Policy",
                            style: _txtCustomSub.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black
                            ),
                          ),
                          Text("Last modified: March 15 22, 2021")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Divider(
                  height: 0.5,
                  color: Colors.black12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "There are many different ways you can use our services: to search for and share information, to communicate with other people or to create new content. When you share information with us, for example by creating an Account, we can make those services even better, to show you more relevant information, to help you connect with As you use our services, we want you to be clear how we're using information and the ways in which you can protect your privacy."
                  "\n\nYour personal information is any information that can be used to identify you, including name, address, gender, email address, etc.  JANGO STARTUP INCUBATOR I/S, HEREUNDER TJAO applications, collects, uses and shares personal information to manage and operate JANGO STARTUP INCUBATOR I/S, HEREUNDER TJAO application and protects your personal data in order to make you feel safe and secure."
                  "\nJANGO STARTUP INCUBATOR I/S, HEREUNDER TJAO applications, Fagotvej 2, 3650 is \"data controller\" and thus responsible for your personal information.",
                  style: _txtCustomSub.copyWith(color: Colors.black),
                  textAlign: TextAlign.justify,
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Our Privacy Policy explains:",
                            style: _txtCustomSub.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "• What information we collect and why we collect it."
                  "\n• How we use that information."
                  "\nThe choices we offer, including how to access and update information. We've tried to keep it as simple as possible, but if you're not familiar with terms like cookies, IP addresses, pixel tags and browsers, then read about these key terms first. Please do take the time to get to know our practices : and if you have any questions contact us."
                  "• Payments & subscriptions",
                  style: _txtCustomSub.copyWith(color: Colors.black),
                  textAlign: TextAlign.justify,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
