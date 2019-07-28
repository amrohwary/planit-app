import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 15, top: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Workspace",
              style: new TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Create a New Trip!",
              style: new TextStyle(
                fontSize: 20,
//                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        new NewTripForm(),
      ],
    );
  }
}

class NewTripForm extends StatefulWidget {
  @override
  _NewTripFormState createState() => _NewTripFormState();
}

class _NewTripFormState extends State<NewTripForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return "Trip name is required";
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "Trip Name",
                labelStyle: new TextStyle(color: Colors.black),
              ),
            ),
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return "Start date is required";
                }
                return null;
              },
              decoration: new InputDecoration(
                labelText: "Start Date",
                labelStyle: new TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
