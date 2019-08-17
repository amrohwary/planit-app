import 'package:flutter/material.dart';
var months = {"Jan" : 1, "Feb" : 2, "Mar" : 3, "Apr" : 4, "May" : 5, "Jun" : 6,
  "Jul" : 7, "Aug" : 8, "Sep": 9, "Oct" : 10, "Nov" : 11, "Dec" : 12};

DateTime parseDate(String date) {
  int month = months[date.split(" ").first];
  int day = int.parse(date.split(" ")[1].replaceAll(",", ""));
  int year = int.parse(date.split(" ")[2]);
  return new DateTime(year, month, day);
}