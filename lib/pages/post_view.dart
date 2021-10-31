import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/post.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'image_view.dart';

class PostViewPage extends StatefulWidget {
  final List<Post> posts;
  final int index;
  final Function(Post post) onChange;

  PostViewPage({
    Key key,
    @required this.posts,
    @required this.index,
    this.onChange,
  }) : super(key: key);

  @override
  _PostViewPageState createState() => _PostViewPageState(posts);
}

class _PostViewPageState extends State<PostViewPage> {
  final List<Post> posts;
  _PostViewPageState(this.posts);
  PageController pageController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoading = true;
  User authUser;
  @override
  void initState() {
    super.initState();
    authUser = AuthService.user;
    pageController = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Post details')),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {},
        children: posts.map((post) {
          final heroTag = 'post - ${post.id}';
          return Padding(
            padding: const EdgeInsets.only(top: 10,bottom: 10,left: 3,right: 3),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ListTile(
                      leading: Container(
                        width: 40.0,
                        height: 40.0,
                        child: post.firm.thumbUrl == null
                            ? Image.asset('images/placeholder.png')
                            : CachedNetworkImage(
                                imageUrl: post.firm.thumbUrl,
                                fit: BoxFit.contain,
                              ),
                      ),
                      title: Text(post.firm.name ?? ''),
                      subtitle: Text(post.createdAt),
                      onTap: () {
                        AuthService.getUser().then(
                          (res) {
                            if (res.approved == 1) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => WholesalerViewPage(
                                  wholesalerId: post.wholesalerFirmId,
                                ),
                              ));
                            } else {
                              showInfoDialog(context, 'Info',
                                  'Your account is not approved, please contact us on below number\n\n7208226814');
                            }
                          },
                        );
                      }),
                  
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300.0),
                    child: post.thumbUrl == null
                        ? null
                        : GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageView(
                                    imageUrl: post.imageUrl,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: post.thumbUrl,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorWidget: (c, u, e) => Image.asset(
                                "images/ic_launcher.png",
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                              ),
                              // Icon(Icons.warning),
                              // placeholder: (c, u) => Center(
                              //     child:
                              //         CircularProgressIndicator(strokeWidth: 2.0)),
                            ),
                          ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 16.0, left: 16.0, right: 16.0),
                    child: Text(post.text),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      //MESSAGE
                      FlatButton.icon(
                        label: Text('Message'),
                        icon: Image.asset(
                          'images/whatsapp.png',
                          width: 24,
                          height: 24,
                        ),
                        textColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        onPressed: () {
                          AuthService.getUser().then((res) {
                            if (res.approved == 1) {
                              // do whatsapp share process
                              whatsappWholesaler(post.firm.mobile,
                                  post.createdAt, post.image_share);
                            } else {
                              showInfoDialog(context, 'Info',
                                  'Your account is not approved, please contact us on below number\n\n7208226814');
                            }
                          });
                        },
                      ),
                      //COLLECTION
                      InkWell(
                        onTap: () {
                          AuthService.getUser().then((res) {
                            if (res.approved == 1) {
                              viewCollection(
                                  context: context,
                                  firmId: post.wholesalerFirmId);
                            } else {
                              showInfoDialog(context, 'Info',
                                  'Your account is not approved, please contact us on below number\n\n7208226814');
                            }
                          });
                          
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.grid_on, color: Colors.indigo),
                              SizedBox(width: 4),
                              Text('Collection'),
                            ],
                          ),
                        ),
                      ),
                      //FOLLOW
                      InkWell(
                        onTap: () {
                          AuthService.getUser().then((res) {
                            if (res.approved == 1) {
                              post.firm.followId == null
                                  ? follow(firm: post.firm)
                                  : unfollow(
                                      firm: post.firm);
                            }else{
                              showInfoDialog(context, 'Info',
                                  'Your account is not approved, please contact us on below number\n\n7208226814');
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                post.firm.followId == null
                                    ? Icons.person_add
                                    : Icons.person,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 4),
                              Text(post.firm.followId == null
                                  ? 'Follow'
                                  : 'Unfollow'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void whatsappWholesaler(String mobile, String createdAt, String image_share) {
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    try {
      final url = "https://api.whatsapp.com/send?phone=91$mobile&text=" +
          "$firmName\nfrom $city\n is interested in one of your products posted on $createdAt. "
              "To view image of the product please save this number and click on the below link\n $image_share";
      final encodeURL = Uri.encodeFull(url);

      print("final url to open:" + url);
      print("final url to open: encode url " + encodeURL);
      launch(encodeURL);
    } catch (error) {
      print("Launch Error:" + error.toString());
    }
  }

  viewCollection({BuildContext context, String firmId}) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => ProductsPage(firm: firm),
    //   ),
    // );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WholesalerViewPage(
          wholesalerId: firmId,
        ),
      ),
    );
  }
  // void follow({WholesalerFirm firm, int index})
  void follow({WholesalerFirm firm}) {
    setState(() => isLoading = true);
    FollowService.create(firmId: firm.id, mobile: firm.mobile).then((res) {
      ToastService.success(
        _scaffoldKey,
        'You are now following ${firm.name}!',
      );
      setState(() => firm.followId = res.id);
     // setState(() => posts[index].firm.followId = res.id);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void unfollow({WholesalerFirm firm}) {
    setState(() => isLoading = true);
    FollowService.delete(firm.followId).then((res) {
      ToastService.success(
        _scaffoldKey,
        'You are no longer following ${firm.name}!',
      );
      setState(() => firm.followId = null);
     // setState(() => posts[index].firm.followId = null);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
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

  call() {
    launch("tel://917208226814");
  }

  void whatsappRetailer() {
    launch("https://api.whatsapp.com/send?phone=917208226814");
  }
}
