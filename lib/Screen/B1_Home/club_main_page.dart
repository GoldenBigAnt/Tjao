import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tjao/Screen/B1_Search/SearchClub.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:tjao/Screen/B1_Home/club_profile_page.dart';
import 'package:tjao/Screen/B3_Navigation/LocationService.dart';
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';
import 'package:tjao/model/club.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubMainPage extends StatefulWidget {
  ClubMainPage({Key key}) : super(key: key);

  _ClubMainPageState createState() => _ClubMainPageState();
}

void gotoClubProfile(BuildContext context, ClubModel club, int userId){
  Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (_, ___, ____) =>
              new ClubProfilePage(clubId : club.club_id, clubName: club.clubName, address: club.address, bannerImg: club.bannerImg, description: club.description, upcoming: club.upcoming, offers: club.offers, news: club.news, max_allowance: club.max_allowance, rating: club.rating, distance: club.distance, visitors: club.visitors, live_friends: club.live_friends, phone_number: club.phone_number, latitude: club.latitude, longitude: club.longitude, bar_timing: club.bar_timing)
      )
  );
}

class _ClubMainPageState extends State<ClubMainPage> {
  final GridListDemoType type = GridListDemoType.footer;
  final CardTypeConst cardType = CardTypeConst.tappable;
  Future<List<ClubModel>> futureData;
  Future<List<ClubModel>> friendClubs;
  Future<List<ClubModel>> offerClubs;
  int clubCount = 0;
  int offerCount = 0;
  Future<String> banner;

  Map<String, String> get headers => {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json; charset=UTF-8"
  };

  Future<List<ClubModel>> fetchClubs(http.Client client) async {
    String url = baseApiURL + "method=get_clubs&type=nearest&user_id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  Future<List<ClubModel>> fetchFriendsClubs(http.Client client) async {
    String url = baseApiURL + "method=get_clubs&type=friends&user_id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  Future<List<ClubModel>> fetchLatestOffers(http.Client client) async {
    String url = baseApiURL + "method=get_latest_offers&user_id=$userId";
    final response = await client.get(url, headers: headers);
    return compute(parseClubs, response.body);
  }

  Future<String> fetchAppBanner(http.Client client) async {
    String url = baseApiURL + "method=get_banner&user_id=$userId";
    final response = await client.get(url);
    return response.body.toString();
  }

  @override
  void initState() {
    super.initState();   
    new LocationService();     
    banner = fetchAppBanner(http.Client());
    startTime();
  }

  void callClubData(){
    if (this.mounted) {
      this.setState(() {
        friendClubs = fetchFriendsClubs(http.Client());
        offerClubs = fetchLatestOffers(http.Client());
        futureData = fetchClubs(http.Client());
      });
    }
  }

  startTime() async {
    return new Timer(Duration(milliseconds: 10000), callClubData);
  }

  void gotoSearchScreen(String searchText){
    if(searchText.length >= 3){
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, ___, ____) =>
              new SearchClubPage(searchText: searchText,)
        )
      );
    }    
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 10,
          backgroundColor: Colors.white,
          title: TextField(
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
              onChanged: (text){
                gotoSearchScreen(text);
              },
            ),
            elevation: 0.0,
        ),
      body: SingleChildScrollView (
        child: Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

                new Container(
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 1,
                  child: new ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: FutureBuilder<String>(
                      future: banner,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.none) {
                          return Image.asset(
                            'assets/img/club_banner.jpg',
                            fit: BoxFit.fitWidth,
                          );
                        } else if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
                          return Image.asset(
                            'assets/img/club_banner.jpg',
                            fit: BoxFit.fitWidth,
                          );
                        } else if(snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError)
                            return Image.asset(
                              'assets/img/club_banner.jpg',
                              fit: BoxFit.fitWidth,
                            );
                          return Image.network(
                              baseUploadURL + snapshot.data,
                              fit: BoxFit.fitWidth
                          );
                        }
                        return Image.network(
                            baseUploadURL + snapshot.data,
                            fit: BoxFit.fitWidth
                        );
                      },
                    ),
                  )
                ),
                new Container(
                  margin: const EdgeInsets.all(10),
                  child: Text("Your friends are visiting..", style: new TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                ),
                FutureBuilder<List<ClubModel>>(
                  future: friendClubs,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? FriendClubScreen(

                          list: snapshot.data,
                        ) : Center(child: CircularProgressIndicator());
                  },
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  child: FlatButton(
                    onPressed: () => {},
                    color: Color(0xFFe0e1e4),
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text("see more"),
                        Icon(Icons.arrow_drop_down_sharp),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<List<ClubModel>>(
                  future: offerClubs,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return (snapshot.hasData && snapshot.data.length > 0)
                        ? Container(
                            margin: const EdgeInsets.all(10),
                            child: Text("LATEST OFFERS", style: new TextStyle(fontSize: 14, color: Colors.grey),textAlign: TextAlign.left,)
                          ) : Container();
                  },
                ),
                FutureBuilder<List<ClubModel>>(
                  future: offerClubs,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return (snapshot.hasData && snapshot.data.length > 0)
                        ? LatestOfferScreen(

                          list: snapshot.data,
                        ) : Container();
                  },
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 10, top: 5),
                  child: FutureBuilder<List<ClubModel>>(
                    future: futureData,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        clubCount = snapshot.data.length;
                      }
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? Text("$clubCount clubs around you", style: new TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.left,) : Center(child: CircularProgressIndicator());
                    },
                  )
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text("Everything in a list - go nuts!", style: new TextStyle(fontSize: 12, color: Colors.grey),textAlign: TextAlign.left,),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0.0),
                  child: FutureBuilder<List<ClubModel>>(
                    future: futureData,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? CardDataScreen(

                            list: snapshot.data,
                          ) : Center(child: CircularProgressIndicator());
                    },
                  )
                ),
            ]
          )
        )
      ),
    );
  }
}

// ignore: must_be_immutable
class FriendClubScreen extends StatelessWidget {
  FriendClubScreen({this.userId, this.list});
  final List<ClubModel> list;
  int userId;
  final GridListDemoType type = GridListDemoType.footer;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 2,
      shrinkWrap: true, 
      physics: ScrollPhysics(),
      padding: const EdgeInsets.all(8),
      children: list.map<Widget>((club) {
        return _GridDemoPhotoItem(
          club: club,
          tileStyle: type,
        );
      }).toList(),
    );
  }
}

// ignore: must_be_immutable
class LatestOfferScreen extends StatelessWidget {
  LatestOfferScreen({this.userId, this.list});
  final List<ClubModel> list;
  int userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      height: MediaQuery.of(context).size.height * 0.20,
      child: ListView.builder(                  
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          ClubModel club = list[index];
            if(index == (list.length - 1)){
              return Container(
                child: InkWell(
                  onTap: () {
                    gotoClubProfile(context, club, userId);
                  },
                  child: Image.network(
                    baseUploadURL + club.bannerImg,
                    height: double.infinity,
                  )
                )
              );
            }else{
              return Container(
                margin: const EdgeInsets.only(right: 1),
                child: InkWell(
                  onTap: () {
                    gotoClubProfile(context, club, userId);
                  },
                  child: Image.network(
                    baseUploadURL + club.bannerImg,
                    height: double.infinity,
                  )
                )
              );
            }                      
        }
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
          String clubName = list[i].clubName;
          String address = list[i].address;
          String bannerImg = list[i].bannerImg;
          String description = list[i].description;
          int club_id = list[i].club_id;
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


enum GridListDemoType {
  imageOnly,
  header,
  footer,
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

class _GridDemoPhotoItem extends StatelessWidget {
  _GridDemoPhotoItem({
    Key key,
    @required this.club,
    @required this.tileStyle,
  }) : super(key: key);

  final ClubModel club;
  final GridListDemoType tileStyle;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Image.network(
        baseUploadURL + club.bannerImg,
        /*fit: BoxFit.cover,*/
        width: MediaQuery.of(context).size.width,
        height: 85,
      ),
    );

    switch (tileStyle) {
      case GridListDemoType.imageOnly:
        return image;
      case GridListDemoType.header:
        return GridTile(
          header: Material(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: GridTileBar(
              title: _GridTitleText(club.clubName),
              backgroundColor: Colors.black45,
            ),
          ),
          child: image,
        );
      case GridListDemoType.footer:
        return Column(
          //mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        gotoClubProfile(context, club, userId);
                      },
                      child: image,
                    )
                  ),
                  SizedBox(
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(club.clubName, style: TextStyle(fontSize: 12.0,)),
                      )
                    ),
                  ),
                ],
        );
    }
    return null;
  }
}

class ClubItem extends StatelessWidget {
  const ClubItem({Key key, @required this.club, this.shape})
      : assert(club != null),
        super(key: key);

  // This height will allow for all the Card's content to fit comfortably within the card.
  static const height = 360.0;
  final ClubModel club;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
                    gotoClubProfile(context, club, userId);
                  },
                  // Generally, material cards use onSurface with 12% opacity for the pressed state.
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  // Generally, material cards do not have a highlight overlay.
                  highlightColor: Colors.transparent,
                  child: ClubContent(club: club),
                ),
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
              Positioned(
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
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: descriptionStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This array contains the three line description on each card
                // demo.
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    club.description,
                    style: descriptionStyle.copyWith(color: Colors.black54, fontSize: 14),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.location_pin, size: 18, color: Colors.black54,)
                      ),
                      TextSpan(
                        text: club.address,
                        style: descriptionStyle.copyWith(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                //Text(club.address),
              ],
            ),
          ),
        ),
        if (club.cardType == CardTypeConst.standard)
          // share, explore buttons
          ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    FlatButton(
                      textColor: const Color(0xFFad2829),
                      onPressed: () {
                        // Perform some action
                      },
                      child: const Text('Share'),
                    ),
                    FlatButton(
                      textColor: const Color(0xFFad2829),
                      onPressed: () {
                        _getDirection();
                      },
                      child: const Text('Get Direction'),
                    ),
                  ],
                ),
      ],
    );
  }
}