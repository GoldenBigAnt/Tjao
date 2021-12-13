import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:tjao/Screen/B1_Home/club_profile_page.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/club.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class SearchClubPage extends StatefulWidget {
  String searchText;
  SearchClubPage({this.searchText});

  _SearchClubPageState createState() => _SearchClubPageState();
}


void gotoClubProfile(BuildContext context, ClubModel club){
  Navigator.of(context).push(
    PageRouteBuilder(
        pageBuilder: (_, ___, ____) =>
            new ClubProfilePage(clubId : club.club_id, clubName: club.clubName, address: club.address, bannerImg: club.bannerImg, description: club.description, upcoming: club.upcoming, offers: club.offers, news: club.news, max_allowance: club.max_allowance, rating: club.rating, distance: club.distance, visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number, latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing)
    )
  );
}

class _SearchClubPageState extends State<SearchClubPage> {
  final CardTypeConst cardType = CardTypeConst.tappable;
  Future<List<ClubModel>> futureData;
  String type = "nearest";

  Map<String, String> get headers => {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=UTF-8"
  };

  Future<List<ClubModel>> fetchClubs(http.Client client) async {
    String url = baseApiURL + "method=get_clubs&search=${widget.searchText}&type=$type&user_id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchClubs(http.Client());
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 10,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          /*leading: Transform.translate(
            offset: Offset(-15, 0),
            child: Icon(Icons.arrow_back),
          ),*/
          title: TextFormField(
            initialValue: widget.searchText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8.0),
              prefixIcon: Icon(Icons.search),
              labelText: "Search for clubs and bars...",
              labelStyle: new TextStyle(color: Colors.grey),
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
            /*onchanged: (text){
              setState(() {
                widget.search_txt = text;
                future_data = fetchClubs(http.Client());
              });
            }*/
          ),
          elevation: 0.0,
        ),
      body: SingleChildScrollView (
        child: Container(
          //margin: const EdgeInsets.only(top: 20),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*new Container(
                margin: const EdgeInsets.only(top:10, left:10, right:10),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8.0),
                    prefixIcon: Icon(Icons.search),
                    labelText: "Search for clubs and bars...",
                    labelStyle: new TextStyle(color: Colors.grey),
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
              ),*/
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide( //                    
                    color: Colors.grey[300],
                    width: 1.0,
                  ),)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,                  
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Builder(
                        builder: (context) {
                          return OutlineButton(
                            onPressed: () {
                              setState(() {
                                type = "friends";
                                futureData = fetchClubs(http.Client());
                              });
                            },
                            borderSide: BorderSide(
                              color: type == "friends" ? Color(0xFFad2829) : Colors.grey, //Color of the border
                              style: BorderStyle.solid, //Style of the border
                              width: 1.0, //width of the border
                            ),
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: Color(0xFFad2829),
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Text("Popular in friends", style: TextStyle(color: type == "friends" ? Color(0xFFad2829) : Colors.grey)),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Builder(
                        builder: (context) {
                          return OutlineButton(
                            onPressed: () {
                              setState(() {
                                type = "nearest";
                                futureData = fetchClubs(http.Client());
                              });
                            },
                            borderSide: BorderSide(
                              color: type == "nearest" ? Color(0xFFad2829) : Colors.grey, //Color of the border
                              style: BorderStyle.solid, //Style of the border
                              width: 1.0, //width of the border
                            ),
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: Color(0xFFad2829),
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Text("Nearest to me", style: TextStyle(color: type == "nearest" ? Color(0xFFad2829) :  Colors.grey)),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                  ]
                ),
              ),
              
              FutureBuilder<List<ClubModel>>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? CardDataScreen(

                        list: snapshot.data,
                      ) : Center(child: CircularProgressIndicator());
                },
              ),
            ]
          )
        )
      )
    );
  }
}

// ignore: must_be_immutable
class CardDataScreen extends StatelessWidget {
  int userId;
  CardDataScreen({this.userId, this.list});

  final List<ClubModel> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: list.length,
        itemBuilder: (context, i) {
          CardTypeConst cardType = list[i].cardType;

          return InkWell(
            onTap: () {
              
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: (cardType == CardTypeConst.standard)
                  ? ClubItem(club: list[i])
                  : cardType == CardTypeConst.tappable
                      ? ClubItem(club: list[i])
                      : ClubItem(club: list[i]),
            ),
          );
        });
  }
}

class ClubItem extends StatelessWidget {
  const ClubItem({Key key, @required this.club, this.shape})
      : assert(club != null),
        super(key: key);

  // This height will allow for all the Card's content to fit comfortably within the card.
  static const height = 430.0;
  final ClubModel club;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 10.0, right: 8.0),
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: Card(
                // This ensures that the Card's children are clipped correctly.
                clipBehavior: Clip.antiAlias,
                shape: shape,
                child: InkWell(
                  onTap: () {
                    gotoClubProfile(context, club);
                  },
                  // Generally, material cards use onSurface with 12% opacity for the pressed state.
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  // Generally, material cards do not have a highlight overlay.
                  highlightColor: Colors.transparent,
                  child: ClubContent(club: club),
                ),
                //child: ClubContent(club: club),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubContent extends StatelessWidget {
  const ClubContent({Key key, @required this.club})
      : assert(club != null),
        super(key: key);

  final ClubModel club;

  _getDirection() async { 
     var uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${club.latitude},${club.longitude}&mode=d");
      if (await canLaunch(uri.toString())) {
          await launch(uri.toString());
      } else {
          throw 'Could not launch ${uri.toString()}';
      }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline5.copyWith(color: Colors.white);
    final descriptionStyle = theme.textTheme.subtitle1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 184,
          child: Stack(
            children: [
              Positioned.fill(
                // In order to have the ink splash appear above the image, you
                // must use Ink.image. This allows the image to be painted as
                // part of the Material and display ink effects above it. Using
                // a standard Image will obscure the ink splash.
                child: Ink.image(
                  image: NetworkImage(baseUploadURL + club.bannerImg, scale: 1.0),
                  fit: BoxFit.fitWidth,
                  child: Container(),
                ),
              ),
              /*Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    club.clubName,
                    style: titleStyle,
                  ),
                ),
              ),*/
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(club.clubName, textAlign: TextAlign.left, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.black),),                                            
              Container(
                width: 80.0,
                height: 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        //color: Colors.red[300],
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: FittedBox(
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      child: Text('${club.rating}', textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.black),),
                    ),
                    Text('/5', textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.black38),),
                  ]
                )
              )
            ],
          )
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: descriptionStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                            child: Icon(Icons.location_pin, size: 16, color: Colors.black54,)
                        ),
                        TextSpan(
                          text: club.address,
                          style: descriptionStyle.copyWith(color: Colors.black54, fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  height: 23.0,
                  decoration: BoxDecoration(
                    //color: Colors.red[300],
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text('${double.parse((club.distance).toStringAsFixed(2))} km', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.white),),
                  )
                ),                
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: descriptionStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VISITING / ALLOWANCE', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.black38),),
                Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  height: 23.0,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text('${club.visitors} / ${club.max_allowance}', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),),
                  )
                ),                
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: descriptionStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Friends', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.black38),),
                Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  height: 23.0,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text('${club.live_friends}', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),),
                  )
                ),                
              ],
            ),
          ),
        ),
        if (club.cardType == CardTypeConst.standard)
          // share, explore buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                textColor: const Color(0xFFad2829),
                onPressed: () {
                  _getDirection();
                },
                child: const Text('Get Direction'),
              ),
              FlatButton(
                textColor: const Color(0xFFad2829),
                onPressed: () {
                  // Perform some action
                },
                child: Text('Opens at ${club.open_time}'),
              ),
            ],
          ),
      ],
    );
  }
}