import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/bullion_service.dart';

import 'bullion_vendor_detail_page.dart';

// ignore: must_be_immutable
class BullionVendorPage extends StatefulWidget {
  String cityId;
  GetLivePrice getLivePrice;

  BullionVendorPage(this.cityId, this.getLivePrice);

  @override
  _BullionVendorPageState createState() => _BullionVendorPageState();
}

class _BullionVendorPageState extends State<BullionVendorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoading = true, _error;
  List<BullionVendor> _vendorList = [];
  BullionService bullionService;

  @override
  void initState() {
    super.initState();
    bullionService = new BullionService(context);
    AuthService.getUser().then((res) {
      _fetchData(res.id);
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bullion Dealer', style: TextStyle(fontFamily: 'serif')),
      ),
      key: _scaffoldKey,
      body: _error != null
          ? Center(child: Text(_error.toString()))
          : Stack(
              children: <Widget>[
                _buildListView(),
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

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _vendorList.length,
      separatorBuilder: (ctx, i) => Divider(height: 1),
      itemBuilder: (context, index) {
        BullionVendor model = _vendorList[index];
        return Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: ListTile(
              // User info details
              title: Row(
                children: [
                  Text(model.firm_name),
                  Text(" ("),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.star,
                      color: Color(0xffdea321),
                    ),
                  ),
                  Text(
                    model.avg_rating.roundToDouble().toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(")"),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Mobile:'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                              model.mobile != null ? model.mobile : 'NA',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        children: [
                          Text('Gold:'),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                                model.gold_price_margin != null
                                    ? (widget.getLivePrice != null
                                            ? '₹' +
                                                (widget.getLivePrice.gold +
                                                        model.gold_price_margin)
                                                    .toString()
                                            : '₹' +
                                                model.gold_price_margin
                                                    .toString()) ??
                                        'NA'
                                    : 'NA',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        children: [
                          Text('Silver:'),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                                model.silver_price_margin != null
                                    ? (widget.getLivePrice != null
                                            ? '₹' +
                                                (widget.getLivePrice.silver +
                                                        model
                                                            .silver_price_margin)
                                                    .toString()
                                            : '₹' +
                                                model.silver_price_margin
                                                    .toString()) ??
                                        'NA'
                                    : 'NA',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Container(
                height: double.infinity,
                child: Icon(Icons.chevron_right),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        BullionVendorDetailPage(model, widget.getLivePrice),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  _fetchData(String userId) {
    setState(() => isLoading = true);

    bullionService.getVendorList(userId, widget.cityId, 0, 0).then((res) {
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
