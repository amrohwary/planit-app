import 'package:flutter/material.dart';
import 'package:planit/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../create_page.dart';

TabController tabController;

final homeScaffoldKey = new GlobalKey<ScaffoldState>();
class Home extends StatefulWidget {
  const Home({Key key, this.user}) : super(key: key);
  final FirebaseUser user;
  @override
  _HomeState createState() => _HomeState();
}



class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  void _toggleTab() {
    _tabIndex = (tabController.index + 1) % 2;
    tabController.animateTo(_tabIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff074A77),
        elevation: 0,
        flexibleSpace: SafeArea(
            child: TabBar(
              controller: tabController,
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
        controller: tabController,
        children: [
          // Profile Page
          Container(
            color: Colors.white,
            child: new Collections(user: widget.user),
          ),
          // Create Page
          Container(
              color: Colors.white,
              child: CreatePage(user: widget.user),
          )
        ],
      ),
    );
  }
}
