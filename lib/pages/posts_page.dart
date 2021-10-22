import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/post.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/products_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/post_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PostsPage extends StatefulWidget {
  final WholesalerFirm firm;
  final Function(int index) onTabChange;

  const PostsPage({Key key, this.firm, this.onTabChange}) : super(key: key);

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, _error, totalPage = 0, rowCount = 0;
  List<Post> _posts = [];

  User authUser;
  @override
  void initState() {
    super.initState();
    authUser = AuthService.user;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchPosts();
          }
        }
      }
    });

    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: widget.firm != null
            ? Text('${widget.firm.name} Posts')
            : Text('Zaveri Bazaar', style: TextStyle(fontFamily: 'serif')),
      ),
      drawer:
          widget.firm == null ? DrawerWidget(scaffoldKey: _scaffoldKey) : null,
      body: _error != null
          ? buildErrorWidget()
          : Stack(
              children: <Widget>[
                _buildListView(),
                Visibility(
                  visible: isLoading,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
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
          Text(_error.toString()),
          SizedBox(height: 16),
          Visibility(
            visible: widget.onTabChange != null,
            child: FlatButton(
              onPressed: () => widget.onTabChange(2),
              child: Text('Follow wholesalers'),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _posts.length,
      separatorBuilder: (ctx, i) => Divider(
        height: 5,
        thickness: 2,
        //color: Colors.blueGrey.shade100,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        // if (index == 0) {
        //   return ListTile(
        //     trailing: Icon(Icons.message),
        //     title: Text('Write new post'),
        //     onTap: () => _createPost(),
        //   );
        // } else {
        return _buildListItem(context, index);
        // }
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final heroTag = 'post - ${_posts[index].id}';
    final post = _posts[index];
    return Card(
      color: Colors.white,
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => PostViewPage(
            //         post: _posts[index],
            //         heroTag: heroTag,
            //         onChange: (post) {
            //           setState(() => _posts[index] = post);
            //         },
            //       ),
            //     ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WholesalerViewPage(
                        wholesalerId: post.wholesalerFirmId,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 16.0, left: 16.0, right: 16.0),
                child: Text(post.text),
              ),
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
              //SizedBox(height: 8),
              Divider(),
              // actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  //   child: FlatButton.icon(
                  //     label: Text('SHARE'),
                  //     icon: Icon(Icons.share),
                  //     textColor: Colors.blue.shade700,
                  //     padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //     onPressed: () => sharePost(post),
                  //   ),
                  // ),
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
                      UserLogService.userLogById(post.wholesalerFirmId, "Feed")
                          .then((res) {
                        print("userLogById Success");
                      }).catchError((err) {
                        print("userLogById Error:" + err.toString());
                      });
                      // do whatsapp share process
                      whatsappWholesaler(post.firm.mobile,post.createdAt,post.imageUrl);
                    },
                  ),
                  //COLLECTION
                  InkWell(
                    onTap: () {
                      viewCollection(
                          context: context, firmId: post.wholesalerFirmId);
                      // print(
                      //     "///////////////////////////////////////// FIRMMMMMMMM");
                      // print(post.firm.followId);
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
                      post.firm.followId == null
                          ? follow(firm: post.firm, index: index)
                          : unfollow(firm: post.firm, index: index);
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
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void sharePost(Post post) async {
    final text = (post.text ?? '') +
        "\n\nShared from Zaveri Bazaar app, Download now from https://zaveribazaar.co.in";

    if (post.imageUrl != null) {
      var request = await HttpClient().getUrl(Uri.parse(post.imageUrl));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);

      await Share.file(
        'Share post',
        'post.jpg',
        bytes,
        'image/jpg',
        text: text,
      );
    } else {
      Share.text('Share post', text, 'text/plain');
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

  void follow({WholesalerFirm firm, int index}) {
    setState(() => isLoading = true);
    FollowService.create(firmId: firm.id, mobile: firm.mobile).then((res) {
      ToastService.success(
        _scaffoldKey,
        'You are now following ${firm.name}!',
      );
      //setState(() => firm.followId = res.id);
      setState(() => _posts[index].firm.followId = res.id);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void unfollow({WholesalerFirm firm, int index}) {
    setState(() => isLoading = true);
    FollowService.delete(firm.followId).then((res) {
      ToastService.success(
        _scaffoldKey,
        'You are no longer following ${firm.name}!',
      );
      //setState(() => firm.followId = null);
      setState(() => _posts[index].firm.followId = null);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void whatsappWholesaler(String mobile,String createdAt,String imageUrl) {
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    try {
      final url = "https://api.whatsapp.com/send?phone=91$mobile&text=" +
          "$firmName\nfrom $city\n is interested in one of your products posted on $createdAt. "
              "To view image of the product please save this number and click on the below link\n $imageUrl";
      final encodeURL = Uri.encodeFull(url);

      print("final url to open:" + url);
      print("final url to open: encode url " + encodeURL);
      launch(encodeURL);
    }catch(error){
      print("Launch Error:" + error.toString());
    }
  }

  _fetchPosts() {
    setState(() => isLoading = true);

    if (widget.firm != null) params['wholesaler_firm_id'] = widget.firm.id;

    PostService.getAll(params).then((res) {
      List<Post> posts = Post.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          _posts.addAll(posts);
          //print(_posts[0]);
          _error = null;
          isLoading = false;
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _error = err;
          isLoading = false;
        });
    });
  }
}
