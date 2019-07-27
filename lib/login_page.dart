import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        color: Color(0xFF074A77),
        padding: new EdgeInsets.symmetric(horizontal: 30),
        child: new Form(
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 120,),
              new Image.asset("assets/images/solidBackgroundLogo.JPG",
              height: 250,),
              new SizedBox(height: 70,),
              new TextFormField(
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                  labelText: "Email",
                  labelStyle: new TextStyle(color: Colors.white),
              ),
              ),
              new TextFormField(
                obscureText: true,
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                    labelText: "Password",
                    labelStyle: new TextStyle(color: Colors.white)),),
              new RaisedButton(
                  child: new Text(
                    "Login", style: new TextStyle(color: Colors.white,),
                  ),
                  onPressed: null
              ),
            ],
          ),
        ),
      ),
    );
  }
}
