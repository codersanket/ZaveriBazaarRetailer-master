import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/order.dart';
import 'package:sonaar_retailer/models/status.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/pages/orders_add.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/homepage_service.dart';
import 'package:sonaar_retailer/services/order_service.dart';

class OrdersPage extends StatefulWidget {
  final bool focusSearch;
  OrdersPage({this.focusSearch = false});
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = false, _error, totalPage = 0, rowCount = 0;
  List<Orders> _orders = [];
  List<Status> _status = [];

  List<String> tags = [];
  bool searchVisible = false;
  Map<String, dynamic> param = {};
  final searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  FocusNode searchFocusNode;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchVisible = widget.focusSearch;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchOrders();
          }
        }
      }
    });
    _fetchStatusList();
    //_fetchOrders();
    if (widget.focusSearch) {
      searchFocusNode.requestFocus();
    } else {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchVisible && param['query'] != null) {
                searchProducts(null);
              }
              setState(() => searchVisible = !searchVisible);
            },
          )
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _error != null
                ? buildErrorWidget()
                : Stack(children: <Widget>[
                    _buildListView(),
                    Visibility(
                      visible: isLoading,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0)),
                    ),
                  ]),
          )
        ],
      ),
      // body: _error != null
      //     ? buildErrorWidget()
      //     : Stack(
      //         children: <Widget>[
      //           _buildListView(),
      //           Visibility(
      //             visible: searchVisible,
      //             child: Card(
      //               margin: EdgeInsets.only(left: 8, right: 8, top: 8),
      //               elevation: 2,
      //               child: AutoCompleteTextField(
      //                 key: searchKey,
      //                 focusNode: searchFocusNode,
      //                 controller: searchController,
      //                 suggestions: tags,
      //                 clearOnSubmit: false,
      //                 itemBuilder: (BuildContext context, String suggestion) {
      //                   return Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: <Widget>[
      //                       Divider(
      //                         height: 1,
      //                         thickness: 1,
      //                         color: Colors.grey.shade300,
      //                       ),
      //                       Padding(
      //                         padding: const EdgeInsets.all(12.0),
      //                         child: Text(suggestion),
      //                       )
      //                     ],
      //                   );
      //                 },
      //                 itemSorter: (String a, String b) {
      //                   return a.compareTo(b);
      //                 },
      //                 itemFilter: (String suggestion, String query) {
      //                   return suggestion
      //                       .toLowerCase()
      //                       .contains(query.toLowerCase());
      //                 },
      //                 itemSubmitted: searchProducts,
      //                 textSubmitted: searchProducts,
      //                 decoration: InputDecoration(
      //                   hintText: 'Search',
      //                   border: InputBorder.none,
      //                   prefixIcon: Icon(Icons.search, size: 18),
      //                   contentPadding: EdgeInsets.all(16),
      //                 ),
      //               ),
      //             ),
      //           ),
      //           Visibility(
      //             visible: isLoading,
      //             child: Center(
      //                 child: CircularProgressIndicator(strokeWidth: 2.0)),
      //           ),
      //         ],
      //       ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _createOrder();
        },
      ),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_error.toString()),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, index);
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final heroTag = 'post - ${_orders[index].id}';
    final order = _orders[index];
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: RichText(
                        overflow: TextOverflow.fade,
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: 'name: '),
                            new TextSpan(
                                text: '${order.customerName}',
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: RichText(
                        overflow: TextOverflow.fade,
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: 'contact: '),
                            new TextSpan(
                                text: '${order.customerNumber}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: RichText(
                        overflow: TextOverflow.fade,
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: 'issue date: '),
                            new TextSpan(
                                text: '${order.date}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text("order Items : ${order.orderItem.length}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text("view details"),
                              Icon(Icons.navigate_next_rounded)
                            ],
                          )),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  onPressed: () {
                    _editOrder(index);
                  },
                  child: Text("Edit"),
                ),
                RaisedButton(
                  onPressed: () {
                    _deleteOrder(index);
                  },
                  child: Text("Delete"),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: _status.map((Status value) {
                      return DropdownMenuItem<Status>(
                        value: value,
                        child: Text(value.statusName),
                      );
                    }).toList(),
                    hint: Text(
                      " ${order.statusDetail.statusName} ",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor:
                            order.statusDetail.statusName == "DELIVERED"
                                ? Colors.green
                                : order.statusDetail.statusName == "CANCELLED"
                                    ? Colors.red
                                    : Colors.grey.shade400,
                      ),
                    ),
                    // value:  initalValue,
                    onChanged: (Status newValue) {
                      // setState(() {
                      //   initalValue = newValue;
                      // });
                      _updateStatus(id: newValue.id, index: index);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget _buildOrderItemList({List<OrderItem> items}) {
  //    ScrollController _itemScrollController;
  //   return ListView.builder(
  //     controller: _itemScrollController,
  //     itemCount: items.length,
  //     itemBuilder: (context, index) {
  //       //return _buildListOrderItem(item: items[index]);
  //       return ListTile(
  //         title: Text(items[index].product, overflow: TextOverflow.fade,),
  //       );
  //     },
  //   );
  // }

  // Widget _buildListOrderItem({OrderItem item}){
  //   return ListTile(
  //     title: Text(item.product),
  //   );
  // }

  Widget _buildOrderItemList({List<OrderItem> items}) {
    List<Widget> widgetList = [];
    items.forEach((element) {
      widgetList.add(OutlinedButton(
        onPressed: () {},
        child: Text(element.product, overflow: TextOverflow.fade),
      ));
    });
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgetList,
    );
  }
  //Text(element.product, overflow: TextOverflow.fade)

  searchProducts(String keyword) {
    // param['user_id']=AuthService.user.id;
    param['query'] = keyword;
    // params['page'] = 1;
    print('Search KeyWord:-$keyword');
    fetchData();
  }

  fetchData() {
    param['user_id'] = AuthService.user.id;
    setState(() {
      isLoading = true;
      _orders.clear();
    });
    OrderService.search(param).then((res) {
      List<Orders> order = Orders.listFromJson(res['data']);
      if (mounted)
        setState(() {
          _orders.addAll(order);
          // _repairs = res ;
          _error = null;
          isLoading = false;
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _orders.clear();
          _error = err;
          isLoading = false;
        });
    });
  }

  _fetchStatusList() {
    setState(() => isLoading = true);

    HomePageService.getAllStatus({"create_order": "1"}).then((res) {
      List<Status> status = Status.listFromJson(res["data"]);
      if (mounted) {
        setState(() {
          _status.addAll(status);
          _error = null;
          isLoading = false;
        });
      }
    }).catchError((err) {
      _showError(err.toString());
      if (mounted)
        setState(() {
          _error = err;
          isLoading = false;
        });
    });
  }

  _fetchOrders() {
    setState(() => isLoading = true);

    OrderService.getAll(params).then((res) {
      List<Orders> repairs = Orders.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          _orders.addAll(repairs);
          //print(_posts[0]);
          _error = null;
          isLoading = false;
        });
    }).catchError((err) {
      _showError(err.toString());
      if (mounted)
        setState(() {
          _error = err;
          isLoading = false;
        });
    });
  }

  _createOrder() async {
    final refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddOrder()));
    if (refresh != null && refresh) {
      _orders = [];
      params['page'] = 1;
      this._fetchOrders();
    }
  }

  _editOrder(int index) {
    // Navigator.of(context)
    //     .push(
    //   MaterialPageRoute(
    //     builder: (_) => EditRequirement(requirement: _requirements[index]),
    //   ),
    // )
    //     .then((res) {
    //   if (res != null) {
    //     setState(() => _requirements[index] = res);
    //   }
    // });
  }

  _updateStatus({int id, int index}) async {
    setState(() => isLoading = true);

    Orders data = _orders[index];
    data.status = id;
    FormData formData = FormData.fromMap(data.toJson());

    OrderService.update(formData).then((res) {
      setState(() {
        _orders[index] = res;
      });
    }).catchError((err) {
      _showError(err.toString());
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  _deleteOrder(int index) async {
    final result = await _showConfirmationDialog();
    if (result == 'yes') {
      OrderService.delete(id: _orders[index].id, userId: _orders[index].userId)
          .then((res) {
        setState(() => _orders.removeAt(index));
      }).catchError((err) => _showError(err.toString()));
    }
  }

  _showConfirmationDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete item'),
          content: Text(
            'Are you sure you want to remove this order?',
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop('no'),
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop('yes'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
    ));
  }
}
