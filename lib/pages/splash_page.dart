import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/pages/update_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:uni_links/uni_links.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/splash_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.7),
              BlendMode.lighten,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Zaveri Bazaar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'retailers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  letterSpacing: 1,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    bool launched = false;
    // initial value
    try {
      launched = processUri(await getInitialUri(), true);
    } on FormatException {}

    if (!launched) {
      Future.delayed(Duration(seconds: 2), () async {
        if (!await AuthService.isLoggedIn()) {
          UserLogService.userLogById("000", 'App usage log').then((res) {
            print("userLogById Success");
          }).catchError((err) {
            print("userLogById Error:" + err.toString());
          });
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }

        try {
          final User user = await AuthService(context).profile();
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          final pref =
              Platform.isIOS ? user.preference.iOS : user.preference.android;

          /*if (int.parse(pref['version']) > int.parse(packageInfo.buildNumber)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => UpdatePage(
                  url: pref['url'],
                  whatsNew: pref['whats_new'],
                ),
              ),
            );
          } else {*/
          UserLogService.userLogById("000", 'App usage log').then((res) {
            print("userLogById Success");
          }).catchError((err) {
            print("userLogById Error:" + err.toString());
          });
          Navigator.of(context).pushReplacementNamed('/main');
          // }
        } catch (e) {
          UserLogService.userLogById("000", 'App usage log').then((res) {
            print("userLogById Success");
          }).catchError((err) {
            print("userLogById Error:" + err.toString());
          });
          Navigator.of(context).pushReplacementNamed('/main');
        }
      });
    }
  }

  bool processUri(Uri uri, bool delayed) {
    if (uri == null) return false;

    if (uri.path.startsWith("/app/wholesaler-firms/") &&
        uri.pathSegments.length == 3) {
      if (delayed) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WholesalerViewPage(
                wholesalerId: uri.pathSegments[2],
              ),
            ),
          );
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WholesalerViewPage(
              wholesalerId: uri.pathSegments[2],
            ),
          ),
        );
      }

      return true;
    }

    return false;
  }

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }
}
