import 'package:flutter/material.dart';
import 'package:planit/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*class CustomTabController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
              child: getTabBar()
          ),
        ),
        body: getTabBarPages(),
      ),
    );
  }
}*/

class Home extends StatefulWidget {
  const Home({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
              child: TabBar(
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                tabs: [
                  Tab(
                    child: new Image.asset("assets/images/logoTransparent.png",
                      height: 150,
                    ),
                  ),
                  Tab(icon: Icon(Icons.edit)),
                ],
              ),
          ),
        ),
        body: TabBarView(
          children: [

            // Profile Page
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  new NameAndDate(user: widget.user),
                ],
              ),
            ),



            // Create Page
            Container(
                color: Colors.white,
                child: Icon(Icons.edit)),
          ],
        ),
      ),
    );
  }
}
