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
import 'place_view.dart';
import 'dart:convert';
import 'dart:io';
import 'parse_dates.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
var uuid = new Uuid();

class EditPage extends StatefulWidget {
  final DocumentSnapshot trip;
  const EditPage({Key key, this.trip}) : super(key: key);
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String title;
  String city;
  String cityId;
  String collection = "Select a Collection for this trip";
  int selectedCollectionIndex = 0;
  List<DateEntry> dateEntries = [];

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initializeTrip());
  }

  void initializeTrip() async {
    List<DateEntry> defaultDateEntries = [];
    var dates = widget.trip["lines"];
    for (var i = 0; i < dates.length; i++) {
      List<PlaceCard> places = [];
      for (var j = 0; j < dates[i]["places"].length; j++) {
        var placeId = dates[i]["places"][j];
        PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
        PlaceDetails placeDetails = detail.result;
        places.add(new PlaceCard(placeId: placeId, placeDetails: placeDetails,));
      }
      defaultDateEntries.add(
          new DateEntry(
            date: dates[i]["date"],
            description: dates[i]["dailySummary"],
            places: places,
            dateAsDateTime: parseDate(dates[i]["date"]),
      ));
    }
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(widget.trip["location"]);
    PlaceDetails placeDetails = detail.result;

    setState(() {
      dateEntries = defaultDateEntries;
      title = widget.trip["tripName"];
      cityId = widget.trip["location"];
      city = placeDetails.name;
      collection = widget.trip["collection"];
    });
  }

  void showInvalidDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        content: new Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            isDefaultAction: false,
            child: new Text("Close"),
          )
        ],
      ),
    );
  }

  void saveTrip() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var valid = true;
    if (title == null || title.trim().length == 0) {
      showInvalidDialog("Please enter a valid title");
      return;
    }
    if (cityId == null) {
      showInvalidDialog("Please select a destination");
      return;
    }
    if (collection == "Select a Collection for this trip") {
      showInvalidDialog("Please indicate a collection for this trip to be added to");
      return;
    }

    List<Map> lines = [];
    List<DateTime> dates = [];
    for (DateEntry dateEntry in dateEntries) {
      if (dateEntry.dateAsDateTime == null) {
        showInvalidDialog("Please specify a date for each line");
        return;
      }
      Map<String, dynamic> currentLine = {};
      currentLine["dailySummary"] = dateEntry.description;
      currentLine["date"] = dateEntry.date;
      dates.add(dateEntry.dateAsDateTime);
      List<String> places = [];
      for (PlaceCard placeCard in dateEntry.places) {
        // ignore: unnecessary_statements
        places.add(placeCard.placeId);
      }
      currentLine["places"] = places;
      lines.add(currentLine);
    }
    dates.sort();
    String startDate = DateFormat.yMMMd().format(dates[0]).toString();
    String endDate;
    if (dates.length > 1) {
      endDate = DateFormat.yMMMd().format(dates[dates.length - 1]).toString();
    }

    String imagePath;
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(cityId);
    if (detail.result != null && detail.result.photos != null) {
      var photoReference = detail.result.photos.first.photoReference;
      imagePath = "https://maps.googleapis.com/maps/api/place/photo?photoreference="
          + photoReference + "&sensor=false&maxheight=9000&maxwidth=9000&key="
          + googleMapsApiKey;
    }

    Map<String, dynamic> trip = {"tripName" : title, "imagePath" : imagePath,
      "startDate" : startDate, "endDate" : endDate, "location" : cityId, "lines"
          : lines, "collection" : collection};
    if (valid) {
      await Firestore.instance.collection("users").document(user.uid)
          .collection("collections").document(collection).collection("trips").
      document(title).setData(trip);
    }
    else {
      print("invalid trip");
    }
    Navigator.pop(context);
  }

  Future<List> _getCollectionsFromFirestore() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot ref = await Firestore.instance.collection('users').document
      (user.uid).collection("collections").getDocuments();

    List<String> collectionChoices = [];
    ref.documents.forEach((document) {
      if (!collectionChoices.contains(document["collectionName"])) {
        collectionChoices.add(document["collectionName"]);
      }
    });
    return collectionChoices;
  }

  Widget buildListOfDates() {
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
                padding: const EdgeInsets.only(left: 110, right: 110, top: 0),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                  color: Color(0xFF074A77),
                  onPressed: saveTrip,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Image.asset("assets/images/planitLettersOnly.png", fit: BoxFit.fill,),
                  ),
                ),
              ),
            ],
          );
        }
        if (index == dateEntries.length) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 130, right: 130, top: 15),
              child: FlatButton(
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                color: Color(0xFF01B2AA),
                onPressed: () {
                  setState(() {
                    dateEntries.add(new DateEntry(
                      description: "",
                      date: "Select Date",
                      places: [],
                    ));
                  });
                },
                child: Text("Add a Day",
                  style: TextStyle(color: Colors.white, fontSize: 16), ),
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
              if (dateEntries.length == 0) {
                dateEntries.add(DateEntry());
              }
            });
          },
        );
      },
    );
  }

  void selectCollection() async {
    List<String> collectionChoices = await _getCollectionsFromFirestore();
    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: selectedCollectionIndex);
    if (collectionChoices.length == 1) {
      setState(() {
        collection = collectionChoices[0];
      });
    }
    showModalBottomSheet(context: context, builder: (BuildContext builder) {
      return Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker.builder(
          backgroundColor: Colors.white,
          itemExtent: 30,
          magnification: 1.5,
          scrollController: scrollController,
          childCount: collectionChoices.length,
          itemBuilder: (context, index) {
            return Text(collectionChoices[index]);
          },
          squeeze: 0.8,
          onSelectedItemChanged: (item) {
            setState(() {
              selectedCollectionIndex = item;
              collection = collectionChoices[item];
            });
          },
        ),
      );
    });
  }

  void selectLocation(newLocation) async {
    var url =  "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?&key=${googleMapsApiKey}&input=${newLocation}";
    var request = await new HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    String predictions = "";
    await for (String data in response.transform(Utf8Decoder())) {
      predictions += data;
    }
    var placeId;
    try {
      Map parsedResponse = json.decode(predictions);
      placeId = parsedResponse["predictions"].first["place_id"];
    } catch (e) {
      print("error!");
      placeId = null;
    }
    setState(() {
      this.cityId = placeId;
      city = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleController = new TextEditingController();
    titleController.text = title;
    var locationController = new TextEditingController();
    locationController.text = city;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.trip["tripName"] + " Summary"),
        backgroundColor: Color(0xff074A77),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 22),
            child: Container(
              padding: const EdgeInsets.only(right: 15),
              child: TextField(
                controller: titleController,
                readOnly: true,
                enabled: false,
                onChanged: (newTitle) {
                  setState(() {
                    title = newTitle;
                  });
                },
                maxLength: 30,
                style: new TextStyle(
                  fontSize: 25,
                ),
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: -2),
                  counterText: "",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 0,
            ),
            height: 40,
            child: PlacesAutocompleteField(
              controller: locationController,
              types: ["(regions)",],
              mode: Mode.overlay,
              hint: "Where are you going?",
              onChanged: (newCity) {
                selectLocation(newCity);
              },
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
                    onPressed: () {
                      selectCollection();
                    },
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
          buildListOfDates(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class DateEntry extends StatefulWidget {
  String id = uuid.v1();
  List<PlaceCard> places = [];
  String date = "Select Date";
  String description = "";

  DateEntry({Key key, this.places, this.date, this.description, this.dateAsDateTime}) : super(key: key);
  String get uniqueId {
    return this.id;
  }
  DateTime dateAsDateTime;
  DateTime lastDate = DateTime.now();


  @override
  _DateEntryState createState() => _DateEntryState();
}

class _DateEntryState extends State<DateEntry> {
  void _showDatePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: CupertinoDatePicker(
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  widget.lastDate = newDate;
                  widget.dateAsDateTime = newDate;
                  widget.date = DateFormat.yMMMd().format(newDate).toString();
                });
              },
              initialDateTime: widget.lastDate,
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
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      if (detail.result != null) {
        setState(() {
          widget.places.add(new PlaceCard(placeDetails: detail.result, placeId: p.placeId));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var dailySummaryController = new TextEditingController();
    dailySummaryController.text = widget.description;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 0),
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width - 138,
                  height: 40,
                  child: TextField(
                    controller: dailySummaryController,
                    onChanged: (newDescription) {
                      setState(() {
                        widget.description = newDescription;
                      });
                    },
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
                  width: 120,
                  height: 30,
                  child: FlatButton(
                    child: Text(widget.date),
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
              itemCount: widget.places.length + 1,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (widget.places.length == 0) {
                  return Container(
                    margin: const EdgeInsets.only(top: 15,),
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90.0),
                      child: Container(
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
                      ),
                    ),
                  );
                }
                if (index == widget.places.length) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: Icon(Icons.add_circle, size: 30,),
                      onPressed: _googlePlaceSearch,
                      color: Colors.black,
                    ),
                  );
                }
                return InkWell(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                      new CupertinoAlertDialog(
                        content: new Text("Are you sure you want to remove "
                            + widget.places[index].placeDetails.name +
                            " from your trip?"),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            isDefaultAction: false,
                            child: new Text("Cancel"),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              setState(() {
                                widget.places.removeAt(index);
                              });
                              Navigator.pop(context);
                            },
                            isDefaultAction: true,
                            child: new Text("Confirm"),
                          )
                        ],
                      ),
                    );
                  },
                  onTap: () {
                    return Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            PlaceView(placeDetails: widget.places[index]
                                .placeDetails,)));
                  },
                  child: widget.places[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class PlaceCard extends StatefulWidget {
  const PlaceCard({Key key, this.placeDetails, this.placeId}) : super(key: key);
  final PlaceDetails placeDetails;
  final String placeId;
  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  @override
  Widget build(BuildContext context) {
    var name = widget.placeDetails.name;
    Widget image;
    if (widget.placeDetails.photos != null) {
      var photoReference = widget.placeDetails.photos.first.photoReference;
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

    return Container(
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
                    child: image,
                  ),
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
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(name,
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12),
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
      ),
    );
  }
}
