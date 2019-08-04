import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_keys.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'common/appbar.dart';
import 'package:uuid/uuid.dart';
import 'place_view.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
var uuid = new Uuid();

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 20),
          child: Container(
            padding: const EdgeInsets.only(right: 15),
            child: TextField(
              maxLength: 30,
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
        Container(
          margin: const EdgeInsets.only(
            left: 3,
          ),
          height: 40,
          child: PlacesAutocompleteField(
            mode: Mode.overlay,
            hint: "Where are you going?",
            inputDecoration: new InputDecoration(
              counterText: "",
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            apiKey: googleMapsApiKey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Divider(),
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
  List dateEntries = [DateEntry()];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: dateEntries.length + 1,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == dateEntries.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
            child: FlatButton(
              color: Color(0xFF074A77),
              onPressed: () {
                setState(() {
                  dateEntries.add(new DateEntry());
                });
              },
              child: Text(
                "Add a Day!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return Dismissible(
          key: Key(dateEntries[index].id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.only(right: 60),
              child: Icon(
                Icons.delete,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          child: dateEntries[index],
          onDismissed: (direction) {
            setState(() {
              dateEntries.removeAt(index);
            });
          },
        );
      },
    );
  }
}

class DateEntry extends StatefulWidget {
  String id = uuid.v1();

  String get uniqueId {
    return this.id;
  }

  @override
  _DateEntryState createState() => _DateEntryState();
}

class _DateEntryState extends State<DateEntry> {
  List places = [];
  String date = "Select Date";

  void _showDatePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
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

  void _googlePlaceSearch() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleMapsApiKey,
        mode: Mode.fullscreen,
        language: "en-US",
        components: [new Component(Component.country, "US")]);
    addNewPlace(p, homeScaffoldKey.currentState);
  }

  Future<Null> addNewPlace(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      if (detail.result != null) {
        print(detail.result.formattedAddress);
        setState(() {
          places.add(createPlaceCard(detail.result, context));
        });
        scaffold.showSnackBar(new SnackBar(
            content: new Text(
                "${p.description} was successfully added to your trip.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  width: 250,
                  height: 40,
                  child: TextField(
                    maxLength: 30,
                    style: new TextStyle(
                      fontSize: 16,
                    ),
                    decoration: new InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Daily Summary (optional)',
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
              itemCount: places.length + 1,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == places.length) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 30,
                      ),
                      onPressed: _googlePlaceSearch,
                      color: Colors.black,
                    ),
                  );
                }
                return places[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget createPlaceCard(PlaceDetails placeDetails, BuildContext context) {
  var name = placeDetails.name;
  //var location = placeDetails.addressComponents.elementAt(0).shortName;

  return InkWell(
    onTap: () {
      return Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceView(placeDetails: placeDetails,)));
    },
    child: Container(
        child: Padding(
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
                        child: Image.asset("assets/images/newyork.jpg",
                            fit: BoxFit.cover)),
                    Positioned(
                      height: 100,
                      width: 180,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.black, Colors.black.withOpacity(0)]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14)),
                              Text("Manhattan, NY",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      fontSize: 12)),
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
        ),
    ),
  );
}
