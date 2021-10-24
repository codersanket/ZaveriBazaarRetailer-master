import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/bullion_service.dart';
import 'package:sonaar_retailer/services/date.service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bullion_price_helper.dart';

class BullionVendorDetailPage extends StatefulWidget {
  final BullionVendor bullionVendor;
  final GetLivePrice getLivePrice;

  BullionVendorDetailPage(this.bullionVendor, this.getLivePrice);

  @override
  _BullionVendorDetailState createState() => _BullionVendorDetailState();
}

class _BullionVendorDetailState extends State<BullionVendorDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var isLoading = false, _error;
  BullionService bullionService;

  @override
  void initState() {
    super.initState();
    bullionService = new BullionService(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Bullion dealer details')),
      body: _error != null
          ? Center(child: Text(_error.toString()))
          : Stack(
              children: <Widget>[
                _buildParentView(),
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

  Widget _buildParentView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Details
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                // firm name
                ListTile(
                  title: Wrap(
                    direction: Axis.horizontal,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.bullionVendor.firm_name,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                            TextSpan(
                              text: " (",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.star,
                                color: Color(0xffdea321),
                                size: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.bullionVendor.avg_rating
                                      .roundToDouble()
                                      .toString() +
                                  ")",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                // recommendation
                ListTile(
                  title: Wrap(
                    direction: Axis.horizontal,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Recommendation',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                            TextSpan(
                              text: " (" +
                                  widget.bullionVendor.sum_recommend
                                      .toString() +
                                  ")",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // Address
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(widget.bullionVendor.address.isEmpty
                      ? "-"
                      : widget.bullionVendor.address),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // Mobile number
                ListTile(
                  onTap: call,
                  leading: Icon(Icons.phone),
                  title: Text(widget.bullionVendor.mobile),
                  trailing: Icon(Icons.chevron_right),
                ),

                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                // GST No.
                ListTile(
                  leading: Align(
                    widthFactor: 1,
                    child: Text(
                      'GST',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  title: Text(widget.bullionVendor.gst_no),
                ),
              ],
            ),
          ),

          // price card
          buildPriceCard(),

          // estimated price card
          buildEstimatedPriceCard(),

          // Links
          buildLinksCard(),

          // rate this order
          Visibility(
            child: buildRateCard(context),
            visible: widget.bullionVendor.ratting_review_by_user == null
                ? true
                : false,
          ),

          // rate if already given view
          Visibility(
            child: buildRateGivenCard(context),
            visible: widget.bullionVendor.ratting_review_by_user == null
                ? false
                : true,
          ),
        ],
      ),
    );
  }

  Widget buildPriceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // gold price
          ListTile(
            title: Text('Gold Rate:'),
            trailing: Text((widget.bullionVendor.gold_price_margin != null &&
                    widget.bullionVendor.is_gold_available == 1)
                ? BullionPriceHelper.getLivePrice(widget.getLivePrice.gold,
                    widget.bullionVendor.gold_price_margin)
                : '-'),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // silver price
          ListTile(
            title: Text('Silver Rate:'),
            trailing: Text((widget.bullionVendor.silver_price_margin != null &&
                    widget.bullionVendor.is_silver_available == 1)
                ? BullionPriceHelper.getLivePrice(widget.getLivePrice.silver,
                    widget.bullionVendor.silver_price_margin)
                : '-'),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  // estimated price widget
  Widget buildEstimatedPriceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // estimated gold price
          ListTile(
            title: Text('Estimated Gold Rate:'),
            trailing: Text((widget.bullionVendor.estimated_gold_price != null &&
                    widget.bullionVendor.is_gold_available == 1)
                ? BullionPriceHelper.getEstimatedPrice(widget.getLivePrice.gold,
                    widget.bullionVendor.estimated_gold_price)
                : '-'),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // estimated silver price
          ListTile(
            title: Text('Estimated Silver Rate:'),
            trailing: Text(
                (widget.bullionVendor.estimated_silver_price != null &&
                        widget.bullionVendor.is_silver_available == 1)
                    ? BullionPriceHelper.getEstimatedPrice(
                        widget.getLivePrice.silver,
                        widget.bullionVendor.estimated_silver_price)
                    : '-'),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget buildLinksCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // play store url
          ListTile(
            leading: ImageIcon(
              AssetImage("images/ic_play_store.png"),
            ),
            title: Text(widget.bullionVendor.android_app_link.isEmpty
                ? 'Not Given'
                : widget.bullionVendor.android_app_link),
            subtitle: Text('Play store url'),
            trailing: Icon(Icons.chevron_right),
            onTap: widget.bullionVendor.android_app_link.isEmpty
                ? null
                : () => openLink(widget.bullionVendor.android_app_link),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // apple store url
          ListTile(
            leading: ImageIcon(
              AssetImage("images/ic_app_store.png"),
            ),
            title: Text(widget.bullionVendor.ios_app_link.isEmpty
                ? 'Not Given'
                : widget.bullionVendor.ios_app_link),
            subtitle: Text('Apple store url'),
            trailing: Icon(Icons.chevron_right),
            onTap: widget.bullionVendor.ios_app_link.isEmpty
                ? null
                : () => openLink(widget.bullionVendor.ios_app_link),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // Website
          ListTile(
            leading: Icon(Icons.language),
            title: Text(widget.bullionVendor.website.isEmpty
                ? 'Not Given'
                : widget.bullionVendor.website),
            subtitle: Text('Website'),
            trailing: Icon(Icons.chevron_right),
            onTap: widget.bullionVendor.website.isEmpty
                ? null
                : () => openLink(widget.bullionVendor.website),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget buildRateCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // play store url
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rate this dealer'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _showRatingDialog(context);
            },
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget buildRateGivenCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // rating label
            Text(
              'Rating',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),

            // Rating view
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Row(
                children: [
                  // rating indicator view
                  RatingBarIndicator(
                    rating: (widget.bullionVendor.ratting_review_by_user !=
                                null &&
                            widget.bullionVendor.ratting_review_by_user
                                    .ratting !=
                                null)
                        ? widget.bullionVendor.ratting_review_by_user.ratting
                        : 0,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 16.0,
                    direction: Axis.horizontal,
                  ),

                  //  rating date
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        (widget.bullionVendor.ratting_review_by_user != null &&
                                widget.bullionVendor.ratting_review_by_user
                                        .created_at !=
                                    null)
                            ? DateService.ddMMMyyyy(widget.bullionVendor
                                .ratting_review_by_user.created_at)
                            : "",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        )),
                  ),
                ],
              ),
            ),

            // recommended view
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Row(
                children: [
                  //  recommended value
                  Text(
                      'Recommended: ' +
                          ((widget.bullionVendor.ratting_review_by_user !=
                                      null &&
                                  widget.bullionVendor.ratting_review_by_user
                                          .recommend !=
                                      null)
                              ? widget.bullionVendor.ratting_review_by_user
                                          .recommend ==
                                      1
                                  ? 'Yes'
                                  : 'No'
                              : ""),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                      )),
                ],
              ),
            ),

            // review text
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                  'Review: ' +
                      ((widget.bullionVendor.ratting_review_by_user != null &&
                              widget.bullionVendor.ratting_review_by_user
                                      .review !=
                                  null)
                          ? widget.bullionVendor.ratting_review_by_user.review
                          : ""),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  call() {
    launch("tel://${widget.bullionVendor.mobile}");
    UserLogService.userLogById(
      widget.bullionVendor.id,"Bullion Vendor details call")
                                    .then((res) {
                                  print("userLogById Success");
                                }).catchError((err) {
                                  print("userLogById Error:" + err.toString());
                                });
  }

  openLink(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://' + url;
    }
    launch(url);
  }

  Future<String> _showRatingDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        int _recommend = -1;
        double _rating = 0;
        final reviewController = TextEditingController();

        return AlertDialog(
          title: Text('Rate'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // recommend
                    Text('Would you recommend?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: RadioListTile(
                            title: Text("Yes"),
                            value: 1,
                            groupValue: _recommend,
                            onChanged: (value) {
                              setState(() {
                                _recommend = value;
                              });
                              print("_recommend" + _recommend.toString());
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RadioListTile(
                            title: Text("No"),
                            value: 0,
                            groupValue: _recommend,
                            onChanged: (value) {
                              setState(() {
                                _recommend = value;
                              });
                              print("_recommend" + _recommend.toString());
                            },
                          ),
                        ),
                      ],
                    ),

                    // rate dealer
                    Text('How do you rate this dealer?'),
                    // Rating
                    RatingBar.builder(
                      onRatingUpdate: (r) => setState(() => _rating = r),
                      initialRating: 0,
                      minRating: 1,
                      itemCount: 5,
                      glow: false,
                      itemSize: 32,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),

                    // review
                    TextFormField(
                      obscureText: false,
                      controller: reviewController,
                      decoration: InputDecoration(hintText: 'Review'),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please enter review';
                        else
                          return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop('cancelled');
              },
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Navigator.of(context).pop('submitted');
                  _updateVendorRating(
                      _recommend, _rating, reviewController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _updateVendorRating(int _recommend, double _rating, String text) {
    setState(() => isLoading = true);

    AuthService.getUser().then((res) {
      bullionService
          .updateVendorRating(
              res.id, widget.bullionVendor.vendor_id, _recommend, _rating, text)
          .then((res) {
        if (mounted)
          setState(() {
            _error = null;
            isLoading = false;
            // go back to previous screen
            Navigator.of(context).pop();
          });
      }).catchError((err) {
        if (mounted)
          setState(() {
            _error = err;
            isLoading = false;
          });
      });
    }).catchError((err) {
      print(err);
    });
  }
}
