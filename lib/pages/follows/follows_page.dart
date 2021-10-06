import 'package:flutter/material.dart';
import 'package:sonaar_retailer/pages/follows/contacts_page.dart';
import 'package:sonaar_retailer/pages/follows/followers_page.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';

class FollowsPage extends StatefulWidget {
  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Zaveri Bazaar',
            style: TextStyle(fontFamily: 'serif'),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Following'),
              Tab(text: 'Suggestions'),
            ],
          ),
        ),
        drawer: DrawerWidget(scaffoldKey: _scaffoldKey),
        body: TabBarView(
          children: [
            FollowingPage(),
            ContactsPage(),
          ],
        ),
      ),
    );
  }
}
