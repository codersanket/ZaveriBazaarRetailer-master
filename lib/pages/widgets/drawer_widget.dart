import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/notifications_page.dart';
import 'package:sonaar_retailer/pages/products_categorywise_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_ratings_page.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:sonaar_retailer/services/wholesaler_firm_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  final scaffoldKey;
  const DrawerWidget({Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  User authUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authUser = AuthService.user;
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 160,
            child: DrawerHeader(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Zaveri Bazaar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () => showNotifications(context),
          ),
          ListTile(
            leading: Icon(Icons.apps),
            title: Text('My favourites'),
            // subtitle: Text('Products bookmarked by you'),
            onTap: () => showProducts(context),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Wholesaler ratings'),
            onTap: () => showRatings(context),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Inquiry'),
            subtitle: Text('Contact us via whatsapp.'),
            onTap: doInquiry,
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text('Deals'),
            subtitle: Text('Coming soon!'),
            onTap: () => showToast(context, 'Deals'),
          ),
          ListTile(
            leading: Icon(Icons.collections),
            title: Text('Exclusive'),
            subtitle: Text('Coming soon!'),
            onTap: () => showToast(context, 'Exclusive'),
          ),
        ],
      ),
    );
  }

  showProducts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductsCategorywisePage(onlyBookmarked: true),
      ),
    );
  }

  showNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsPage(),
      ),
    );
  }

  showRatings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WholesalerRatingsPage(),
      ),
    );
  }

  doInquiry() {
    final mobile = AuthService.user.preference.productWhatsapp;
    UserLogService.userLogById(authUser.id.toString(), 'zaveri inquiry')
        .then((res) {
      print("userLogById Success");
    }).catchError((err) {
      print("userLogById Error:" + err.toString());
    });

    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    launch("https://api.whatsapp.com/send?phone=919321463461&text=" +
        "Hi I am a Zaveri bazaar buyer app user my name is\n $firmName from $city\n "
            "I am searching for some product/dealer can you help me with it. ");
  }

  showToast(BuildContext context, String title) {
    // ToastService.info(scaffoldKey, 'Coming soon!');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('Coming soon!'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              textColor: Theme.of(context).primaryColor,
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
}
