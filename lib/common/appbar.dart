import 'package:flutter/material.dart';

class CustomTabController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
}


Widget getTabBar() {
  return TabBar(
    indicatorColor: Colors.black,
    labelColor: Colors.black,
    tabs: [
      Tab(icon: Icon(Icons.edit)),
      Tab(icon: Icon(Icons.account_circle)),
      Tab(icon: Icon(Icons.public)),
    ],
  );
}

Widget getTabBarPages() {
  return TabBarView(
    children: [
      Container(
          color: Colors.white,
          child: Icon(Icons.edit)),
      Container(
          color: Colors.white,
          child: Icon(Icons.account_circle)
      ),
      Container(
          color: Colors.white,
          child: Icon(Icons.public)),
    ],
  );
}

