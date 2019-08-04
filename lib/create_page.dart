import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_keys.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'common/appbar.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
var uuid = new Uuid();

class CreatePage extends StatefulWidget {
  const CreatePage({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String collection = "Select a Collection for this trip";
  List<String> collectionChoices = [];

  Future<void> _getCollectionsFromFirestore() async {
    QuerySnapshot ref = await Firestore.instance.collection('users').document
      (widget.user.uid).collection("collections").getDocuments();

    ref.documents.forEach((document) {
      if (!collectionChoices.contains(document["title"])) {
        collectionChoices.add(document["title"]);
      }
    });
  }

  void selectCollection() async {
    await _getCollectionsFromFirestore();
    showModalBottomSheet(context: context, builder: (BuildContext builder) {
      return Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker.builder(
          backgroundColor: Colors.white,
          itemExtent: 30,
          magnification: 1.5,
          childCount: collectionChoices.length,
          itemBuilder: (context, index) {
            return Text(collectionChoices[index]);
          },
          squeeze: 0.8,
          onSelectedItemChanged: (item) {
            setState(() {
              collection = collectionChoices[item];
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 22),
          child: Container(
            padding: const EdgeInsets.only(right: 15),
            child: TextField(
              maxLength: 30,
              style: new TextStyle(
                fontSize: 25,
              ),
              decoration: new InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: -2),
                counterText: "",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Intriguing Title',
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 3,),
          height: 40,
          child: PlacesAutocompleteField(
            types: ["(regions)",],
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
        Container(
          margin: const EdgeInsets.only(left: 19, top: 5, bottom: 10),
          child: Row(
            children: <Widget>[
              Text("Collection: "),
              Container(
                height: 20,
                child: FlatButton(
                  onPressed: selectCollection,
                  child: Text(collection),
                ),
              ),
            ],
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

// -------------------------------------------------------------------------

class NewTripForm extends StatefulWidget {
  @override
  _NewTripFormState createState() => _NewTripFormState();
}

class _NewTripFormState extends State<NewTripForm> {
  List dateEntries = [DateEntry()];

  void saveTrip() {

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: dateEntries.length + 2,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == dateEntries.length + 1) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 130, right: 130, top: 0),
                child: FlatButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                    color: Color(0xFF074A77),
                  onPressed: saveTrip,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/images/planitLettersOnly.png", fit: BoxFit.fill,),
                  ),
                ),
              ),
            ],
          );
        }
        if (index == dateEntries.length) {
          return Padding(
            padding: const EdgeInsets.only(left: 140, right: 140, top: 15),
            child: FlatButton(
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
              color: Color(0xFF01B2AA),
              onPressed: () {
                setState( () {
                  dateEntries.add(new DateEntry());
                });
              },
              child: Text("Add a Day",
                style: TextStyle(color: Colors.white),),
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
              if (dateEntries.length == 0) {
                dateEntries.add(DateEntry());
              }
            });
          },
        );
      },
    );
  }
}

// --------------------------------------------------------------------------

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

  void _googlePlaceSearch() async {
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleMapsApiKey,
      mode: Mode.fullscreen,
      language: "en-US",
      hint: "Search for Places",
    );
    addNewPlace(p, homeScaffoldKey.currentState);
  }

  Future<Null> addNewPlace(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      if (detail.result != null) {
        setState(() {
          places.add(createPlaceCard(detail.result),);
        });
        scaffold.showSnackBar(
            new SnackBar(content: new Text("${p.description} was successfully added to your trip."))
        );
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
                if (places.length == 0) {
                  return Container(
                    margin: const EdgeInsets.only(top: 15),
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      onPressed: _googlePlaceSearch,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add_box, size: 30,),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Add your first place!"),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (index == places.length) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: Icon(Icons.add_circle, size: 30,),
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

Widget createPlaceCard(PlaceDetails placeDetails) {
  var name = placeDetails.name;
  Widget image;
  if (placeDetails.photos != null) {
    var photoReference = placeDetails.photos.first.photoReference;
    var url = "https://maps.googleapis.com/maps/api/place/photo?photoreference="
        + photoReference + "&sensor=false&maxheight=9000&maxwidth=9000&key="
        + googleMapsApiKey;

    image = CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: 500),
      fadeInCurve: Curves.easeIn,
      placeholder: (BuildContext context, String str) =>  Center(child: CircularProgressIndicator(
        backgroundColor: Color(0xFF074A77),
        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF01B2AA)),
      )),
    );
  }
  else {
    var asset = "assets/images/solidNoNameSmall.png";
    image = Image.asset(asset, fit: BoxFit.cover,);
  }

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
              new GestureDetector(
                child: Container(
                  height: 100,
                  width: 180,
                  child: image,
                ),
                onLongPressEnd: (details) {
                  print("jkdfnkdf");
                  },
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
                        ),
                     ),
                  ),
              ),
              Positioned(
                left:10,
                bottom: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(name,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

