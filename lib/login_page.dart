import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planit/sign_up.dart';

import 'common/appbar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  void signIn() async {
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try{
        FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(user: user)));
      }catch(e) {
        showDialog(context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: new Text("Invalid Username or Password."),
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

  void resetPassword() async {
      _formKey.currentState.save();
      if (_email != null) {
        try{
          await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);

          showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: new Text("An email has been sent to " + _email + " with instructions on how to reset your password."),
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
        } catch(e) {
          showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: new Text("The provided email address is not associated with a Planit account."),
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

  void signUp() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
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
              new SizedBox(height: 120,),
              new Image.asset("assets/images/solidBackgroundLogo.JPG",
              height: 250,),
              new SizedBox(height: 70,),
              new TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return "Email is required";
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
                  if(input.length < 6){
                    return 'Password must be 6 characters';
                  }
                  return null;
                },
                onSaved: (input) => _password = input,
                style: new TextStyle(color: Colors.white),
                obscureText: true,
                cursorColor: Colors.white,
                decoration: new InputDecoration(
                    labelText: "Password",
                    labelStyle: new TextStyle(color: Colors.white)),),
              new SizedBox(
                height: 10,
              ),
              new RaisedButton(
                color: Color(0xFF01B2AA),
                  child: new Text(
                    "Login",
                    style: new TextStyle(color: Colors.white,),
                  ),
                  onPressed: signIn,
              ),
              Container(
                height: 35,
                child: new FlatButton(
                  child: new Text(
                    "Create a new Account",
                    style: new TextStyle(color: Colors.white,),
                  ),
                  onPressed: signUp,
                ),
              ),

              Container(
                height: 15,
                child: new FlatButton(
                  child: new Text(
                    "Reset Password",
                    style: new TextStyle(color: Colors.white,),
                  ),
                  onPressed: resetPassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
