import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
        //user.sendEmailVerification();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(user: user)));
      } catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        color: Color(0xFF074A77),
        padding: new EdgeInsets.symmetric(horizontal: 30),
        child: new Form(
          key: _formKey,
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 125,),
              Text("Welcome to Planit!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Colors.white,)
              ),
              Text("Get started in Seconds",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Colors.white,)),
              new SizedBox(height: 30,),
              new Image.asset("assets/images/solidLogoNoName.png",
                height: 150,),
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
                    labelStyle: new TextStyle(color: Colors.white)),),
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
            ],
          ),
        ),
      ),
    );
  }
}
