import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final formatCurrency = NumberFormat.simpleCurrency();

class NameAndDate extends StatefulWidget {
  const NameAndDate({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _NameAndDateState createState() => _NameAndDateState();
}

class _NameAndDateState extends State<NameAndDate> {
  String _getDate() {
    var day = new DateFormat.EEEE().format(new DateTime.now());
    var month = new DateFormat.MMMMd().format(new DateTime.now());
    var year = new DateFormat.y().format(new DateTime.now());

    return day + ", " + month + ", " + year;
  }

  String _getWelcome() {
    var hour = new DateTime.now().hour;
    var welcome;
    if (hour > 5 && hour < 12) {
      welcome = "Good Morning, ";
    }
    else if (hour < 5) {
      welcome = "Good Afternoon, ";
    }
    else {
      welcome = "Good Evening, ";
    }
    return welcome + "Amro!";//+ widget.user.email;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(_getWelcome(),
              style: new TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.only(left: 15, top: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(_getDate(),
              style: new TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Collections extends StatefulWidget {
  const Collections({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _CollectionsState createState() => _CollectionsState();
}

class _CollectionsState extends State<Collections> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 723,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          new NameAndDate(user: widget.user),
          new Collection(),
          new Collection(),
          new Collection(),
          new Collection(),
          new Collection(),
        ],
      ),
    );
  }
}

class Collection extends StatefulWidget {
  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 14, top: 15, bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Planned Trips",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF074A77),
              fontWeight: FontWeight.bold,

            ),),
          ),
        ),
        SizedBox(
          width: 500,
          height: 128,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              new TripCard(),
              new TripCard(),
              new TripCard(),
              new TripCard(),
              new TripCard(),
              new TripCard(),
            ],
          ),
        ),
      ],
    );
  }
}


class TripCard extends StatefulWidget {
  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                    height: 120,
                    width: 200,
                    child: new Image.asset("assets/images/newyork.jpg", fit: BoxFit.cover,),
                ),
                Positioned(
                    width: 200,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.black, Colors.black.withOpacity(0)]
                          )
                      ),
                    )
                ),
                Positioned(
                  left:10,
                  bottom: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("New York, NY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                          Text("Feb 2019", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );;
  }
}



