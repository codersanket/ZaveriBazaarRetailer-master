import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonaar_retailer/pages/login_page.dart';
import 'package:sonaar_retailer/pages/main_page.dart';
import 'package:sonaar_retailer/pages/signup-contacts.dart';
import 'package:sonaar_retailer/pages/splash_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

final primaryColor = Color(0xff004272);
final accentColor = Color(0xff004272);

const MaterialColor primaryPalette = MaterialColor(0xFF004272, <int, Color>{
  50: Color(0xFFE0E8EE),
  100: Color(0xFFB3C6D5),
  200: Color(0xFF80A1B9),
  300: Color(0xFF4D7B9C),
  400: Color(0xFF265E87),
  500: Color(0xFF004272),
  600: Color(0xFF003C6A),
  700: Color(0xFF00335F),
  800: Color(0xFF002B55),
  900: Color(0xFF001D42),
});

const MaterialColor primaryPaletteAccent =
    MaterialColor(0xFF4484FF, <int, Color>{
  100: Color(0xFF77A5FF),
  200: Color(0xFF4484FF),
  400: Color(0xFF1162FF),
  700: Color(0xFF0054F6),
});

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {
  runApp(
    MaterialApp(
      title: 'Zaveri Bazaar',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.grey.shade200,
        scaffoldBackgroundColor: Colors.grey.shade200,
        primarySwatch: primaryPalette,
        accentColor: primaryPalette,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary,
          colorScheme: ColorScheme.light().copyWith(primary: primaryColor),
        ),
      ),
      home: SplashPage(),
      //home: ContactsPage(),
      routes: {
        '/main': (context) => MainPage(),
        '/login': (context) => LoginPage(),
      },
    ),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // For contacts
  if (prefs.getString('device_id') == null) {
    prefs.setString('device_id', Uuid().v1());
  }

  // open database
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'notifications_db.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT)",
      );
    },
    version: 1,
  );

  // init firebase messaging
  await initFCM(prefs, database);

  // orientation config
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // deeplink config
  initUniLinks();
}

Future<Null> initUniLinks() async {
  // on change
  getUriLinksStream().listen(processUri);
}

void processUri(Uri uri) {
  if (uri == null) return;

  if (uri.path.startsWith("/app/wholesaler-firms/") &&
      uri.pathSegments.length == 3) {
    navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (_) => WholesalerViewPage(wholesalerId: uri.pathSegments[2]),
      ),
    );
  }
}

initFCM(SharedPreferences prefs, Future<Database> database) async {
  final FirebaseMessaging messaging = FirebaseMessaging();

  await messaging.subscribeToTopic('sonaar.retailer.all-users');

  if (prefs.getString('fcmToken') == null) {
    messaging.getToken().then((token) {
      prefs.setString('fcmToken', token);
    });
  }

  messaging.configure(
    onMessage: (Map<String, dynamic> data) async {
      print('on message $data');
      saveNotification(data, database);
    },
    onResume: (Map<String, dynamic> data) async {
      print('on resume $data');
      saveNotification(data, database);

      // TODO: Navigate based on data
      // navigatorKey.currentState.push(
      //   MaterialPageRoute(builder: (_) => PostsPage()),
      // );
    },
    onLaunch: (Map<String, dynamic> data) async {
      print('on launch $data');
      saveNotification(data, database);

      // TODO: Navigate based on data
      // navigatorKey.currentState.push(
      //   MaterialPageRoute(builder: (_) => PostsPage()),
      // );
    },
  );

  if (Platform.isIOS) {
    await messaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}

saveNotification(Map<String, dynamic> data, Future<Database> database) async {
  final Database db = await database;
  await db.insert(
    'notifications',
    {
      'title': data['notification']['title'].toString(),
      'body': data['notification']['body'].toString(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
