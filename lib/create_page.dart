import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

/*
class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 15, top: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Workspace",
              style: new TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Create a New Trip!",
              style: new TextStyle(
                fontSize: 20,
//                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        new NewTripForm(),
      ],
    );
  }
}

class NewTripForm extends StatefulWidget {
  @override
  _NewTripFormState createState() => _NewTripFormState();
}

class _NewTripFormState extends State<NewTripForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime _date = new DateTime.now();

  Future<Null> _selectedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2019),
        lastDate: new DateTime(2100));
    if (picked != null && picked != _date) {
      print('Date selected: ${_date.toString()}');
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return "Trip name is required";
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "Trip Name",
                labelStyle: new TextStyle(color: Colors.black),
              ),
            ),
            Row(children: [
              Container(
                child: Text(
                  'Start Date: ',
                  style: new TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${new DateFormat.M().format(_date)}-${new DateFormat.d().format(_date)}-${new DateFormat.y().format(_date)}',
                  style: new TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                child: RaisedButton(
                  onPressed: () {
                    _selectedDate(context);
                  },
                  child: Text('Select Date'),
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 10, top: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Workspace",
              style: new TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 5, bottom: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Create a New Trip!",
              style: new TextStyle(
                fontSize: 20,
//                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Container(
            padding: const EdgeInsets.only(right: 15),
            child: TextField(
              scrollPhysics: NeverScrollableScrollPhysics(),
              maxLength: 25,
              style: new TextStyle(
                fontSize: 25,
              ),
              decoration: new InputDecoration(
                counterText: "",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Intriguing Title',
              ),
            ),
          ),
        ),
        NewTripForm(),
      ],
    );
  }
}

class NewTripForm extends StatefulWidget {
  @override
  _NewTripFormState createState() => _NewTripFormState();
}

class _NewTripFormState extends State<NewTripForm> {
  List<DateEntry> dateEntries = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        print(context);
        return new DateEntry();
      },
    );
  }
}

class DateEntry extends StatefulWidget {
  @override
  _DateEntryState createState() => _DateEntryState();
}

class _DateEntryState extends State<DateEntry> {
  String date = "Select Date";

  void _showDatePicker() {
    showModalBottomSheet(context: context, builder: (BuildContext builder) {
      return Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoDatePicker(
          onDateTimeChanged: (DateTime newDate) {
            setState(() {
              date = DateFormat.yMMMd().format(newDate).toString();
            });
          },
          initialDateTime: DateTime.now(),
          mode: CupertinoDatePickerMode.date,
        ),
      );
    });
  }

  void _googlePlaceSearch() {
    print("dnfkdfn");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  width: 270,
                  height: 40,
                  child: TextField(
                    maxLength: 25,
                    style: new TextStyle(
                      fontSize: 16,
                    ),
                    decoration: new InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Subtitle (optional)',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 30,
                  child: FlatButton(
                    child: Text(date),
                    onPressed: _showDatePicker,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 112,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 20,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == 19) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: Icon(Icons.add_circle_outline, size: 30,),
                      onPressed: _googlePlaceSearch,
                      color: Colors.black,
                    ),
                  );
                }
                return createPlaceCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget createPlaceCard() {
  return Padding(
    padding: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
    child: Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                height: 100,
                width: 180,
                child: Image.asset("assets/images/newyork.jpg", fit: BoxFit.cover)
              ),
              Positioned(
                  height: 100,
                  width: 180,
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
                        Text("Place", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        Text("Manhattan, NY", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12)),
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
  );
}

