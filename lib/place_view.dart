import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'api_keys.dart';

class PlaceView extends StatefulWidget {
  final PlaceDetails placeDetails;

  const PlaceView({Key key, this.placeDetails}) : super(key: key);

  @override
  _PlaceViewState createState() => _PlaceViewState();
}

class _PlaceViewState extends State<PlaceView> {
  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${googleMapsApiKey}";
  }

  ListView buildPlaceDetailList() {
    List<Widget> list = [];

    list.add(
      Padding(
          padding: EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 7),
          child: Text(widget.placeDetails.name,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    );

    if (widget.placeDetails.types?.first != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0, bottom: 6.0),
            child: Text(
                widget.placeDetails.types.first
                    .toUpperCase()
                    .replaceAll("_", " "),
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold))),
      );
    }

    if (widget.placeDetails.rating != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              "Rating: ${widget.placeDetails.rating} / 5.0",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            )),
      );
    }

    if (widget.placeDetails.openingHours != null) {
      final openingHour = widget.placeDetails.openingHours;
      var text = '';
      var check = false;
      if (openingHour.openNow) {
        text = 'OPEN';
        check = true;
      } else {
        text = 'CLOSED';
      }
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 3.0, left: 8.0, right: 10.0, bottom: 4.0),
            child: Text(text,
                style: TextStyle(
                  fontSize: 16,
                  color: check ? Colors.green : Colors.red,
                ))),
      );
    }

    if (widget.placeDetails.formattedAddress != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 2.0),
            child: Text("Address: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      );

      list.add(
        Padding(
          padding:
              EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(widget.placeDetails.formattedAddress,
              style: TextStyle(
                fontSize: 16,
              )),
        ),
      );
    }

    if (widget.placeDetails.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 2.0),
            child: Text("Phone: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      );
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Text(
              widget.placeDetails.formattedPhoneNumber,
              style: Theme.of(context).textTheme.button,
            )),
      );
    }

    if (widget.placeDetails.website != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 2.0),
            child: Text("Website: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      );

      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              widget.placeDetails.website,
              style: Theme.of(context).textTheme.button,
            )),
      );
    }

    if (widget.placeDetails.photos != null) {
      final photos = widget.placeDetails.photos;
      list.add(SizedBox(
          height: 300.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(right: 1.0, top: 30),
                    child: SizedBox(
                      height: 400,
                      child: Image.network(
                          buildPhotoURL(photos[index].photoReference)),
                    ));
              })));
    }

    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeDetails.name),
        backgroundColor: Color(0xff074A77),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: buildPlaceDetailList(),
          )
        ],
      ),
    );
  }
}
