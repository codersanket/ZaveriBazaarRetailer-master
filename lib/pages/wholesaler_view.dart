import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/posts_page.dart';
import 'package:sonaar_retailer/pages/products_categorywise_page.dart';
import 'package:sonaar_retailer/pages/products_page.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:sonaar_retailer/services/wholesaler_firm_service.dart';
import 'cached_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
User authUser;
class WholesalerViewPage extends StatefulWidget {
  final String wholesalerId;
  final Function(WholesalerFirm wholesaler) onChange;

  WholesalerViewPage({Key key, @required this.wholesalerId, this.onChange})
      : super(key: key);

  @override
  _WholesalerViewState createState() => _WholesalerViewState();
}

class _WholesalerViewState extends State<WholesalerViewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  WholesalerFirm firm;
  bool isLoading = false;
  var error;
  @override
  void initState() {
    super.initState();
    authUser = AuthService.user;
    fetchWholesaler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Wholesaler details')),
      body: error != null
          ? Center(child: Text(error.toString()))
          : isLoading || firm == null
              ? Center(child: CircularProgressIndicator(strokeWidth: 2.0))
              : Profile(firm: firm, parent: this),
    );
  }

  void follow() {
    setState(() => isLoading = true);
    FollowService.create(firmId: firm.id).then((res) {
      ToastService.success(
        scaffoldKey,
        'You are now following ${firm.name}!',
      );
      setState(() => firm.followId = res.id);
    }).catchError((err) {
      ToastService.error(scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void unfollow() {
    setState(() => isLoading = true);
    FollowService.delete(firm.followId).then((res) {
      ToastService.success(
        scaffoldKey,
        'You are no longer following ${firm.name}!',
      );
      setState(() => firm.followId = null);
    }).catchError((err) {
      ToastService.error(scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void fetchWholesaler() {
    setState(() => isLoading = true);

    WholesalerFirmService.getById(widget.wholesalerId).then((res) {
      setState(() {
        firm = res;
        error = null;
        print(firm);
      });
    }).catchError((err) {
      setState(() => error = err);
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }
}

class Profile extends StatelessWidget {
  final WholesalerFirm firm;
  final _WholesalerViewState parent;

  const Profile({
    Key key,
    @required this.firm,
    @required this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Details
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                // Name
                GestureDetector(
                  child: ListTile(
                    leading: Hero(
                      tag: "Wholesaler_firm",
                      child: CachedImage(
                        imageUrl: firm.thumbUrl,
                        width: 30,
                        height: 30,
                        placeholderIcon: Icons.person,
                      ),
                    ),
                    title: Text(firm.name),
                  ),
                  onTap: firm.imageUrl != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageView(
                                imageUrl: firm.imageUrl,
                                heroTag: 'Wholesaler_firm',
                              ),
                            ),
                          );
                        }
                      : null,
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // Address
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(firm.address),
                  subtitle: Text(firm.pincode ?? "Pincode not available"),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // Mobile number
                ListTile(
                  onTap: call,
                  leading: Icon(Icons.phone),
                  title: Text(firm.mobile),
                  trailing: Icon(Icons.chevron_right),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // GST No.
                ListTile(
                  leading: Align(
                    widthFactor: 1,
                    child: Text(
                      'GST',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  title: Text(firm.gst),
                ),
              ],
            ),
          ),

          // Actions
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(width: 1, color: Colors.grey.shade300),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                // Actions row 1
                TableRow(
                  children: <Widget>[
                    // Collection
                    InkWell(
                      onTap: () => viewCollection(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.grid_on, color: Colors.indigo),
                            SizedBox(height: 4),
                            Text('Collection'),
                          ],
                        ),
                      ),
                    ),

                    // Posts
                    InkWell(
                      onTap: () => viewPosts(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.rss_feed, color: Colors.purple),
                            SizedBox(height: 4),
                            Text('Posts'),
                          ],
                        ),
                      ),
                    ),

                    // QR Code
                    InkWell(
                      onTap: () => showQrCode(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            CachedImage(
                              imageUrl: firm.qrImageUrl,
                              width: 25,
                              height: 25,
                            ),
                            SizedBox(height: 4),
                            Text('QR Code'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Actions row 2
                TableRow(
                  children: <Widget>[
                    // Follow
                    InkWell(
                      onTap: () {
                        firm.followId == null
                            ? parent.follow()
                            : parent.unfollow();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              firm.followId == null
                                  ? Icons.person_add
                                  : Icons.person,
                              color: Colors.teal,
                            ),
                            SizedBox(height: 4),
                            Text(firm.followId == null ? 'Follow' : 'Unfollow'),
                          ],
                        ),
                      ),
                    ),

                    // Message
                    InkWell(
                      onTap: messageFirm,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Image.asset('images/whatsapp.png', width: 24),
                            SizedBox(height: 4),
                            Text('Message'),
                          ],
                        ),
                      ),
                    ),

                    // Share
                    InkWell(
                      onTap: share,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.share, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Share'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contact details
          buildContactCard(),

          // Links
          buildLinksCard(),
        ],
      ),
    );
  }

  Widget buildContactCard() {
    List<Widget> widgets = [];

    // Email address
    if (firm.emailAddresses.length > 0) {
      widgets.addAll(firm.emailAddresses.map(
        (e) => ListTile(
          //onTap: sendMail,
          onTap: () {
            Clipboard.setData(ClipboardData(text: e));
            sendMail(e);
          },
          leading: Icon(Icons.mail),
          title: Text(e),
          subtitle: Text('Email address'),
        ),
      ));

      widgets.add(
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
      );
    }

    // Icom number
    if (firm.icomNumbers.length > 0) {
      widgets.addAll(firm.icomNumbers.map(
        (e) => ListTile(
          leading: Icon(Icons.phone_in_talk),
          title: Text(e),
          subtitle: Text('Intercom number'),
        ),
      ));

      widgets.add(
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
      );
    }

    // Landline number
    if (firm.landlineNumbers.length > 0) {
      widgets.addAll(firm.landlineNumbers.map(
        (e) => ListTile(
          leading: Icon(Icons.phone),
          title: Text(e),
          subtitle: Text('Landline number'),
        ),
      ));

      widgets.add(
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
      );
    }

    return Visibility(
      visible: widgets.length > 0,
      child: Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }

  Widget buildLinksCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Website
          Visibility(
            visible: firm.links != null  && firm.links['website'] != null,
            child: ListTile(
              leading: Icon(Icons.language),
              title: firm.links != null
                  ? Text(firm.links['website'] ?? 'NA')
                  : Text('NA'),
              subtitle: Text('Website'),
              trailing: Icon(Icons.chevron_right),
              onTap: firm.links != null && firm.links['website'] != null
                  ? () => openLink(firm.links['website'])
                  : null,
            ),
          ) ,

          Visibility(
            visible: firm.links != null  && firm.links['website'] != null,
            child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300)),

          // Facebook
          Visibility(
            visible: firm.links != null  && firm.links['facebook'] != null,
            child: ListTile(
              leading: Icon(Icons.language),
              title: firm.links != null
                  ? Text(firm.links['facebook'] ?? 'NA')
                  : Text('NA'),
              subtitle: Text('Facebook'),
              trailing: Icon(Icons.chevron_right),
              onTap: firm.links != null && firm.links['facebook'] != null
                  ? () => openLink(firm.links['facebook'])
                  : null,
            ),
          ),
          Visibility(
            visible: firm.links != null  && firm.links['facebook'] != null,
            child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300)),

          // Instagram
          Visibility(
            visible: firm.links != null  && firm.links['instagram'] != null,
            child: ListTile(
              leading: Icon(Icons.language),
              title: firm.links != null
                  ? Text(firm.links['instagram'] ?? 'NA')
                  : Text('NA'),
              subtitle: Text('Instagram'),
              trailing: Icon(Icons.chevron_right),
              onTap: firm.links != null && firm.links['instagram'] != null
                  ? () => openLink(firm.links['instagram'])
                  : null,
            ),
          ),
        ],
      ),
    );
  }

 
  openLink(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://' + url;
    }
    launch(url);
  }

  viewCollection(BuildContext context) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => ProductsPage(firm: firm),
    //   ),
    // );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductsCategorywisePage(firm: firm,),
      ),
    );
  }


  viewPosts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostsPage(firm: firm),
      ),
    );
  }

  showQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan in retailer app', textAlign: TextAlign.center),
        content: CachedNetworkImage(
          fit: BoxFit.contain,
          imageUrl: firm.qrImageUrl,
          errorWidget: (c, u, e) => Icon(Icons.warning),
          placeholder: (c, u) => Center(
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      ),
    );
  }

  messageFirm() {
    UserLogService.userLogById(firm.id.toString(), 'Wholesaler details message')
        .then((res) {
      print("userLogById Success");
    }).catchError((err) {
      print("userLogById Error:" + err.toString());
    });

    //launch("https://api.whatsapp.com/send?phone=91${firm.mobile}");
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    launch("https://api.whatsapp.com/send?phone=91${firm.mobile}&text=" +
        "Hi my firm name is\n\n $firmName from $city I got your number from Zaveri bazaar app. "
            "I am interested in your product range and would like to know more details.");
  }

  sendMail(String email){
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    launch("mailto:$email?subject=Zaveri Bazaar Buyer App User Query&body=Hi my firm name is\n\n $firmName from $city I got your number from Zaveri bazaar app. \n\nI am interested in your product range and would like to know more details.");
  }

  call() {
    UserLogService.userLogById(firm.id.toString(), 'Wholesaler details call')
        .then((res) {
      print("userLogById Success");
    }).catchError((err) {
      print("userLogById Error:" + err.toString());
    });
    launch("tel://${firm.mobile}");
  }

  share() {
    Share.share(
        'Follow ${firm.name} on Zaveri Bazaar, Click the link to view wholesaler profile: https://zaveribazaar.co.in/applink/wholesaler.php?i=${firm.id}');
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key key,
    @required this.tag,
    @required this.firm,
  }) : super(key: key);

  final String tag;
  final WholesalerFirm firm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 80,
        height: 80,
        child: firm.thumbUrl == null
            ? Image.asset(
                'images/placeholder.png',
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: firm.thumbUrl,
                fit: BoxFit.fitHeight,
                errorWidget: (c, u, e) => Icon(
                  Icons.warning,
                  color: Colors.white,
                ),
                placeholder: (c, u) => Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageView(imageUrl: firm.imageUrl),
          ),
        );
      },
    );
  }
}
