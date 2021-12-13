import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tjao/helper/app_config.dart';
import 'package:tjao/helper/helper.dart';

// ignore: must_be_immutable
class EventDetailPage extends StatefulWidget {
  final int eventId;
  int userId, added_by, joined, approved;
  final String event_name,
      event_type,
      event_date,
      start_time,
      location,
      city,
      imageUrl,
      description;

  EventDetailPage({
    this.eventId,
    this.event_name,
    this.event_type,
    this.event_date,
    this.start_time,
    this.location,
    this.city,
    this.imageUrl,
    this.description,
    this.userId,
    this.added_by,
    this.joined,
    this.approved
  });

  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String _join = "Join";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.added_by == userId){
      setState(() {
        _join = "Cancel Event";
      });
    }
    else if(widget.joined > 0 && widget.approved > 0){
      setState(() {
        _join = "Joined/Leave?";
      });
    }
    else if(widget.joined > 0 && widget.approved == 0){
      setState(() {
        _join = "Awaiting Approval";
      });
    }
    else if(widget.joined > 0 && widget.approved < 0){
      setState(() {
        _join = "Request Rejected";
      });
    }
  }

  joinEvent() async {
    String url = baseApiURL + "method=join_event&id=$userId&event_id=${widget.eventId}";
    await http.Client().get(url);
  }

  leaveEvent() async {
    String url = baseApiURL + "method=leave_event&id=$userId&event_id=${widget.eventId}";
    await http.Client().get(url);
  }

  cancelEvent() async {
    String url = baseApiURL + "method=cancel_event&id=$userId&event_id=${widget.eventId}";
    await http.Client().get(url);
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: <Widget>[
                SliverPersistentHeader(
                  delegate: MySliverAppBar(
                      expandedHeight: _height - 40.0,
                      img: widget.imageUrl,
                      title: widget.event_name,
                      id: widget.eventId
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[                      
                      Padding(
                        padding: EdgeInsets.only(top: 30.0, left: 20.0),
                        child: Text(
                          widget.event_name,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontFamily: "Popins"
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black26,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.event_date,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: "Popins"
                                    ),
                                  ),
                                  Text(
                                    widget.start_time,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 25.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.place,
                              color: Colors.black26,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: "Popins"
                                    ),
                                  ),
                                  Text(
                                    (widget.event_type == "Public" || widget.added_by == userId || (widget.joined > 0 && widget.approved > 0))? "${widget.location}\n${widget.city}" : widget.city,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 25.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.payment,
                              color: Colors.black26,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                widget.event_type,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: "Popins"
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        height: 20.0,
                        width: double.infinity,
                        color: Colors.black12.withOpacity(0.04),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0, left: 20.0),
                        child: Text(
                          "About",
                          style: TextStyle(
                              fontSize: 19.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: "Popins"
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 20.0, right: 20.0, bottom: 20.0),
                        child: Text(
                          widget.description,
                          style: TextStyle(
                              fontFamily: "Popins",
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: 100.0,
                      )
                    ])),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70.0,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        widget.event_type,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 19.0,
                            fontFamily: "Popins"
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: InkWell(
                        onTap: () async {
                          if(widget.added_by == userId){
                            cancelEvent();
                            setState(() {
                              _join = "Cancelled";
                            });
                          }else if(widget.joined > 0 && widget.approved > 0){
                            leaveEvent();
                            setState(() {
                              _join = "Left";
                            });
                          }  else if(widget.joined == 0){
                            joinEvent();
                            setState(() {
                              _join = "Awaiting Approval";
                            });
                          }                          
                        },
                        child: Container(
                          height: 50.0,
                          width: 180.0,
                          decoration: BoxDecoration(
                              color: Color(0xFFAD2829),
                              borderRadius: BorderRadius.all(Radius.circular(40.0))
                          ),
                          child: Center(
                            child: Text(
                              _join,
                              style: TextStyle(
                                  fontFamily: "Popins",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  String img, title;
  int id;

  MySliverAppBar({@required this.expandedHeight, this.img, this.title, this.id});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.clip,
      children: [
        Container(
          height: 50.0,
          width: double.infinity,
          color: Colors.white,
        ),
        Opacity(
          opacity: (1 - shrinkOffset / expandedHeight),
          child: Hero(
            transitionOnUserGestures: true,
            tag: 'hero-tag-$id',
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage(baseUploadURL + img),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Container(
                margin: EdgeInsets.only(top: 130.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: <Color>[
                        new Color(0x00FFFFFF),
                        new Color(0xFFFFFFFF),
                      ],
                      stops: [0.0, 1.0],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(0.0, 1.0)
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                      child: Icon(Icons.arrow_back),
                    )
                )
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 250.0,
                child: Text(
                  "Event",
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 25.0,
            )
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}