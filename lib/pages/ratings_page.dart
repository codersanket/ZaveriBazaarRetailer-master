import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/services/date.service.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class RatingsPage extends StatefulWidget {
  final String mobile;
  final Function(String id) onRatingDelete;

  const RatingsPage({Key key, this.mobile, this.onRatingDelete})
      : super(key: key);

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, error, totalPage = 0, rowCount = 0;
  List<WholesalerRating> ratings = [];

  @override
  void initState() {
    super.initState();

    fetchRatings();

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            fetchRatings();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text('Wholesaler ratings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: buildListView(),
        ),
      ),
    );
  }

  Widget buildListView() {
    if (isLoading)
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.0),
        heightFactor: 2,
      );

    if (error != null)
      return Center(
        child: Text(error.toString()),
        heightFactor: 4,
      );

    return ListView.separated(
      shrinkWrap: ratings.length < 10,
      controller: scrollController,
      itemCount: ratings.length,
      separatorBuilder: (ctx, i) =>
          Divider(height: 1, color: Colors.grey.shade400),
      itemBuilder: buildListItem,
    );
  }

  Widget buildListItem(context, index) {
    final rating = ratings[index];
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image
            Hero(
              tag: 'rating${rating.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  image: rating.thumbUrl != null
                      ? CachedNetworkImageProvider(rating.thumbUrl)
                      : AssetImage('images/placeholder.png'),
                ),
              ),
            ),

            SizedBox(width: 16),

            //
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Rated by you
                  Visibility(
                    visible: rating.canModify,
                    child: Text(
                      'Rated by you',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: rating.canModify ? 4 : 0),

                  // Stars
                  RatingBarIndicator(
                    itemCount: 5,
                    rating: rating.rating.toDouble(),
                    itemSize: 18,
                    unratedColor: Colors.grey[350],
                    itemBuilder: (BuildContext context, int index) {
                      return Icon(Icons.star, color: Colors.amber);
                    },
                  ),

                  // Date
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      DateService.ddMMMyyyy(rating.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  // Recommended
                  Visibility(
                    visible: rating.recommended == 'yes',
                    child: Text(
                      'Recommended by retailer',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),

                  SizedBox(height: 4),

                  // Review
                  Text(
                    rating.review,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Delete rating
            Visibility(
              visible: rating.canModify,
              child: IconButton(
                icon: Icon(Icons.remove_circle_outline),
                tooltip: "Remove rating",
                onPressed: () async {
                  final result = await showConfirmationDialog();
                  if (result == 'yes') {
                    WholesalerRatingService.delete(rating.id).then((res) {
                      widget.onRatingDelete(rating.id);
                      setState(() => ratings.removeAt(index));
                    }).catchError((err) =>
                        ToastService.error(scaffoldKey, err.toString()));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> showConfirmationDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove rating'),
          content: Text(
            'Are you sure you want to remove wholesaler rating?',
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop('no'),
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop('yes'),
            ),
          ],
        );
      },
    );
  }

  fetchRatings() {
    setState(() {
      isLoading = true;
      if (params['page'] == 1) {
        ratings.clear();
        rowCount = 0;
      }
    });

    params['mobile'] = widget.mobile;

    WholesalerRatingService.getAll(params).then((res) {
      List<WholesalerRating> r = WholesalerRating.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          ratings.addAll(r);
          error = null;
          isLoading = false;
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          error = err;
          isLoading = false;
        });
    });
  }
}
