import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'common/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'create_page.dart';
import 'edit_page.dart';



//TOP PART
class NameAndDate extends StatefulWidget {
  const NameAndDate({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _NameAndDateState createState() => _NameAndDateState();
}
class _NameAndDateState extends State<NameAndDate> {
  String _getDate() {
    var day = new DateFormat.EEEE().format(new DateTime.now());
    var month = new DateFormat.MMMMd().format(new DateTime.now());
    var year = new DateFormat.y().format(new DateTime.now());
    return day + ", " + month + ", " + year;
  }
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: WelcomeMessage(uid: widget.user.uid,),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(_getDate(),
              style: new TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class WelcomeMessage extends StatelessWidget {
  final String uid;
  const WelcomeMessage({Key key, this.uid}) : super(key: key);

  String _getWelcome() {
    var hour = new DateTime.now().hour;
    var welcome;
    if (hour > 5 && hour < 12) {
      welcome = "Good Morning, ";
    }
    else if (hour < 17) {
      welcome = "Good Afternoon, ";
    }
    else {
      welcome = "Good Evening, ";
    }
    return welcome;
  }
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(_getWelcome(), style: new TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),);
          }
          else {
            var userDocument = snapshot.data;
            if (userDocument.data != null) {
              return new Text(_getWelcome() + userDocument["firstName"] + "!", style: new TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),);
            }
            else {
              return new Text(_getWelcome(), style: new TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),);
            }
          }
        }
    );
  }
}

// COLLECTIONS

class Collections extends StatefulWidget {

  const Collections({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _CollectionsState createState() => _CollectionsState();
}

class _CollectionsState extends State<Collections> {
  String newCollectionName;
  void displayDialog() {
    newCollectionName = null;
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Create a Collection", textAlign: TextAlign.center,),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              SizedBox(height: 15,),
              TextField(
                onChanged: (newName) {
                  newCollectionName = newName;
                },
                maxLength: 30,
                style: new TextStyle(
                  fontSize: 16,
                ),
                decoration: new InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                  counterText: "",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Ex: Summer Ideas...',
                ),
              ),
            ],
          ),
        ),
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
              if (newCollectionName == null || newCollectionName.trim().length == 0) {
                return;
              }
              createCollection();
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: new Text("Create"),
          )
        ],
      ),
    );
  }

  void createCollection() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference newCollection = Firestore.instance.collection("users").
      document(user.uid).collection("collections").document(newCollectionName);
    CollectionReference trips = newCollection.collection("trips");
    Map<String, dynamic> collectionData = {"collectionName" : newCollectionName};
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(newCollection, collectionData);
      await trips.document("nullTrip").setData({"tripName" : null});
    }).catchError((e) {
      print(e);
    });
  }

  Widget _buildCollections(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView.builder(
        itemCount: snapshots.length + 1,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == snapshots.length) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 90, right: 90, top: 25),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                  color: Color(0xFF01B2AA),
                  onPressed: displayDialog,
                  child: Text("Create a Collection",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            );
          }
          return new StreamBuilder(
            stream: snapshots[index].reference.collection("trips").snapshots(),
            builder: (context, collectionSnapshot) {
              if (!collectionSnapshot.hasData) {
                return Center(
                    child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,), child: LinearProgressIndicator(),)
                );
              }
              return _buildCollection(context, collectionSnapshot.data.documents, snapshots[index]["collectionName"]);
            },
          );
        });
  }

  void goToCreate() {
    tabController.animateTo(1);
  }

  Widget _buildCollection(BuildContext context, List<DocumentSnapshot> snapshots, String title) {
    if (snapshots.length <= 1) {
      return Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 14, top: 15, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF074A77),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ), Container(
            margin: const EdgeInsets.only(top: 35, bottom: 35),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: Container(
                child: FlatButton(
                  onPressed: goToCreate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add_box, size: 30,),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, ),
                        child: Text("Add your first trip!"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 14, top: 15, bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF074A77),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 128,
          child: ListView.builder(
            itemCount: snapshots.length + 1,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == snapshots.length) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      icon: Icon(Icons.add_circle, size: 30,),
                      onPressed: () {
                        tabController.animateTo(1);
                      },
                      color: Colors.black,
                    ),
                  );
              }
              if (snapshots[index]["tripName"] == null) {
                return Container();
              }
              return _buildTripCard(context, snapshots[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, DocumentSnapshot trip) {
    var title = trip["tripName"];
    var imagePath = trip["imagePath"]; // Get image from trip region!!
    Widget image;
    var startDate = trip["startDate"];
    var endDate = trip["endDate"];
    String date = startDate;
    if (endDate != null) {
      date += " - " + endDate;
    }

    if (imagePath != null) {
      image = CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        fadeInDuration: Duration(milliseconds: 500),
        fadeInCurve: Curves.easeIn,
        placeholder: (BuildContext context, String str) =>  Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF074A77),
              valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF01B2AA)),
            )),
      );
    }
    else {
      var asset = "assets/images/solidNoNameSmall.png";
      image = Image.asset(asset, fit: BoxFit.cover,);
    }
    return InkWell(
      onTap: () {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(trip: trip)));
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 120,
                      width: 200,
                      child: image,
                    ),
                    Positioned(
                        width: 200,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [Colors.black, Colors.black.withOpacity(0)]
                              )
                          ),
                        )
                    ),
                    Positioned(
                      left:10,
                      bottom: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                              Text(date, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12)),
                            ],
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        scrollDirection: Axis.vertical,
        // For each collection in users.uid.collections.
        children: <Widget>[
          new NameAndDate(user: widget.user),
          new StreamBuilder(
            stream: Firestore.instance.collection("users").document(widget.user.uid).collection("collections").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,),child: LinearProgressIndicator(),)
                );
              }
              return _buildCollections(context, snapshot.data.documents);
            },
          ),
        ],
      ),
    );
  }
}