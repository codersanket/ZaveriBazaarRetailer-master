import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/pages/cached_image.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/product_service.dart';
//import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
//import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductViewPage extends StatefulWidget {
  final List<Product> products;
  final int index;
  //List<WholesalerRating> ratings = [];
  //final List<Map<String, dynamic>> ratings;
  final Function(Product product) onChange;

  ProductViewPage({
    Key key,
    @required this.products,
    @required this.index,
    this.onChange,
  }) : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState(products);
}

class _ProductViewState extends State<ProductViewPage> {
  final List<Product> products;

  //final List<WholesalerRating> ratings;
  //final List<Map<String, dynamic>> ratings;

  _ProductViewState(this.products);

  PageController pageController;
  User authUser;
  dynamic rating;

  //bool isLoading = false;

  @override
  void initState() {
    super.initState();

    authUser = AuthService.user;
    pageController = PageController(initialPage: widget.index);
  }

  void getRating(String id) async {
    WholesalerRatingService.getRatingbyWholesalerId(id).then((value) {
      setState(() {
        rating = value;
      });
    }).catchError((err) {
      //ToastService.error(scaffoldKey, err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xff004272),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Product details')),
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            getRating(products[index].wholesalerFirmId);
          });

          //getRating(products[index].wholesalerFirmId);
        },
        controller: pageController,
        children: products.map((product) {
          final heroTag = 'product - ${product.id}';
          //getRating(product.wholesalerFirmId);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: CachedImage(
                                imageUrl: product.firm.thumbUrl,
                                width: 30,
                                height: 30,
                                placeholderIcon: Icons.person,
                              ),
                              onTap: product.firm.imageUrl != null
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ImageView(
                                          imageUrl: product.firm.imageUrl,
                                          heroTag: 'Wholesaler_firm',
                                        ),
                                  ),
                                );
                              }
                                  : null,
                            ),
                            //SizedBox(width: 10),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 10, right: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                WholesalerViewPage(
                                                  wholesalerId:
                                                  product.wholesalerFirmId,
                                                ),
                                          ),
                                        );
                                      },
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          product.firm.name,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff004272),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                                  rating == null
                                      ? Text(" ")
                                      : RatingBarIndicator(
                                    itemCount: 5,
                                    rating: double.parse(
                                        rating[0]["average"]),
                                    itemSize: 14,
                                    unratedColor: Colors.grey[700],
                                    itemBuilder: (BuildContext context,
                                        int index) {
                                      return Icon(Icons.star,
                                          color: Colors.yellow.shade600);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                UserLogService.userLogById(
                                    products[pageController.page.toInt()]
                                        .wholesalerFirmId,
                                    "Product details message")
                                    .then((res) {
                                  print("userLogById Success");
                                }).catchError((err) {
                                  print("userLogById Error:" + err.toString());
                                });
                                // do whatsapp share process
                                whatsappWholesaler(
                                    products[pageController.page.toInt()]
                                        .firm
                                        .mobile,
                                    products[pageController.page.toInt()]
                                        .shareLink);
                              },
                              icon: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.asset('images/whatsapp.png',
                                    color: Colors.green),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                UserLogService.userLogById(
                                    products[pageController.page.toInt()]
                                        .wholesalerFirmId,
                                    "Product details call")
                                    .then((res) {
                                  print("userLogById Success");
                                }).catchError((err) {
                                  print("userLogById Error:" + err.toString());
                                });
                                // call firm
                                launch(
                                    "tel://${products[pageController.page
                                        .toInt()].firm.mobile}");
                              },
                              icon: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.blueAccent,
                                  )),
                            ),
                          ],
                        ),
                        // ElevatedButton.icon(
                        //     style: ButtonStyle(
                        //       shape: MaterialStateProperty.all<
                        //               RoundedRectangleBorder>(
                        //           RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(18.0),
                        //       )),
                        //       foregroundColor:
                        //           MaterialStateProperty.all(Colors.white),
                        //       backgroundColor:
                        //           MaterialStateProperty.all(Colors.green),
                        //     ),
                        //     onPressed: () {
                        //       UserLogService.userLogById(
                        //               products[pageController.page.toInt()]
                        //                   .wholesalerFirmId,
                        //               "Product details")
                        //           .then((res) {
                        //         print("userLogById Success");
                        //       }).catchError((err) {
                        //         print("userLogById Error:" + err.toString());
                        //       });
                        //       // do whatsapp share process
                        //       whatsappWholesaler(
                        //           products[pageController.page.toInt()]
                        //               .firm
                        //               .mobile,
                        //           products[pageController.page.toInt()]
                        //               .shareLink);
                        //     },
                        //     icon: Image.asset('images/whatsapp.png',
                        //         width: 20, color: Colors.white),
                        //     label: Text(
                        //       'MESSAGE',
                        //       style: TextStyle(fontSize: 12),
                        //     )),
                      ],
                    ),
                  ),
                ),
                //SizedBox(height: 5),
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.white,
                          child: Hero(
                            tag: heroTag,
                            child: CachedNetworkImage(
                              imageUrl: product.thumbUrl,
                              fit: BoxFit.contain,
                              errorWidget: (c, u, e) =>
                                  Image.asset(
                                    "images/ic_launcher.png",
                                    fit: BoxFit.contain,
                                    alignment: Alignment.topCenter,
                                  ),
                              //   Icon(Icons.warning, color: Colors.white),
                              // placeholder: (c, u) => Center(
                              //     child: CircularProgressIndicator(
                              //         strokeWidth: 2.0)),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ImageView(
                                      imageUrl: product.imageUrl,
                                      heroTag: heroTag,
                                    )),
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(product.categoryName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                      product.createdAt
                                          .substring(0, 10)
                                          .split('-')
                                          .reversed
                                          .join('-') ??
                                          "-",
                                      style: TextStyle(fontSize: 12)),
                                )
                              ],
                            ),
                            GestureDetector(
                              child: Icon(
                                product.bookmarked
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.yellowAccent.shade400,
                                size: 34.0,
                              ),
                              onTap: () => bookmarkProduct(product),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  //color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTableRowGrid("Melting", product.melting ?? "-",
                          "Weight", product.weightRange ?? "-"),
                      //buildTableRowCard('Brand', product.brandName ?? "-"),
                      //buildTableRowCard('Melting', product.melting ?? "-"),
                      buildTableRowGrid('Mark', product.mark ?? "-", 'Brand',
                          product.brandName ?? "-"),
                      //buildTableRowCard('Weight', product.weightRange ?? "-"),
                      buildTableRowCard('Tags', product.tags ?? "-"),
                    ],
                  ),
                ),
                SizedBox(height: 72),
              ],
            ),
          );
        }).toList(),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //     label: Text('MESSAGE'),
      //     foregroundColor: Colors.white,
      //     icon: Image.asset('images/whatsapp.png',
      //         width: 24, color: Colors.white),
      //     backgroundColor: Colors.green,
      //     onPressed: () {
      //       UserLogService.userLogById(
      //               products[pageController.page.toInt()].wholesalerFirmId,
      //               "Product details")
      //           .then((res) {
      //         print("userLogById Success");
      //       }).catchError((err) {
      //         print("userLogById Error:" + err.toString());
      //       });
      //       // do whatsapp share process
      //       whatsappWholesaler(
      //           products[pageController.page.toInt()].firm.mobile,
      //           products[pageController.page.toInt()].shareLink);
      //     }),
    );
  }

  void whatsappWholesaler(String mobile, String shareLink) {
    final firmName = authUser.retailerFirmName;
    final city = authUser.city;

    try {
      final url = "https://api.whatsapp.com/send?phone=91$mobile&text=" +
          "ZaveriBazaar B2B platform\n\n$firmName from $city has an enquiry regarding your product. Click on the below link to view the product details\n\n$shareLink";
      // Uri.encodeFull(shareLink);
      final encodeURL = Uri.encodeFull(url);

      print("final url to open:" + url);
      print("final url to open: encode url " + encodeURL);
      launch(encodeURL);

      // launch("whatsapp://send?phone=91$mobile&text=" +
      //     "ZaveriBazaar B2B platform\n\n$firmName from $city has an enquiry regarding your product. Click on the below link to view the product details\n\n" +
      //     Uri.encodeFull(shareLink));

    } catch (error) {
      print("Launch Error:" + error.toString());
    }
  }

  Widget buildTableRowCard(String label, String value) {
    List tagList = value.split(",");
    return value.isEmpty
        ? Expanded(
        child: SizedBox(
          width: double.infinity,
        ))
        : Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Padding(
              padding: const EdgeInsets.all(5.0),
              child: tagList.length != 1
                  ? Wrap(
                spacing: 2.0,
                alignment: WrapAlignment.spaceBetween,
                children: List.generate(tagList.length, (index) {
                  return ChoiceChip(
                      label: Text(tagList[index]), selected: false);
                }),
              )
                  : ChoiceChip(label: Text(value), selected: false)),
        ],
      ),
    );
  }

  Widget buildTableRowGrid(String label1, String value1, label2, value2) {
    if (value1 == "-" && value2 != "-") {
      value1 = value2;
      label1 = label2;
      label2 = null;
      value2 = "-";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: value1 == "-"
              ? SizedBox(
            width: double.infinity,
          )
              : Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(label1,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      value1,
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          child: value2 == "-"
              ? SizedBox(
            width: double.infinity,
          )
              : Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(label2,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      value2,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget buildTags(String tags) {
  //   List tagList = tags.split(",");
  //   return Card(
  //     child: Wrap(
  //       children: List.generate(tagList.length, (index) {
  //         return ListTile(
  //           leading: Icon(Icons.people),
  //           title: Text(tagList[index]),
  //           onTap: () {},
  //           selected: true,
  //         );
  //       }),
  //     ),
  //   );
  // }

  void bookmarkProduct(Product product) {
    setState(() {
      product.bookmarked = !product.bookmarked;
    });

    ProductService.toggleBookmark(product.id, !product.bookmarked)
        .then((value) {})
        .catchError((err) {
      //ToastService.error(scaffoldKey, err.toString());
      setState(() {
        product.bookmarked = !product.bookmarked;
      });
    });
  }

}
