import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:sonaar_retailer/models/follow.dart';
import 'package:sonaar_retailer/pages/contacts_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/dialog_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class FollowsPage extends StatefulWidget {
  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, _error, totalPage = 0, rowCount = 0;
  List<Follow> _follows = [];

  @override
  void initState() {
    super.initState();

    _fetchFollows();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchFollows();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Zaveri Bazaar', style: TextStyle(fontFamily: 'serif')),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RaisedButton.icon(
              label: Text('Scan Wholesaler QR Code'),
              icon: Image.asset(
                'images/qr_code.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
              onPressed: _scanQrCode,
            ),
          ),
          Expanded(
            child: _error != null
                ? Center(child: Text(_error.toString()))
                : Stack(
                    children: <Widget>[
                      _buildListView(),
                      Visibility(
                        visible: isLoading,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactsPage(() {
                params['page'] = 0;
                _fetchFollows();
              }),
            ),
          );
        },
        tooltip: 'Search from contacts',
        child: Icon(Icons.contacts),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _follows.length,
      separatorBuilder: (ctx, i) => Divider(height: 0),
      itemBuilder: (context, index) {
        final heroTag = 'follow - ${_follows[index].id}';
        final followed = _follows[index].followed;
        return Material(
          color: Colors.white,
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WholesalerViewPage(
                    wholesalerId: _follows[index].followedId,
                  ),
                ),
              );
            },
            leading: Hero(
              tag: heroTag,
              child: Container(
                width: 40.0,
                height: 40.0,
                child: followed.thumbUrl == null
                    ? Image.asset('images/placeholder.png', fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: followed.thumbUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorWidget: (c, u, e) => Icon(Icons.warning),
                        placeholder: (c, u) => Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                      ),
              ),
            ),
            title: Text(followed.name),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline),
              tooltip: 'Unfollow',
              onPressed: () => _unfollow(index),
            ),
          ),
        );
      },
    );
  }

  _scanQrCode() async {
    final txt = await new QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(false) // default false
        .setTorchEnabled(false) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();

    if (txt != null) {
      final data = json.decode(txt);
      if (data != null && data['id'] != null) {
        final id = data['id'].toString();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WholesalerViewPage(wholesalerId: id),
          ),
        );
      }
    }
  }

  void _unfollow(int index) async {
    final ans = await DialogService.confirm(
      context,
      'Unfollow wholesaler',
      'Are you sure you want to unfollow this wholesaler ?',
    );

    if (ans != 'yes') return;

    FollowService.delete(_follows[index].id).then((res) {
      ToastService.success(
          _scaffoldKey, 'Wholesaler unfollow successful!', true);
      setState(() {
        _follows.removeAt(index);
        if (_follows.length == 0) _error = "No follows found!";
      });
    }).catchError(
        (err) => ToastService.error(_scaffoldKey, err.toString(), true));
  }

  _fetchFollows() {
    setState(() {
      isLoading = true;
      if (params['page'] == 0) {
        rowCount = 0;
        _follows.clear();
      }
    });

    FollowService.getAll(params).then((res) {
      List<Follow> follows = Follow.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          _follows.addAll(follows);
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
