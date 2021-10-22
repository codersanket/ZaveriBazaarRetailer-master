import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonaar_retailer/models/bullion_city.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';
import 'package:sonaar_retailer/models/post.dart';
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/product_view.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/bullion_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/post_service.dart';
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bullion_price_controller.dart';
import 'bullion_price_helper.dart';
import 'bullion_vendor_detail_page.dart';

// ignore: must_be_immutable
class BullionCityPage extends StatefulWidget {
  @override
  _BullionCityPageState createState() => _BullionCityPageState();
}

class _BullionCityPageState extends State<BullionCityPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoading = true, _error,_prodError,_postError;
  List<BullionCity> _cityList = [];
  BullionService bullionService;

  // selected city for dropdown
  BullionCity _selectedCity;
  String _selectedItem = "Gold & Silver";

  // vendor list
  List<BullionVendor> _vendorList = [];
  String userId;

  // bullion price controller
  BullionPriceController _bullionPriceController =
      Get.put(BullionPriceController());

  //for carousel
  int _currentProductIndex = 0;
  int _currentPostIndex = 0;
  User authUser;
  List<Product> productList = [];
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();
    bullionService = new BullionService(context);
    // get user id
    AuthService.getUser().then((res) {
      userId = res.id;
      // call api
      fetchCityList();
    }).catchError((err) {
      print(err);
    });

    fetchTopProducts();
    fetchTopPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Scaffold(
          appBar:AppBar(title :Text('Zaveri Bazaar', style: TextStyle(fontFamily: 'serif')),),
          key: _scaffoldKey,
          drawer: DrawerWidget(scaffoldKey: _scaffoldKey),
          body: _error != null
              ? Center(child: Text(_error.toString()))
              : Stack(
                  children: <Widget>[
                    _buildWidgetView(),
                    Visibility(
                      visible: isLoading,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildWidgetView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // top city and gold/silver drop down view
          Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 0.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // city drop down view
                  Flexible(
                    child: DropdownButtonFormField(
                      isDense: true,
                      value: _selectedCity,
                      isExpanded: true,
                      items: _cityList
                          .map((c) => DropdownMenuItem(
                                child: Text(c.name),
                                value: c,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCity = value);
                        // fetch vendor list
                        fetchVendorList();
                      },
                    ),
                  ),

                  // gold/silver drop down view
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      child: DropdownButtonFormField(
                        isDense: true,
                        value: _selectedItem,
                        isExpanded: true,
                        items: ["Gold", "Silver", "Gold & Silver"]
                            .map((label) => DropdownMenuItem(
                                  child: Text(label.toString()),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedItem = value);
                          // fetch vendor list
                          fetchVendorList();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // live price label
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
            child: Text(
              'Average Bill Price',
              style:
                  TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
            ),
          ),

          // average gold/silver card view
          Row(
            children: [
              Expanded(
                // live gold price card
                child: Card(
                  margin: const EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        // average gold price
                        Text(
                          'Gold',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                            BullionPriceHelper.getLivePrice(
                                _bullionPriceController.goldPrice.value,
                                _selectedCity != null ? _selectedCity.gold : 0),
                            style: TextStyle(
                              fontSize: 20.0,
                                color: _bullionPriceController.selectedColourGold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // average silver price widget
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        // average silver price
                        Text(
                          'Silver',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                            BullionPriceHelper.getLivePrice(
                                _bullionPriceController.silverPrice.value,
                                _selectedCity != null
                                    ? _selectedCity.silver
                                    : 0),
                            style: TextStyle(
                              fontSize: 20.0,
                                color: _bullionPriceController.selectedColourSilver
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // estimated price label
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
          //   child: Text(
          //     'Average Trader Price',
          //     style:
          //         TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
          //   ),
          // ),

          // estimated gold/silver card view
          // Row(
          //   children: [
          //     Expanded(
          //       // estimated gold price card
          //       child: Card(
          //         margin: const EdgeInsets.all(10.0),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         clipBehavior: Clip.antiAlias,
          //         child: Padding(
          //           padding: const EdgeInsets.all(10.0),
          //           child: Column(
          //             children: <Widget>[
          //               // gold price (live)
          //               Text(
          //                 'Gold',
          //                 style: TextStyle(
          //                   fontSize: 14.0,
          //                 ),
          //               ),
          //               Text(
          //                   BullionPriceHelper.getEstimatedPrice(
          //                       _bullionPriceController.goldPrice.value,
          //                       _selectedCity != null ? _selectedCity.gold : 0),
          //                   style: TextStyle(
          //                     fontSize: 20.0,
          //                       color: _bullionPriceController.selectedColourGold),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),

          //     // estimated silver price card
          //     Expanded(
          //       child: Card(
          //         margin: const EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         clipBehavior: Clip.antiAlias,
          //         child: Padding(
          //           padding: const EdgeInsets.all(10.0),
          //           child: Column(
          //             children: <Widget>[
          //               // gold price (live)
          //               Text(
          //                 'Silver',
          //                 style: TextStyle(
          //                   fontSize: 14.0,
          //                 ),
          //               ),
          //               Text(
          //                   BullionPriceHelper.getEstimatedPrice(
          //                       _bullionPriceController.silverPrice.value,
          //                       _selectedCity != null
          //                           ? _selectedCity.silver
          //                           : 0),
          //                   style: TextStyle(
          //                     fontSize: 20.0,
          //                       color: _bullionPriceController.selectedColourSilver
          //                   )),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          // Bullion Dealer label
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 0,
              ),
              child: Row(
                children: [
                  // Bullion Dealer title text
                  Expanded(
                    child: Text(
                      'Bullion Dealer',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).accentColor),
                    ),
                  ),

                  // gold title text
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      'Gold',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).accentColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // silver title text
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    margin: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      'Silver',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).accentColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bullion Dealer card
          Card(
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _vendorList.length,
              separatorBuilder: (ctx, i) => Divider(height: 1),
              itemBuilder: (context, index) {
                BullionVendor model = _vendorList[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BullionVendorDetailPage(model, getLivePriceModel()),
                      ),
                    ).then((value) {
                      //debugPrint(value);
                      _reloadPage();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                direction: Axis.horizontal,
                                children: [
                                  // dealer name and rating details
                                  Text(
                                    model.firm_name,
                                    style: TextStyle(
                                        fontSize: 11.0, color: Colors.black),
                                  ),
                                ],
                              ),

                              // mobile number
                              Wrap(
                                direction: Axis.horizontal,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: model.mobile != null
                                              ? model.mobile
                                              : 'NA',
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        TextSpan(
                                          text: " (",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: Colors.black),
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.star,
                                            color: Color(0xffdea321),
                                            size: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: model.avg_rating
                                                  .roundToDouble()
                                                  .toString() +
                                              ")",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // gold price
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          margin: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            model.is_gold_available == 1
                                ? BullionPriceHelper.getLivePrice(
                                    _bullionPriceController.goldPrice.value,
                                    model.gold_price_margin)
                                : '-',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: _bullionPriceController.selectedColourGold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // silver price
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          margin: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            model.is_silver_available == 1
                                ? BullionPriceHelper.getLivePrice(
                                    _bullionPriceController.silverPrice.value,
                                    model.silver_price_margin)
                                : '-',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: _bullionPriceController.selectedColourSilver
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
          // top products label 
          Visibility(
            visible: productList.isNotEmpty && _prodError==null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Text(
                'Top Products',
                style:
                    TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
              ),
            ),
          ),

          // top products carousel
          Visibility(
            visible: productList.isNotEmpty && _prodError==null,
            child: Card(
              color :Colors.grey.shade200,
              margin: EdgeInsets.all(10),
              child: _buildProductCarousel(),)),

           // top post label 
          Visibility(
            visible: postList.isNotEmpty && _postError==null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Text(
                'Top Posts',
                style:
                    TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
              ),
            ),
          ),

          // top products carousel
          Visibility(
            visible: postList.isNotEmpty && _postError==null,
            child: Card(
              color :Colors.grey.shade200,
              margin: EdgeInsets.all(10),
              child: _buildPostCarousel(),)),
        ],
      ),
    );
  }

//Product Carousel
Widget _buildProductCarousel() {
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
                  _currentProductIndex = index;
                },
              );
            },
          ),
          items: productList
              .map((item) => Card(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductViewPage(
                                products: productList,
                                index: _currentProductIndex,
                                onChange: (product) {
                                  setState(() => productList[_currentProductIndex] = product);
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
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
                                            style: TextStyle(color: Color(0xff004272),fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Divider(
                                  //   color: Colors.black38,
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: <Widget>[
                                  //     Text(
                                  //       // "${_products[index].melting}".isNotEmpty
                                  //       //     ? "Melting : ${_products[index].melting}"
                                  //       //     : "-",
                                  //       "Melting : " +
                                  //           (item.melting == null
                                  //               ? " - "
                                  //               : "${item.melting}"),
                                  //       style: TextStyle(fontSize: 11),
                                  //       overflow: TextOverflow.fade,
                                  //       maxLines: 1,
                                  //       softWrap: false,
                                  //     ),
                                  //     Text(
                                  //       // "${_products[index].weightRange}".isNotEmpty
                                  //       //     ? "Weight : " +
                                  //       //             "${_products[index].weightRange}" ??
                                  //       //         "-"
                                  //       //     : "-",
                                  //       "Weight : " +
                                  //           (item.weightRange == null
                                  //               ? " - "
                                  //               : "${item.weightRange}"),
                                  //       style: TextStyle(fontSize: 11),
                                  //       overflow: TextOverflow.fade,
                                  //       maxLines: 1,
                                  //       softWrap: false,
                                  //     ),
                                  //   ],
                                  // ),
                                  // Divider(
                                  //   color: Colors.black38,
                                  // ),
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
          children: productList.map((urlOfItem) {
            int index = productList.indexOf(urlOfItem);
            return Container(
              width: 5.0,
              height: 5.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentProductIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.8)
                    : Color.fromRGBO(0, 0, 0, 0.3),
              ),
            );
          }).toList(),
        )
      ],
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

  fetchTopProducts(){
    
    setState(() {
      isLoading = true;
      ProductService.getTopProducts().then((res) {
        List<Product> products = Product.listFromJson(res);
        if (mounted)
          setState(() {
            products.shuffle();
            productList.addAll(products);
            _prodError = null;
            isLoading = false;
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            _prodError = err;
            isLoading = false;
          });
      });
    });
  }


//post carousel

Widget _buildPostCarousel() {
  dynamic heroTag;
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
                  _currentPostIndex = index;
                  heroTag = 'post - ${postList[index].id}';
                },
              );
            },
          ),
          items: postList
              .map((post) => Card(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                constraints: BoxConstraints(maxHeight: 180.0),
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
                      UserLogService.userLogById(post.wholesalerFirmId, "Feed top 10")
                          .then((res) {
                        print("userLogById Success");
                      }).catchError((err) {
                        print("userLogById Error:" + err.toString());
                      });
                      // do whatsapp share process
                      whatsappWholesaler(post.firm.mobile,post.createdAt,post.image_share);
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
                          ? follow(firm: post.firm, index: _currentPostIndex)
                          : unfollow(firm: post.firm, index: _currentPostIndex);
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
    ))
      .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: productList.map((urlOfItem) {
            int index = productList.indexOf(urlOfItem);
            return Container(
              width: 5.0,
              height: 5.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentProductIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.8)
                    : Color.fromRGBO(0, 0, 0, 0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

fetchTopPosts(){
    
    setState(() {
      isLoading = true;
      PostService.getTopPosts().then((res) {
        List<Post> posts = Post.listFromJson(res);
        if (mounted)
          setState(() {
            posts.shuffle();
            postList.addAll(posts);
            _postError = null;
            isLoading = false;
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            _postError = err;
            isLoading = false;
          });
      });
    });
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
      setState(() => postList[index].firm.followId = res.id);
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
      setState(() => postList[index].firm.followId = null);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void whatsappWholesaler(String mobile,String createdAt,String image_share) {
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
    }catch(error){
      print("Launch Error:" + error.toString());
    }
  }


//bullion

  GetLivePrice getLivePriceModel() {
    return GetLivePrice(
        gold: _bullionPriceController.goldPrice.value,
        silver: _bullionPriceController.silverPrice.value);
  }

  void _reloadPage() {
    print("called _reloadPage");
    // fetch vendor list
    fetchVendorList();
  }

  // fetch bullion city data
  void fetchCityList() {
    setState(() => isLoading = true);

    bullionService.getBullionCityList().then((res) {
      BullionCity city;
      for (int i = 0; i < res.length; i++) {
        if (res[i].name.toLowerCase().contains("mumbai")) {
          city = res[i];
          break;
        }
      }
      if (mounted)
        setState(() {
          _cityList = res;
          _selectedCity = city;
          _error = null;
          isLoading = false;
          // fetch vendor list
          fetchVendorList();
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _error = err;
          isLoading = false;
        });
    });
  }

  void fetchVendorList() {
    if (_selectedCity == null) return;

    setState(() => isLoading = true);

    int isGoldVendor, isSilverVendor;
    if (_selectedItem == "Gold & Silver") {
      isGoldVendor = 1;
      isSilverVendor = 1;
    } else if (_selectedItem == "Gold") {
      isGoldVendor = 1;
      isSilverVendor = 0;
    } else {
      isGoldVendor = 0;
      isSilverVendor = 1;
    }

    bullionService
        .getVendorList(userId, _selectedCity.id, isGoldVendor, isSilverVendor)
        .then((res) {
      if (mounted)
        setState(() {
          _vendorList = res;
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
