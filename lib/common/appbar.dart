import 'package:flutter/material.dart';
import 'package:planit/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../create_page.dart';

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
          backgroundColor: Color(0xff074A77),
          elevation: 0,
          flexibleSpace: SafeArea(
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                tabs: [
                  Tab(
                    child: Image.asset("assets/images/solidNoNameSmall.png",
                      height: 150,
                    ),
                  ),
                  Tab(icon: Icon(Icons.edit,
                  size: 30,
                  color: Colors.white,)),
                ],
              ),
          ),
        ),
        body: TabBarView(
          children: [
            // Profile Page
            Container(
              color: Colors.white,
              child: new Collections(user: widget.user),
            ),
            // Create Page
            Container(
                color: Colors.white,
                child: CreatePage(),
            )
          ],
        ),
      ),
    );
  }
}
