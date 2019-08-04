import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'common/appbar.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName, _lastName, _email, _password;

  void signUp() async {
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password).then((data) {
          this.createUser(data);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(user: data)));
        }).catchError((e) {print(e.message);});
      } catch (e) {
        showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: new Text(e.message),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: new Text("Close")),
                ],
              );
            }
        );
      }
    }
  }

  /*
  Add users first and last name to Firestore database.
   */
  void createUser(FirebaseUser user) {
    Map<String, dynamic> userData = new Map<String, dynamic>();
    userData["firstName"] = _firstName;
    userData["lastName"] = _lastName;

    DocumentReference userFile = Firestore.instance.collection("users").document(user.uid);
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(userFile, userData);
    }).catchError((e) {
      print(e.message);
    });

    userFile.get().then((data) {
      print("data: " + data.toString());
    });
  }

  void goToSignIn() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        color: Color(0xFF074A77),
        padding: new EdgeInsets.symmetric(horizontal: 30),
        child: new Form(
          key: _formKey,
          child: new ListView(
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              new SizedBox(height: 70,),
              Text("Welcome to Planit!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Colors.white,)
              ),
              Text("Create an Account!",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Colors.white,)),
              new SizedBox(height: 30,),
              Image.asset("assets/images/solidNoNameSmall.png",
                height: 200,),
              new SizedBox(height: 30,),
              new TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return "Input your first name";
                  }
                  return null;
                },
                onSaved: (input) => _firstName = input,
                style: new TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                  labelText: "First Name",
                  labelStyle: new TextStyle(color: Colors.white),
                ),
              ),
              new TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return "Input your last name";
                  }
                  return null;
                },
                onSaved: (input) => _lastName = input,
                style: new TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                  labelText: "Last Name",
                  labelStyle: new TextStyle(color: Colors.white),
                ),
              ),
              new TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return "Provide an email";
                  }
                  return null;
                },
                onSaved: (input) => _email = input,
                style: new TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                  labelText: "Email",
                  labelStyle: new TextStyle(color: Colors.white),
                ),
              ),
              new TextFormField(
                validator: (input) {
                  if(input.length < 6) {
                    return 'Longer password please';
                  }
                  return null;
                },
                onSaved: (input) => _password = input,
                style: new TextStyle(color: Colors.white),
                obscureText: true,
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                    labelText: "Password",
                    labelStyle: new TextStyle(color: Colors.white)),
              ),
              new SizedBox(
                height: 10,
              ),
              new RaisedButton(
                color: Color(0xFF01B2AA),
                child: new Text(
                  "Sign Up",
                  style: new TextStyle(color: Colors.white,),
                ),
                onPressed: signUp,
              ),
              new FlatButton(
                // color: Color(0xFF01B2AA),
                child: new Text(
                  "Already have an account? Sign in",
                  style: new TextStyle(color: Colors.white,),
                ),
                onPressed: goToSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
