import 'package:flutter/material.dart';
import 'package:sonaar_retailer/pages/bullion/bullion_city_page.dart';
import 'package:sonaar_retailer/pages/follows/follows_page.dart';
import 'package:sonaar_retailer/pages/posts_page.dart';
import 'package:sonaar_retailer/pages/products_categorywise_page.dart';
import 'package:sonaar_retailer/pages/profile_page.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageStage createState() => _MainPageStage();
}

class _MainPageStage extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    AuthService.getUser().then((res) {
      if (res.approved == 1) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        if (index == 1 || index == 2 || index == 3 || index == 4) {
          showInfoDialog(context, 'Info',
              'Your account is not approved, please contact us on below number\n\n7208226814');
          return;
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<String> showInfoDialog(
      BuildContext context, String titleText, String contentText) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(titleText),
                  CloseButton(
                      color: Colors.black87,
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]),
            content: SingleChildScrollView(child: Text(contentText)),
            actions: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ButtonTheme(
                        minWidth: 25.0,
                        height: 40.0,
                        child: FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text('Call'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            call();
                          },
                        )),
                    SizedBox(width: 8.0),
                    ButtonTheme(
                        minWidth: 25.0,
                        height: 40.0,
                        child: FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text('Message'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            whatsappRetailer();
                          },
                        )),
                    SizedBox(width: 8.0),
                  ]))
            ]);
      },
    );
  }

  /*Future<String> showInfoDialog(BuildContext context, String titleText, String contentText) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text('Message'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      whatsappRetailer();
                    },
                  ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text('Call'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      call();
                    },
                  ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ]
            )
          ],
        );
      },
    );
  }*/

  call() {
    launch("tel://917208226814");
  }

  void whatsappRetailer() {
    launch("https://api.whatsapp.com/send?phone=917208226814");
  }

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      //BullionCityPage(),
      PostsPage(onTabChange: _onItemTapped),
      Visibility(
        visible: true,
        child: ProductsCategorywisePage(),
      ),
      ProductsCategorywisePage(whatsNew: true),
      FollowsPage(),
      // Visibility widget used for fixing refresh for two same widgets in bottombar
      // Visibility(
      //   visible: true,
      //   child: ProductsCategorywisePage(onlyBookmarked: true),
      // ),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: ImageIcon(
          //     AssetImage("images/ic_gold_grey.png"),
          //   ),
          //   title: Text('Bullion', style: TextStyle(fontSize: 12.0)),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            title: Text('Feed', style: TextStyle(fontSize: 12.0)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            title: Text('Products', style: TextStyle(fontSize: 12.0)),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/new.png')),
            title: Text('Arrivals', style: TextStyle(fontSize: 12.0)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Following', style: TextStyle(fontSize: 12.0)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile', style: TextStyle(fontSize: 12.0)),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}
