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

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: WelcomeMessage(uid: widget.user.uid,),
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

  Widget _buildCollections(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView.builder(
        itemCount: snapshots.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return new StreamBuilder(
            stream: snapshots[index].reference.collection("trips").snapshots(),
            builder: (context, collectionSnapshot) {
              if (!collectionSnapshot.hasData) {
                return Center(
                    child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,), child: LinearProgressIndicator(),)
                );
              }
              return _buildCollection(context, collectionSnapshot.data.documents, snapshots[index]["title"]);
            },
          );
        });
  }

  Widget _buildCollection(BuildContext context, List<DocumentSnapshot> snapshots, String title) {

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 14, top: 15, bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF074A77),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 500,
          height: 128,
          child: ListView.builder(
            itemCount: snapshots.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return TripCard();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 723,
      child: ListView(
        scrollDirection: Axis.vertical,
        // For each collection in users.uid.collections.
        children: <Widget>[
          new NameAndDate(user: widget.user),
          new StreamBuilder(
            stream: Firestore.instance.collection("users").document(widget.user.uid).collection("collections").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,),child: LinearProgressIndicator(),)
                );
              }
              return _buildCollections(context, snapshot.data.documents);
            },
          ),
        ],
      ),
    );
  }
}

class Collection extends StatefulWidget {
  const Collection({Key key, this.title}) : super(key: key);
  final String title;
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
            child: Text(widget.title,
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
                  color: Colors.blue,
                    height: 120,
                    width: 200,
                    //child: new Image.asset("assets/images/newyork.jpg", fit: BoxFit.cover,),
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
                          Text("Feb 12 - 14, 2019", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12)),
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

class WelcomeMessage extends StatelessWidget {
  final String uid;
  const WelcomeMessage({Key key, this.uid}) : super(key: key);

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
    return welcome;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(_getWelcome(), style: new TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),);
          }
          var userDocument = snapshot.data;
          return new Text(_getWelcome() + userDocument["firstName"] + "!", style: new TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),);
        }
    );
  }
}




