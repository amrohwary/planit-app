import 'package:flutter/material.dart';
import 'login_page.dart';
import 'styleguide/stylesheet.dart';

void main() => runApp(MyApp());



ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  backgroundColor: backgroundColor,
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.white,
      ),
      home: LoginPage(),
    );
  }
}