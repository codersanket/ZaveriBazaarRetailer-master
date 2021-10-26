//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/pages/product_view.dart';
import 'package:sonaar_retailer/pages/products_page.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/pages/widgets/product_filters.dart' as PF;
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:sonaar_retailer/services/user_tracking.dart';

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
  List<dynamic> _newProducts;
  int _currentProductIndex = 0;

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
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    'No new products have been uploaded today.\nPlease check again later',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
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
        //crossAxisSpacing: 2,
        //mainAxisSpacing: 2,
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
            print('Main Category id:-' +
                category['id'].toString() +
                '\nCategory Name:-' +
                category['name'].toString());
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
    //final productList = _newProducts[index]["Product"];
    List<Product> productList = Product.listFromJson(_newProducts[index]["Product"]);
    final firmName = _newProducts[index]["name"];
    return Card(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.all(4), child: Text(firmName)),
        //   CarouselSlider(
        //   options: CarouselOptions(
        //     autoPlay: true,
        //     viewportFraction: 0.6,
        //     height: 250,
        //     //aspectRatio: 3,
        //     //enlargeCenterPage: true,
        //     //scrollDirection: Axis.vertical,
        //     onPageChanged: (index, reason) {
        //       setState(
        //         () {
        //           _currentProductIndex = index;
        //         },
        //       );
        //     },
        //   ),
        //   items: productList
        //       .map((item) => Card(
        //             child: GestureDetector(
        //               onTap: () {
        //                 Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (_) => ProductViewPage(
        //                         products: productList,
        //                         index: _currentProductIndex,
        //                         onChange: (product) {
        //                           setState(() => productList[_currentProductIndex] = product);
        //                         },
        //                       ),
        //                     ));
        //               },
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.start,
        //                 children: [
        //                   Expanded(
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(top : 8.0),
        //                       child: Container(
        //                         //height: 150,
        //                         //width: 150,
        //                         color: Colors.white,
        //                         child: Center(
        //                           child: CachedNetworkImage(
        //                             imageUrl: item.imageUrl,
        //                             fit: BoxFit.cover,
        //                             alignment: Alignment.topCenter,
        //                             errorWidget: (c, u, e) => Image.asset(
        //                               "images/ic_launcher.png",
        //                               fit: BoxFit.contain,
        //                               alignment: Alignment.topCenter,
        //                             ),
        //                             //Icon(Icons.warning),
        //                             placeholder: (c, u) => Center(
        //                                 child: CircularProgressIndicator(strokeWidth: 2.0)),
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                   Padding(
        //                     padding:
        //                         const EdgeInsets.symmetric(horizontal: 4.0),
        //                     child: Container(
        //                       //color: Colors.black.withOpacity(0.6),
        //                       padding: EdgeInsets.all(8.0),
        //                       child: Padding(
        //                         padding: const EdgeInsets.all(8.0),
        //                         child: Row(
        //                           mainAxisAlignment: MainAxisAlignment.start,
        //                           children: <Widget>[
        //                             Text(
        //                               "by ",
        //                               style: TextStyle(fontSize: 10),
        //                               overflow: TextOverflow.fade,
        //                               maxLines: 1,
        //                               softWrap: false,
        //                             ),
        //                             Expanded(
        //                               child: Text(
        //                                 item.firm.name.isNotEmpty
        //                                     ? "${item.firm.name}"
        //                                     : "-",
        //                                 style: TextStyle(color: Color(0xff004272),fontWeight: FontWeight.bold,fontSize: 12),
        //                                 overflow: TextOverflow.fade,
        //                                 maxLines: 1,
        //                                 softWrap: false,
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ))
        //       .toList(),
        // ),
        ],
      ),
    );
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
            //List<Product> _newProducts = Product.listFromJson(res["request"]);
            if (_newProducts != null) {
              _newProducts.isEmpty ? isEmpty = true : isEmpty = false;
            }
            _error = null;
            isLoading = false;
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            if (_newProducts != null) {
              _newProducts.clear();
            }
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
