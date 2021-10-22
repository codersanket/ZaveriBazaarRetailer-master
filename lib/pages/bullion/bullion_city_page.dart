import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonaar_retailer/models/bullion_city.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/bullion_service.dart';

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
  var isLoading = true, _error;
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
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Scaffold(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
            child: Text(
              'Average Trader Price',
              style:
                  TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
            ),
          ),

          // estimated gold/silver card view
          Row(
            children: [
              Expanded(
                // estimated gold price card
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
                        // gold price (live)
                        Text(
                          'Gold',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                            BullionPriceHelper.getEstimatedPrice(
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

              // estimated silver price card
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
                        // gold price (live)
                        Text(
                          'Silver',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                            BullionPriceHelper.getEstimatedPrice(
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
        ],
      ),
    );
  }

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
