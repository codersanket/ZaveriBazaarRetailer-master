import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/pages/rating_wholesaler_view.dart';
import 'package:sonaar_retailer/pages/wholesaler_rating_add.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/pages/widgets/rating_filters.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WholesalerRatingsPage extends StatefulWidget {
  @override
  _WholesalerRatingsPageState createState() => _WholesalerRatingsPageState();
}

class _WholesalerRatingsPageState extends State<WholesalerRatingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, error, totalPage = 0, rowCount = 0;
  List<WholesalerRating> ratings = [];

  final searchCtrl = TextEditingController();
  final filter = RFilter();

  @override
  void initState() {
    super.initState();

    fetchRatings();
    fetchAttributes();

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
      appBar: AppBar(
        title: Text('Wholesaler ratings'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilters,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            buildSearchView(),
            SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: buildListView(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => WholesalerRatingAddPage()),
          );

          if (result != null) {
            params['page'] = 1;
            fetchRatings();
          }
        },
        tooltip: 'Rate wholesaler',
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget buildSearchView() {
    final textColor = Theme.of(context).primaryColor.withOpacity(0.6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.search, size: 18, color: textColor),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchCtrl,
                cursorColor: Theme.of(context).primaryColor,
                onSubmitted: searchWholesalers,
                decoration: InputDecoration(
                  hintText: 'Search wholesalers',
                  isDense: true,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: textColor),
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
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
      separatorBuilder: (ctx, i) => Divider(height: 1),
      itemBuilder: buildListItem,
    );
  }

  Widget buildListItem(context, index) {
    final rating = ratings[index];
    return Material(
      color: Colors.white,
      child: ListTile(
        dense: true,
        title: Text(
          rating.name,
          style: TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Hero(
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
        subtitle: RatingBarIndicator(
          itemCount: 5,
          rating: rating.rating.toDouble(),
          itemSize: 16,
          unratedColor: Colors.grey[350],
          itemBuilder: (BuildContext context, int index) {
            return Icon(Icons.star, color: Colors.amber);
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RatingWholesalerViewPage(
                ratingId: rating.id,
                heroTag: 'rating${rating.id}',
                onRatingDelete: (id) => setState(() {
                  ratings.removeWhere((el) => el.id == id);
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  void showFilters() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => RatingFilters(filter),
    );

    if (result == 'filter') {
      params['page'] = 1;
      fetchRatings();
    }
  }

  searchWholesalers(String text) {
    params['query'] = text;
    params['page'] = 1;
    fetchRatings();
  }

  fetchRatings() {
    setState(() {
      if (params['page'] == 1) {
        ratings.clear();
        rowCount = 0;
      }
      isLoading = true;
    });

    params['city_id'] =
        filter.cities.where((c) => c.checked).map((c) => c.id).join(",");

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

  fetchAttributes() async {
    try {
      filter.cities = await WholesalerRatingService.getCities();
    } catch (ignored) {}

    setState(() {});
  }
}
