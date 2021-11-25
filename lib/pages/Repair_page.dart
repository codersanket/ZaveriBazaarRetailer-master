import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/repairs.dart';
import 'package:sonaar_retailer/models/status.dart';
import 'package:sonaar_retailer/pages/Repair_edit.dart';
import 'package:sonaar_retailer/pages/Repair_add.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/repair_service.dart';
import 'package:sonaar_retailer/services/homepage_service.dart';
import 'package:dio/dio.dart';

class Repair extends StatefulWidget {
  final bool focusSearch;
  final String customerName;
  final String customerNumber;
  Repair({this.focusSearch = false, this.customerName, this.customerNumber});
  @override
  _RepairState createState() => _RepairState();
}

class _RepairState extends State<Repair> {
  String initalValue = "Change Status";

  //var statusList = ['Unassigned', 'Assigned', 'Received', 'Delivered', 'Cancel'];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  Map<String, dynamic> param = {};
  var isLoading = false, _error, totalPage = 0, rowCount = 0;
  List<Repairs> _repairs = [];
  List<String> tags = [];
  List<Status> _status = [];
  bool searchVisible = false;
  final searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  FocusNode searchFocusNode;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initalValue = statusList[1].toString();
    searchFocusNode = new FocusNode();
    searchVisible = widget.focusSearch;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchRepairs();
          }
        }
      }
    });
    _fetchStatusList();
    _fetchRepairs();
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
        title: Text("Repairs Page"),
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
      body: _error != null
          ? buildErrorWidget()
          : Stack(
              children: <Widget>[
                _buildListView(),
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
                        return suggestion
                            .toLowerCase()
                            .contains(query.toLowerCase());
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
                Visibility(
                  visible: isLoading,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _createRepair();
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
      itemCount: _repairs.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, index);
      },
    );
  }

  searchProducts(String keyword) {
    param['user_id']=AuthService.user.id;
    param['query'] = keyword;
   // params['page'] = 1;
    print('Search KeyWord:-$keyword');
    fetchData();
  }

  fetchData() {
    setState(() {
      isLoading = true;
      _repairs.clear();
    });
    RepairService.search(param).then((res) {
      List<Repairs> repairs = Repairs.listFromJson(res['data']);
       if (mounted)
         setState(() {
          _repairs.addAll(repairs);
           _repairs = res ;
           _error = null;
           print("Heo"+_error);
           isLoading = false;
         });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _repairs.clear();
          _error = err;
          isLoading = false;
        });
    });

    // RepairService.getAll(params).then((res) {
    //   List<Repairs> repairs = Repairs.listFromJson(res['data']);
    //   totalPage = res['last_page'];
    //   if (rowCount == 0) rowCount = res['total'];
    //
    //   if (mounted)
    //     setState(() {
    //       _repairs.addAll(repairs);
    //       //print(_posts[0]);
    //       _error = null;
    //       isLoading = false;
    //     });
    // }).catchError((err) {
    //   _showError(err.toString());
    //   if (mounted)
    //     setState(() {
    //       _error = err;
    //       isLoading = false;
    //     });
    // });
  }

  Widget _buildListItem(BuildContext context, int index) {
    final heroTag = 'post - ${_repairs[index].id}';
    final repair = _repairs[index];
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.35,
                      maxHeight: MediaQuery.of(context).size.width * 0.28,
                    ),
                    child: repair.thumbUrl == null
                        ? null
                        : GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageView(
                                    imageUrl: repair.imageUrl,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: repair.thumbUrl,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorWidget: (c, u, e) => Image.asset(
                                "images/ic_launcher.png",
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                  ),
                ),
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
                                text: '${repair.customerName}',
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
                                text: '${repair.customerNumber}',
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
                                text: '${repair.inwardDate}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: repair.remark != null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: RichText(
                          overflow: TextOverflow.fade,
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(text: 'remark: '),
                              new TextSpan(
                                  text: '${repair.remark}',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                    _editRepair(index);
                  },
                  child: Text("Edit"),
                ),
                RaisedButton(
                  onPressed: () {
                    _deleteRepair(index);
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
                      " ${repair.statusDetails.statusName} ",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor:
                            repair.statusDetails.statusName == "DELIVERED"
                                ? Colors.green
                                : repair.statusDetails.statusName == "CANCELLED"
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

  _fetchStatusList() {
    setState(() => isLoading = true);

    HomePageService.getAllStatus({"repairing": "1"}).then((res) {
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

  _fetchRepairs() {
    setState(() => isLoading = true);

    RepairService.getAll(params).then((res) {
      List<Repairs> repairs = Repairs.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          _repairs.addAll(repairs);
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

  _createRepair() async {
    final refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => RepairAdd()));
    if (refresh != null && refresh) {
      _repairs = [];
      params['page'] = 1;
      this._fetchRepairs();
    }
  }

  _editRepair(int index) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => RepairEdit(repair: _repairs[index]),
      ),
    )
        .then((res) {
      if (res != null) {
        setState(() => _repairs[index] = res);
      }
    });
  }

  _updateStatus({int id, int index}) async {
    setState(() => isLoading = true);

    Repairs data = _repairs[index];
    data.assignedStatus = id;
    FormData formData = FormData.fromMap(data.toJson());

    RepairService.update(formData).then((res) {
      setState(() {
        _repairs[index] = res;
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

  _deleteRepair(int index) async {
    final result = await _showConfirmationDialog();
    if (result == 'yes') {
      RepairService.delete(
              id: _repairs[index].id, userId: _repairs[index].userId)
          .then((res) {
        setState(() => _repairs.removeAt(index));
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
            'Are you sure you want to remove this repair item?',
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

//Alternate to row UI
//              ListTile(
//   leading: ConstrainedBox(
//     constraints: BoxConstraints(
//       //minWidth: 100,
//       //minHeight: 260,
//       maxWidth:  MediaQuery.of(context).size.width * 0.4,
//       //maxHeight: 264,
//     ),
//     child: Image.network(
//                 "https://wi.wallpapertip.com/wsimgs/62-627190_gold-jewellery-wallpaper.jpg",
//                 fit: BoxFit.fill,
//               ),
//   ),
//   title: Text('Texas Angus Burger'),
//   subtitle: Text('With fries and coke.'),
//   dense: false,
//   isThreeLine: true,
// ),

//original UI
// ListTile(
//   shape: OutlineInputBorder(),
//   title: Padding(
//     padding: const EdgeInsets.only(bottom:8.0),
//     child: Text("abc"),
//   ),
//   leading : Text("name :"),
// ),
// SizedBox(height: 10),
// Container(
//   height: 45,
//   child: TextFormField(
//     decoration: InputDecoration(
//         border: OutlineInputBorder(),
//         labelText: 'contact'),
//   ),
// ),
// SizedBox(height: 10),
// Container(
//   height: 45,
//   child: TextFormField(
//     decoration: InputDecoration(
//         border: OutlineInputBorder(),
//         labelText: 'Issue date'),
//   ),
// ),
// SizedBox(height: 10),
// Container(
//   height: 200,
//   width: 200,
//   child: Image.network(
//     "https://wi.wallpapertip.com/wsimgs/62-627190_gold-jewellery-wallpaper.jpg",
//     fit: BoxFit.cover,
//   ),
// ),

//  SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding:
//                   const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 30),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 20,bottom: 20,left: 15,right: 15),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.all(2.0),
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               maxWidth: MediaQuery.of(context).size.width * 0.35,
//                               //maxHeight: MediaQuery.of(context).size.height * 0.5,
//                             ),
//                             child: Image.network(
//                           "https://wi.wallpapertip.com/wsimgs/62-627190_gold-jewellery-wallpaper.jpg",
//                           fit: BoxFit.cover,
//                         ),
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
//                               child: Text(
//                                 'Texas Angus Burger',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
//                               child: Text(
//                                 'Served with fries.',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                       ],
//                     ),
//                       SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           RaisedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => RepairEdit()));
//                             },
//                             child: Text("Edit"),
//                           ),
//                           RaisedButton(
//                             onPressed: () {},
//                             child: Text("Delete"),
//                           ),
//                           DropdownButtonHideUnderline(
//                             child: DropdownButton(
//                               items: statusList.map((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                               hint: Text(initalValue),
//                               // value:  initalValue,
//                               onChanged: (String newValue) {
//                                 setState(() {
//                                   initalValue = newValue;
//                                 });
//                               },
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
