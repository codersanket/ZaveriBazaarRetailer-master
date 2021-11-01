import 'dart:math';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/pages/widgets/product_filters.dart' as PF;
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/product_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/user_tracking.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';

import 'package:url_launcher/url_launcher.dart';

class ProductsPage extends StatefulWidget {
  final WholesalerFirm firm;
  final String categoryId;
  final String categoryName;
  final bool focusSearch;
  final onlyBookmarked;
  final bool whatsNew;

  const ProductsPage({
    Key key,
    this.firm,
    this.categoryId,
    this.categoryName,
    this.focusSearch = false,
    this.onlyBookmarked = false,
    this.whatsNew = false,
  }) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> params = {'page': 1, 'per_page': 30, 'query': null};

  var isLoading = false, _error, totalPage = 0, rowCount = 0;
  List<Product> _products = [];

  List<Product> temp = [];
  // filters
  PF.Filter filter = PF.Filter();

  bool searchVisible = false;
  final searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  List<String> tags = [];
  FocusNode searchFocusNode;

  bool vWhatsappButton = false;
  bool vWeightClearButton = false;

  final weightFormKey = GlobalKey<FormState>();
  final searchController = TextEditingController();
  final weightFromController = TextEditingController();
  final weightToController = TextEditingController();

  //for carousel
  int _currentIndex = 0;
  User authUser;

  @override
  void initState() {
    super.initState();
    authUser = AuthService.user;
    searchFocusNode = new FocusNode();
    weightFromController.text = filter.weightRangeLower.toString();
    weightToController.text = filter.weightRangeUpper.toString();

    searchVisible = widget.focusSearch;
    if (widget.focusSearch) {
      searchFocusNode.requestFocus();
    } else {
      fetchProducts();
    }
    fetchAttributes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.sort_rounded),
        onPressed: showFilters,
      ),
      appBar: AppBar(
        title: Text(getTitle()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchVisible && params['query'] != null) {
                searchProducts(null);
              }
              //setState(() => searchVisible = !searchVisible);
              setState(() {
                searchVisible = !searchVisible;
                filter.searchkey = searchController.text.toString();
              });
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list),
          //   onPressed: showFilters,
          // ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search
          Visibility(
            visible: searchVisible,
            child: Card(
              margin: EdgeInsets.only(left: 8, right: 8, top: 8),
              elevation: 2,
              child: AutoCompleteTextField(
                key: searchKey,
                focusNode: searchFocusNode,
                controller: searchController,
                suggestions: tags,
                clearOnSubmit: false,
                itemBuilder: (BuildContext context, String suggestion) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(suggestion),
                      )
                    ],
                  );
                },
                itemSorter: (String a, String b) {
                  return a.compareTo(b);
                },
                itemFilter: (String suggestion, String query) {
                  return suggestion.toLowerCase().contains(query.toLowerCase());
                },
                itemSubmitted: searchProducts,
                textSubmitted: searchProducts,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //   Padding(
                //     padding: const EdgeInsets.all(5.0),
                //     child: Text(
                //       'Weight range',
                //     ),
                //   ),
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       // Container(
                //       //   height: 25,
                //       //   width: 60,
                //       //   child: FlatButton(
                //       //     padding: EdgeInsets.all(5),
                //       //     child: Text(
                //       //       'Apply',
                //       //       style: TextStyle(color: Colors.grey.shade700),
                //       //     ),
                //       //     color: Colors.grey.shade300,
                //       //     onPressed: () {
                //       //       setState(() {
                //       //         params['page'] = 1;
                //       //         fetchProducts();
                //       //       });
                //       //     },
                //       //   ),
                //       // ),
                //       // SizedBox(
                //       //   width: 10,
                //       // ),
                //       Container(
                //         height: 25,
                //         width: 60,
                //         child: FlatButton(
                //           padding: EdgeInsets.all(5),
                //           child: Text(
                //             'Clear',
                //             style: TextStyle(color: Colors.grey.shade700),
                //           ),
                //           color: Colors.grey.shade300,
                //           onPressed: () {
                //             setState(() {
                //               weightFromController.text =
                //                   filter.weightRange.lower.toString();
                //               weightToController.text =
                //                   filter.weightRange.upper.toString();
                //             });
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: _buildWeightForm(),
            ),
          ),
          //
          //CAROUSEL
          //temp.isEmpty ? Text("") : _buildCarousel(),

          //
          // Products grid
          Expanded(
            child: _error != null
                ? Center(child: Text(_error.toString()))
                : Stack(
                    children: <Widget>[
                      _buildGridView(),
                      Visibility(
                        visible: isLoading,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildGridView() {
    ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            fetchProducts();
          }
        }
      }
    });
    return GridView.builder(
      controller: _scrollController,
      itemCount: _products.length + 2,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        if (index == _products.length) {
          return buildWhatsappItem();
        } else if (index == _products.length + 1) {
          return buildWeightClearItem();
        } else {
          return _buildGridItem(context, index);
        }
      },
    );
  }

  getTitle() {
    if (widget.onlyBookmarked) {
      return 'My favourites';
    } else if (widget.firm != null) {
      return '${widget.firm.name} Products';
    } else if (widget.focusSearch) {
      return 'Search products';
    } else {
      return '${widget.categoryName}';
    }
  }

  Widget buildWhatsappItem() {
    return Visibility(
      visible: vWhatsappButton,
      child: Material(
        color: Colors.grey.shade300,
        child: GridTile(
          // Header
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Can\'t find what you are looking for ?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),

          // Body
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Share with us the product image & our team will find it for you!',
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Footer
          footer: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: OutlineButton(
              onPressed: whatsappSupport,
              child: Text('Whatsapp us'),
              textColor: Colors.green.shade600,
              highlightedBorderColor: Colors.green.shade600,
            ),
          ),
        ),
      ),
    );
  }

  buildWeightClearItem() {
    return Visibility(
      visible: vWeightClearButton,
      child: Material(
        color: Colors.grey.shade300,
        child: GridTile(
          // Body
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Browse more products from other weight options',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          footer: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: OutlineButton(
              onPressed: clearWeightFilter,
              child: Text('Load more'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final heroTag = 'product - ${_products[index].id}';
    final firm = _products[index].firm;

    return Card(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductViewPage(
                  products: _products,
                  index: index,
                  onChange: (product) {
                    setState(() => _products[index] = product);
                  },
                ),
              ));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Hero(
                  tag: heroTag,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: _products[index].thumbUrl,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      errorWidget: (c, u, e) => Image.asset(
                        "images/ic_launcher.png",
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                      //Icon(Icons.warning),
                      //placeholder: (c, u) => Center(
                      //    child: CircularProgressIndicator(strokeWidth: 2.0)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                //color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Divider(
                    //   color: Colors.black38,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "by ",
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Expanded(
                          child: Text(
                            firm.name.isNotEmpty ? "${firm.name}" : "-",
                            //style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          // "${_products[index].melting}".isNotEmpty
                          //     ? "Melting : ${_products[index].melting}"
                          //     : "-",
                          "Melting : " +
                              (_products[index].melting == null
                                  ? " - "
                                  : "${_products[index].melting}"),
                          style: TextStyle(fontSize: 11),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Text(
                          // "${_products[index].weightRange}".isNotEmpty
                          //     ? "Weight : " +
                          //             "${_products[index].weightRange}" ??
                          //         "-"
                          //     : "-",
                          "Weight : " +
                              (_products[index].weightRange == null
                                  ? " - "
                                  : "${_products[index].weightRange}"),
                          style: TextStyle(fontSize: 11),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          child: Icon(
                            _products[index].bookmarked
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.yellowAccent.shade400,
                          ),
                          onTap: () => bookmarkProduct(_products[index]),
                        ),
                        Text(
                          _products[index].createdAt.isNotEmpty
                              ? "${_products[index].createdAt.substring(0, 10)}"
                                  .split('-')
                                  .reversed
                                  .join('-')
                              : "-",
                          style: TextStyle(fontSize: 10),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // footer: Container(
      //   color: Colors.black.withOpacity(0.6),
      //   padding: EdgeInsets.all(8.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       Expanded(
      //         child: Padding(
      //           padding: const EdgeInsets.only(right: 8.0),
      //           child: Text(
      //             firm?.name ?? "-",
      //             style: TextStyle(color: Colors.white),
      //             overflow: TextOverflow.fade,
      //             maxLines: 1,
      //             softWrap: false,
      //           ),
      //         ),
      //       ),
      //       GestureDetector(
      //         child: Icon(
      //           _products[index].bookmarked ? Icons.star : Icons.star_border,
      //           color: Colors.yellowAccent.shade400,
      //         ),
      //         onTap: () => bookmarkProduct(_products[index]),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  void bookmarkProduct(Product product) {
    setState(() {
      product.bookmarked = !product.bookmarked;
    });

    ProductService.toggleBookmark(product.id, !product.bookmarked)
        .then((value) {})
        .catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
      setState(() {
        product.bookmarked = !product.bookmarked;
      });
    });
  }

  void whatsappSupport() {
    final mobile = AuthService.user.preference.productWhatsapp;
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;
    launch("https://api.whatsapp.com/send?phone=919321463461&text=" +
        "Hi I am a Zaveri bazaar buyer app user my name is $firmName from $city"
            " I am searching for some product can you please help me.");
    UserLogService.userLogById(
            '000', "Products page can't find item whatsapp button")
        .then((res) {
      print("userLogById Success");
    }).catchError((err) {
      print("userLogById Error:" + err.toString());
    });
  }

  void clearWeightFilter() {
    filter.weightRangeLower = filter.weightRange.lower;
    filter.weightRangeUpper = filter.weightRange.upper;
    params['page'] = 1;
    fetchProducts();
  }

  void showFilters() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      //isScrollControlled: true,
      builder: (_) => PF.ProductFilters(filter, context,searchController.text,),
    );
    if (result == 'filter') {
      params['page'] = 1;
      fetchProducts();
    }
  }

  searchProducts(String keyword) {
    params['query'] = keyword;
    params['page'] = 1;
    print('Search KeyWord:-$keyword');
    //Tracking.getSearch(keyword.toString());
    fetchProducts();
  }

  fetchProducts() {
    setState(() {
      isLoading = true;
      if (params['page'] == 1) {
        _products.clear();
        rowCount = 0;
      }

      vWhatsappButton = false;
      vWeightClearButton = false;
    });
    updateParams();
    ProductService.getAll(params).then((res) {
      List<Product> products = Product.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          if (params['page'] == 1) _products.clear();

          if (widget.firm == null) {
            products.shuffle();
          }
          //products.shuffle();
          //
          //FOR TESTING THE CAROUSEL
          //
          //temp = products.sublist(1, 5);
          _products.addAll(products);
          _error = null;
          isLoading = false;
          print("load $isLoading");
          Tracking.track1(
              searchController.text,
              widget.categoryId,
              weightFromController.text.toString(),
              weightToController.text.toString(),
              products.length.toString());
          Tracking.getResult(products.length.toString());
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _error = err;
          print("error give:-$_error");
          isLoading = false;
        });
    }).whenComplete(() {
      if (params['page'] >= totalPage) {
        vWhatsappButton = true;
      }

      if (params['page'] >= totalPage &&
          (params['weight_from'] != null || params['weight_to'] != null)) {
        vWeightClearButton = true;
      }
    });
  }

  updateParams() {
    if (widget.categoryId != null) params['category_id'] = widget.categoryId;
    if (filter.categoryId != null) params['category_id'] = filter.categoryId;

    params['whats_new'] = widget.whatsNew ? '1' : null;

    if (widget.onlyBookmarked) {
      params['bookmarked'] = widget.onlyBookmarked ? '1' : null;
    }
    // params['bookmarked'] = widget.onlyBookmarked ? '1' : null;

    params['subcategory_id'] =
        filter.subcategories.where((c) => c.checked).map((c) => c.id).join(",");
    params['city_id'] =
        filter.cities.where((c) => c.checked).map((c) => c.id).join(",");
    params['type_id'] =
        filter.types.where((c) => c.checked).map((c) => c.id).join(",");

    params['weight_from'] = filter.weightRangeLower > 0 &&
            filter.weightRangeLower != filter.weightRange.lower
        ? filter.weightRangeLower.toInt()
        : null;

    params['weight_to'] = filter.weightRangeUpper > 0 &&
            filter.weightRangeUpper != filter.weightRange.upper
        ? filter.weightRangeUpper.toInt()
        : null;

    if (widget.firm != null) params['wholesaler_firm_id'] = widget.firm.id;
  }

  fetchAttributes() async {
    if (widget.categoryId == null) {
      try {
        filter.categories = await ProductService.getCategories();
      } catch (ignored) {}
    }

    if (widget.categoryId != null) {
      try {
        filter.subcategories =
            await ProductService.getSubcategories(widget.categoryId);
      } catch (ignored) {}
    }

    try {
      filter.cities = await ProductService.getCities(widget.categoryId);
    } catch (ignored) {}

    try {
      filter.types = await ProductService.getTypes();
    } catch (ignored) {}

    try {
      filter.weightRange = await ProductService.getWeightRange();
      filter.weightRangeLower = filter.weightRange.lower;
      filter.weightRangeUpper = filter.weightRange.upper;
    } catch (ignored) {}

    try {
      tags.clear();
      tags.addAll(
          await ProductService.getTags(widget.categoryId ?? filter.categoryId));
    } catch (ignored) {}

    setState(() {});
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  //Weight range filter
  Widget _buildWeightForm() {
    return Card(
      child: Form(
          key: weightFormKey,
          child: Table(
            children: [
              TableRow(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 4.0, top: 4.0),
                  //   child: Column(
                  //     children: [Text("Weight"), Text("Range")],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                    child: TextFormField(
                      style: TextStyle(fontSize: 12),
                      controller: weightFromController,
                      cursorColor: Theme.of(context).primaryColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 12),
                        labelStyle: TextStyle(fontSize: 12),
                        labelText: 'Min',
                        //'Weight From',
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      style: TextStyle(fontSize: 12),
                      controller: weightToController,
                      cursorColor: Theme.of(context).primaryColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 12),
                        labelStyle: TextStyle(fontSize: 12),
                        labelText: 'Max',
                        //'Weight To',
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: TextButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                        //foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey.shade300),
                      ),
                      onPressed: () {
                        setState(() {
                          double from =
                              double.tryParse(weightFromController.text);
                          double to = double.tryParse(weightToController.text);

                          if (from > to) {
                            var temp = from;
                            from = to;
                            to = temp;
                          }
                          filter.weightRangeLower =
                              from ?? filter.weightRange.lower;

                          filter.weightRangeUpper =
                              to ?? filter.weightRange.upper;
                          params['page'] = 1;
                          print('Min value:-' +
                              weightFromController.text.toString());
                          print('Max value:-' +
                              weightToController.text.toString());
                          //Tracking.getWeight(from.toString(), to.toString());
                          fetchProducts();
                        });
                      },
                      child: Text(
                        'Apply',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  //   child: TextButton(
                  //     style: ButtonStyle(
                  //       shape:
                  //           MaterialStateProperty.all<RoundedRectangleBorder>(
                  //               RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10.0),
                  //       )),
                  //       //foregroundColor: MaterialStateProperty.all(Colors.white),
                  //       backgroundColor:
                  //           MaterialStateProperty.all(Colors.grey.shade300),
                  //     ),
                  //     onPressed: () {
                  //       setState(() {
                  //         weightFromController.text =
                  //             filter.weightRange.lower.toString();
                  //         weightToController.text =
                  //             filter.weightRange.upper.toString();
                  //       });
                  //     },
                  //     child: Text(
                  //       'Clear',
                  //       style: TextStyle(
                  //           color: Colors.grey.shade700, fontSize: 12),
                  //     ),
                  //   ),
                  // )
                ],
              )
            ],
          )),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            height: 400,
            // enlargeCenterPage: true,
            //scrollDirection: Axis.vertical,
            onPageChanged: (index, reason) {
              setState(
                () {
                  _currentIndex = index;
                },
              );
            },
          ),
          items: temp
              .map((item) => Card(
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (_) => ProductViewPage(
                        //         products: _products,
                        //         index: index,
                        //         onChange: (product) {
                        //           setState(() => _products[index] = product);
                        //         },
                        //       ),
                        //     ));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.topCenter,
                                  errorWidget: (c, u, e) => Image.asset(
                                    "images/ic_launcher.png",
                                    fit: BoxFit.contain,
                                    alignment: Alignment.topCenter,
                                  ),
                                  //Icon(Icons.warning),
                                  //placeholder: (c, u) => Center(
                                  //    child: CircularProgressIndicator(strokeWidth: 2.0)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              //color: Colors.black.withOpacity(0.6),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  // Divider(
                                  //   color: Colors.black38,
                                  // ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "by ",
                                        style: TextStyle(fontSize: 12),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.firm.name.isNotEmpty
                                              ? "${item.firm.name}"
                                              : "-",
                                          //style: TextStyle(color: Colors.white),
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.black38,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        // "${_products[index].melting}".isNotEmpty
                                        //     ? "Melting : ${_products[index].melting}"
                                        //     : "-",
                                        "Melting : " +
                                            (item.melting == null
                                                ? " - "
                                                : "${item.melting}"),
                                        style: TextStyle(fontSize: 11),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      Text(
                                        // "${_products[index].weightRange}".isNotEmpty
                                        //     ? "Weight : " +
                                        //             "${_products[index].weightRange}" ??
                                        //         "-"
                                        //     : "-",
                                        "Weight : " +
                                            (item.weightRange == null
                                                ? " - "
                                                : "${item.weightRange}"),
                                        style: TextStyle(fontSize: 11),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.black38,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Icon(
                                          item.bookmarked
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellowAccent.shade400,
                                        ),
                                        onTap: () => bookmarkProduct(item),
                                      ),
                                      Text(
                                        item.createdAt.isNotEmpty
                                            ? "${item.createdAt.substring(0, 10)}"
                                                .split('-')
                                                .reversed
                                                .join('-')
                                            : "-",
                                        style: TextStyle(fontSize: 10),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: temp.map((urlOfItem) {
            int index = temp.indexOf(urlOfItem);
            return Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.8)
                    : Color.fromRGBO(0, 0, 0, 0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
