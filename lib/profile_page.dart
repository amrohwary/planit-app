import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      welcome = "Good Morning ";
    }
    else if (hour < 5) {
      welcome = "Good Afternoon ";
    }
    else {
      welcome = "Good Evening ";
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
