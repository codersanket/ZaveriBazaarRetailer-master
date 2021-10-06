import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/retailer_rating.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/retailer_rating_service.dart';

class MyRatingsPage extends StatefulWidget {
  @override
  _MyRatingsPageState createState() => _MyRatingsPageState();
}

class _MyRatingsPageState extends State<MyRatingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, error, totalPage = 0, rowCount = 0;
  List<RetailerRating> wholesalers = [];

  @override
  void initState() {
    super.initState();

    _fetchWholesalers();

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchWholesalers();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text('My Ratings')),
      body: error != null
          ? Center(child: Text(error.toString()))
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

  Widget buildListView() {
    return ListView.separated(
      controller: scrollController,
      itemCount: wholesalers.length,
      separatorBuilder: (ctx, i) => Divider(height: 1),
      itemBuilder: (context, index) {
        final wholesaler = wholesalers[index];
        return Material(
          color: Colors.white,
          child: ListTile(
            leading: Image(
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              image: wholesaler.thumbUrl != null
                  ? CachedNetworkImageProvider(wholesaler.thumbUrl)
                  : AssetImage('images/placeholder.png'),
            ),
            title: Text(wholesaler.wholesalerFirm.name),
            subtitle: Text(
              wholesaler.review,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WholesalerViewPage(
                    wholesalerId: wholesaler.wholesalerFirmId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  _fetchWholesalers() {
    setState(() {
      isLoading = true;
      if (params['page'] == 1) {
        wholesalers.clear();
        rowCount = 0;
      }
    });

    RetailerRatingService.getAll(params).then((res) {
      List<RetailerRating> WholesalerRatings =
          RetailerRating.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          wholesalers.addAll(WholesalerRatings);
          error = null;
          isLoading = false;
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          error = 'No wholesalers found!';
          isLoading = false;
        });
    });
  }
}
