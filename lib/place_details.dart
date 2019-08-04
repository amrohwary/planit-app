import 'package:flutter/material.dart';
import 'api_keys.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);

class PlaceDetailsPage extends StatelessWidget {
  final String placeId;

  Future<Null> getPlaceDetails() async  {
    final PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
  }
  PlaceDetailsPage({Key key, this.placeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
