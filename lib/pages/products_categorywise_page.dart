import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/pages/products_page.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/pages/widgets/product_filters.dart' as PF;
import 'package:sonaar_retailer/services/Exception.dart';
import 'package:sonaar_retailer/services/product_service.dart';

class ProductsCategorywisePage extends StatefulWidget {
  final onlyBookmarked;
  final bool whatsNew;

  const ProductsCategorywisePage({
    Key key,
    this.onlyBookmarked = false,
    this.whatsNew = false,
  }) : super(key: key);

  @override
  _ProductsCategorywisePageState createState() =>
      _ProductsCategorywisePageState();
}

class _ProductsCategorywisePageState extends State<ProductsCategorywisePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  Map<String, dynamic> params = {'query': null};

  List<dynamic> _categories = [];
  List<Map<String, dynamic>> _newProducts;
  bool isEmpty = false;
  var isLoading = true, _error;

  // filters
  PF.Filter filter = PF.Filter();

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.onlyBookmarked ? 'My favourites' : 'Zaveri Bazaar',
          style: TextStyle(fontFamily: 'serif'),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      drawer: !widget.onlyBookmarked
          ? DrawerWidget(scaffoldKey: _scaffoldKey)
          : null,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Visibility(
                visible: !widget.whatsNew,
                child: buildSearch(),
              ),
              Visibility(
                visible: widget.whatsNew,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 8),
                      ImageIcon(AssetImage('images/new.png')),
                      SizedBox(width: 8),
                      Text(
                        'New arrivals in last 24 hours',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _error != null
                    ? Center(child: Text(_error.toString()))
                    : widget.whatsNew
                        ? isEmpty || isLoading
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'No new Products have been uploaded today, pls check again later',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                            : buildCarouselView()
                        : buildGridView(),
              ),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          ),
        ],
      ),
    );
  }

  Widget buildSearch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 40,
        child: RaisedButton.icon(
          icon: Icon(Icons.search, size: 16),
          label: Text('Search products'),
          elevation: 1,
          highlightElevation: 3,
          color: Colors.white,
          textColor: Theme.of(context).primaryColor.withOpacity(0.6),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductsPage(
                  focusSearch: true,
                  onlyBookmarked: widget.onlyBookmarked,
                  whatsNew: widget.whatsNew,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      itemCount: _categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: buildGridItem,
    );
  }

  Widget buildGridItem(BuildContext context, int catIndex) {
    final category = _categories[catIndex];
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            print('Main Category id:-' + category['id'].toString());
            UserException1.getFilterData();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductsPage(
                  categoryId: category['id'].toString(),
                  categoryName: category['name'].toString(),
                  onlyBookmarked: widget.onlyBookmarked,
                  whatsNew: widget.whatsNew,
                ),
              ),
            );
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: category['product_thumb_url'],
                  fit: BoxFit.cover,
                  // alignment: Alignment.topCenter,
                  errorWidget: (c, u, e) => Icon(Icons.warning),
                  placeholder: (c, u) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.7),
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                child: Text(
                  category['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCarouselView() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _newProducts.length,
      separatorBuilder: (ctx, i) => Divider(
        height: 5,
        thickness: 2,
        //color: Colors.blueGrey.shade100,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        return _buildCarouselItem(context, index);
      },
    );
  }

  Widget _buildCarouselItem(BuildContext context, int index) {
    return Card();
  }

  fetchProducts() {
    setState(() {
      isLoading = true;
    });

    params['bookmarked'] = widget.onlyBookmarked ? '1' : null;
    //params['whats_new'] = widget.whatsNew ? '1' : null;

    if (widget.whatsNew) {
      ProductService.getNewProducts().then((res) {
        if (mounted)
          setState(() {
            _newProducts = res["request"];
            _newProducts.isEmpty ? isEmpty = true : isEmpty = false;
            _error = null;
            isLoading = false;
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            _newProducts.clear();
            _error = err;
            isLoading = false;
          });
      });
    } else {
      ProductService.getSortedProducts(params, null).then((res) {
        if (mounted)
          setState(() {
            _categories = res;
            _error = null;
            isLoading = false;
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            _categories.clear();
            _error = err;
            isLoading = false;
          });
      });
    }
  }
}
