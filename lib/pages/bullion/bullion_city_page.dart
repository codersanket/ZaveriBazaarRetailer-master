import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sonaar_retailer/models/bullion_city.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';
import 'package:sonaar_retailer/models/post.dart';
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/models/youtube_video.dart';
import 'package:sonaar_retailer/pages/Repair_page.dart';
import 'package:sonaar_retailer/pages/Repair_add.dart';
import 'package:sonaar_retailer/pages/Requirement_create.dart';
import 'package:sonaar_retailer/pages/VideoScreen.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/orders_add.dart';
import 'package:sonaar_retailer/pages/post_view.dart';
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

import '../Requirement_view.dart';
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
  var isLoading = true, _error, _prodError, _postError,_videoError;
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
  int _currentVideoIndex = 0;
  User authUser;
  List<Product> productList = [];
  List<Post> postList = [];
  List<YoutubeVideo> videoList = [];
  //date
  String arrivalText, departureText;
  DateTime arrival, departure;
  TextEditingController _itemDateController1 = TextEditingController();
  TextEditingController _itemDateController2 = TextEditingController();

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
    fetchVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Zaveri Bazaar', style: TextStyle(fontFamily: 'serif')),
          ),
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
                              color:
                                  _bullionPriceController.selectedColourGold),
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
                                color: _bullionPriceController
                                    .selectedColourSilver)),
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
                    child: ExpansionTile(
                      title:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bullion Dealer',
                            style: TextStyle(
                                fontSize: 16, color: Theme.of(context).accentColor),
                          ),
                          //gold title text
                          Container(
                           // width: MediaQuery.of(context).size.width * 0.20,
                            child: Text(
                              'Gold',
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).accentColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // silver title text
                          Container(
                            //width: MediaQuery.of(context).size.width * 0.20,
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
                      children: [
                        _buildBuliondealer()
                        // Text(
                        //   'Bullion Dealer',
                        //   style: TextStyle(
                        //       fontSize: 16, color: Theme.of(context).accentColor),
                        // ),
                      ],
                    ),
                  ),

                  // gold title text
                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.25,
                  //   child: Text(
                  //     'Gold',
                  //     style: TextStyle(
                  //         fontSize: 16, color: Theme.of(context).accentColor),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),

                  // silver title text
                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.25,
                  //   margin: const EdgeInsets.only(left: 5.0),
                  //   child: Text(
                  //     'Silver',
                  //     style: TextStyle(
                  //         fontSize: 16, color: Theme.of(context).accentColor),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Bullion Dealer card
          // Card(
          //   margin: const EdgeInsets.all(10.0),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   clipBehavior: Clip.antiAlias,
          //   child: ListView.separated(
          //     shrinkWrap: true,
          //     physics: NeverScrollableScrollPhysics(),
          //     itemCount: _vendorList.length,
          //     separatorBuilder: (ctx, i) => Divider(height: 1),
          //     itemBuilder: (context, index) {
          //       BullionVendor model = _vendorList[index];
          //       return GestureDetector(
          //         behavior: HitTestBehavior.opaque,
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) =>
          //                   BullionVendorDetailPage(model, getLivePriceModel()),
          //             ),
          //           ).then((value) {
          //             //debugPrint(value);
          //             _reloadPage();
          //           });
          //         },
          //         child: Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.max,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Expanded(
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Wrap(
          //                       direction: Axis.horizontal,
          //                       children: [
          //                         // dealer name and rating details
          //                         Text(
          //                           model.firm_name,
          //                           style: TextStyle(
          //                               fontSize: 11.0, color: Colors.black),
          //                         ),
          //                       ],
          //                     ),
          //
          //                     // mobile number
          //                     Wrap(
          //                       direction: Axis.horizontal,
          //                       children: [
          //                         RichText(
          //                           text: TextSpan(
          //                             children: [
          //                               TextSpan(
          //                                 text: model.mobile != null
          //                                     ? model.mobile
          //                                     : 'NA',
          //                                 style: TextStyle(
          //                                     fontSize: 11.0,
          //                                     color: Theme.of(context)
          //                                         .primaryColor),
          //                               ),
          //                               TextSpan(
          //                                 text: " (",
          //                                 style: TextStyle(
          //                                     fontSize: 11.0,
          //                                     color: Colors.black),
          //                               ),
          //                               WidgetSpan(
          //                                 alignment:
          //                                     PlaceholderAlignment.middle,
          //                                 child: Icon(
          //                                   Icons.star,
          //                                   color: Color(0xffdea321),
          //                                   size: 16,
          //                                 ),
          //                               ),
          //                               TextSpan(
          //                                 text: model.avg_rating
          //                                         .roundToDouble()
          //                                         .toString() +
          //                                     ")",
          //                                 style: TextStyle(
          //                                     fontSize: 11.0,
          //                                     color: Colors.black),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //
          //               // gold price
          //               Container(
          //                 width: MediaQuery.of(context).size.width * 0.25,
          //                 margin: const EdgeInsets.only(left: 5.0),
          //                 child: Text(
          //                   model.is_gold_available == 1
          //                       ? BullionPriceHelper.getLivePrice(
          //                           _bullionPriceController.goldPrice.value,
          //                           model.gold_price_margin)
          //                       : '-',
          //                   style: TextStyle(
          //                       fontSize: 18.0,
          //                       color:
          //                           _bullionPriceController.selectedColourGold),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ),
          //
          //               // silver price
          //               Container(
          //                 width: MediaQuery.of(context).size.width * 0.25,
          //                 margin: const EdgeInsets.only(left: 5.0),
          //                 child: Text(
          //                   model.is_silver_available == 1
          //                       ? BullionPriceHelper.getLivePrice(
          //                           _bullionPriceController.silverPrice.value,
          //                           model.silver_price_margin)
          //                       : '-',
          //                   style: TextStyle(
          //                       fontSize: 18.0,
          //                       color: _bullionPriceController
          //                           .selectedColourSilver),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),

          // top products label
          // Visibility(
          //   visible: productList.isNotEmpty && _prodError==null,
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          //     child: Text(
          //       'Top Products',
          //       style:
          //           TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
          //     ),
          //   ),
          // ),

          /// Youtube video
          Visibility(
            visible: videoList.isNotEmpty,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              height: 110.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: videoList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoScreen(
                                          youtubeVideo: videoList[index],
                                          index: index,
                                          videoId: videoList[index].url,
                                          // onChange: (video) {
                                          //   setState(
                                          //       () => videoList[index] = video);
                                          // },
                                        )));
                          },
                          child: Card(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "https://1.bp.blogspot.com/-5NBQv5hi4fw/XfBkPpizYeI/AAAAAAAAjls/8bVTseXp39IQnRUNUN-2xoP89LRsMCDJQCLcBGAsYHQ/s1600/Divine%2B4-001.jpg"),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                                  
                              child: Center(child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(videoList[index].title,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white), overflow: TextOverflow.fade,),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    );
                  }),
            ),
          ),

          //top products
          Visibility(
              visible: productList.isNotEmpty && _prodError == null,
              child: Container(
                height: 350,
                color: Color(0xff004272),
                //margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: Text(
                        'New Arrivals',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade200),
                      ),
                    ),
                    _buildProductCarousel(),
                  ],
                ),
              )),

          //  // top post label
          Visibility(
            visible: postList.isNotEmpty && _postError == null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
              child: Text(
                'Top Posts',
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).accentColor),
              ),
            ),
          ),

          // // top posts carousel
          Visibility(
              visible: postList.isNotEmpty && _postError == null,
              child: Card(
                color: Colors.grey.shade200,
                margin: EdgeInsets.all(10),
                child: _buildPostCarousel(),
              )),

          Container(
            color: Color(0xff004272),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder()));
                            },
                            icon: Icon(Icons.library_books_outlined),
                            label: Text("Orders"))),
                  ),
                  Expanded(
                    child: Card(
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewRequirement()));
                            },
                            icon: Icon(Icons.format_list_numbered),
                            label: Text("Requirement", style: TextStyle(fontSize: 12),))),
                  ),
                  Expanded(
                    child: Card(
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Repair()));
                            },
                            icon: Icon(Icons.design_services_rounded),
                            label: Text("Repairs"))),
                  ),
                  
                ],
              ),
            ),
          ),

          Container(
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children : [
                Text('Planning to visit Mumbai?\nGet in touch with us.',
                  style: TextStyle(fontSize: 16),),
                IconButton(
                  onPressed: ()async{
                    //await showModalBottomSheet(context: context, builder: (_) => showDates());
                    arrivalText = null;
                    await _displayTextInputDialog(context);
                  }, 
                  icon: Icon(Icons.arrow_forward_ios_outlined)),
              ],
            ),
          ),
        ],
      ),
    );
  }

//Bullion dealer card
  Widget _buildBuliondealer(){
    return  Card(
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
                          color:
                          _bullionPriceController.selectedColourGold),
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
                          color: _bullionPriceController
                              .selectedColourSilver),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

//Product Carousel
  Widget _buildProductCarousel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            viewportFraction: 0.6,
            height: 250,
            //aspectRatio: 3,
            enlargeCenterPage: true,
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
                                  setState(() =>
                                      productList[_currentProductIndex] =
                                          product);
                                },
                              ),
                            ));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                //height: 150,
                                //width: 150,
                                color: Colors.white,
                                child: Center(
                                  child: CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              //color: Colors.black.withOpacity(0.6),
                              padding: EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "by ",
                                      style: TextStyle(fontSize: 10),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.firm.name.isNotEmpty
                                            ? "${item.firm.name}"
                                            : "-",
                                        style: TextStyle(
                                            color: Color(0xff004272),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
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

  fetchTopProducts() {
    setState(() {
      //isLoading = true;
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
            //isLoading = false;
          });
      });
    });
  }

  fetchVideo() {
    setState(() {
      BullionService.getAll().then((res) {
        List<YoutubeVideo> video=YoutubeVideo.listFromJson(res['data']);
        if(mounted)
          setState(() {
            video.shuffle();
            videoList.addAll(video);
            _videoError=null;
            isLoading=false;
          });
      }).catchError((err){
        if (mounted)
          setState(() {
            _prodError = err;
            //isLoading = false;
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
            height: 250,
            viewportFraction: 0.6,
            enlargeCenterPage: true,
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
                    //child: GridTile(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PostViewPage(
                                      posts: postList,
                                      index: _currentPostIndex,
                                      onChange: (post) {
                                        setState(() =>
                                            postList[_currentPostIndex] = post);
                                      },
                                    )));
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
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          //  Padding(
                          //    padding: const EdgeInsets.all(8.0),
                          //    child: GestureDetector(
                          //      child: Container(
                          //         width: 40.0,
                          //         height: 40.0,
                          //         child: post.firm.thumbUrl == null
                          //             ? Image.asset('images/placeholder.png')
                          //             : CachedNetworkImage(
                          //                 imageUrl: post.firm.thumbUrl,
                          //                 fit: BoxFit.contain,
                          //               ),
                          //       ),
                          //       onTap: () {
                          //       Navigator.of(context).push(
                          //         MaterialPageRoute(
                          //           builder: (_) => WholesalerViewPage(
                          //             wholesalerId: post.wholesalerFirmId,
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //    ),
                          //  ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                //width : 150,
                                child: post.thumbUrl == null
                                    ? null
                                    :
                                    // : GestureDetector(
                                    //     onTap: () async {
                                    //       // Navigator.of(context).push(
                                    //       //   MaterialPageRoute(
                                    //       //     builder: (_) => ImageView(
                                    //       //       imageUrl: post.imageUrl,
                                    //       //       heroTag: heroTag,
                                    //       //     ),
                                    //       //   ),
                                    //       //);
                                    //     },
                                    //     child:
                                    CachedNetworkImage(
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
                          ),
                          //),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              post.firm.name ?? '',
                              style: TextStyle(
                                  color: Color(0xff004272),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),

                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: postList.map((urlOfItem) {
            int index = postList.indexOf(urlOfItem);
            return Container(
              width: 5.0,
              height: 5.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPostIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.8)
                    : Color.fromRGBO(0, 0, 0, 0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  fetchTopPosts() {
    setState(() {
      //isLoading = true;
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
            //isLoading = false;
          });
      });
    });
  }

// visit mumbai
  Widget showDates() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text("Choose Dates"),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () async {
              DateTime arrival = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 7)));
              setState(() {
                if (arrival != null) {
                  arrivalText = DateFormat('dd-MM-yyyy').format(arrival);
                }
              });
            },
            icon: Icon(Icons.date_range_outlined),
            label: Text("Pick visit start date"),
          ),
          Visibility(
              visible: arrivalText != null, child: Text(arrivalText ?? "")),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () async {
              DateTime departure = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 7)));
              setState(() {
                if (departure != null) {
                  departureText = DateFormat('dd-MM-yyyy').format(departure);
                }
              });
            },
            icon: Icon(Icons.date_range_outlined),
            label: Text("Pick visit end date"),
          ),
          Visibility(
              visible: departureText != null, child: Text(departureText ?? "")),
        ],
      ),
      ElevatedButton(onPressed: () {}, child: Text("submit")),
    ]);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    //clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Date'),
          content: Container(
            height: 120,
            child: Column(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      arrival = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 7)));
                      setState(() {
                        if (arrival != null) {
                          arrivalText =
                              DateFormat('dd-MM-yyyy').format(arrival);
                          _itemDateController1.text =
                              DateFormat('dd-MM-yyyy').format(arrival);
                        }
                      });
                    },
                    icon: Icon(Icons.date_range_outlined),
                    label: Text("arrival date"),
                  ),
                ),
                Visibility(
                  visible: arrival != null,
                  child: Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.datetime,
                      textAlignVertical: TextAlignVertical.center,
                      controller: _itemDateController1,
                      //maxLength:10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('submit'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
