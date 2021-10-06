import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var isLoading = true;
  List<Map<String, dynamic>> notifications = [];

  Future<Database> database;

  @override
  void initState() {
    super.initState();

    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Notifications')),
      body: notifications.length == 0
          ? buildErrorWidget()
          : Stack(
              children: <Widget>[
                buildListView(),
                Visibility(
                  visible: isLoading,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.info_outline, size: 32),
          SizedBox(height: 16),
          Text('No notifications found!'),
        ],
      ),
    );
  }

  Widget buildListView() {
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (ctx, i) => Divider(height: 1, thickness: 1),
      itemBuilder: buildListItem,
    );
  }

  Widget buildListItem(BuildContext context, int index) {
    final notification = notifications[index];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.notifications,
            color: Colors.grey.shade700,
          ),
          SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notification['title'] ?? '',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  notification['body'] ?? '',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  fetchNotifications() async {
    setState(() => isLoading = true);

    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'notifications_db.db'),
    );

    final Database db = await database;
    notifications = await db.query(
      'notifications',
      limit: 100,
      orderBy: 'id DESC',
    );

    setState(() => isLoading = false);
  }
}
