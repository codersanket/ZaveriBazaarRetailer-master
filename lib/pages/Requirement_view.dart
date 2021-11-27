import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/requirement.dart';
import 'package:sonaar_retailer/pages/Requirement_create.dart';
import 'package:sonaar_retailer/pages/Requirement_edit.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/requirement_service.dart';

class ViewRequirement extends StatefulWidget {
  final bool focusSearch;
  ViewRequirement({this.focusSearch = false});
  @override
  _ViewRequirementState createState() => _ViewRequirementState();
}

class _ViewRequirementState extends State<ViewRequirement> {
  String initalValue = 'Status';
  var statusList = ['Open', 'Close'];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};
  Map<String, dynamic> param = {};

  var isLoading = false, _error, totalPage = 0, rowCount = 0;
  List<Requirement> _requirements = [];
  bool searchVisible = false;
  List<String> tags = [];
  final searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  FocusNode searchFocusNode;
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    searchFocusNode = new FocusNode();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            _fetchRequirements();
          }
        }
      }
    });
      _fetchRequirements();
    if (widget.focusSearch) {
      searchFocusNode.requestFocus();
    } else {
      //fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('View Requirements'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchVisible && params['query'] != null) {
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
      //           _buildListView(),  Visibility(
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
      //                   return suggestion.toLowerCase().contains(query.toLowerCase());
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
          _createRequirement();
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
      itemCount: _requirements.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, index);
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final heroTag = 'post - ${_requirements[index].id}';
    final requirement = _requirements[index];
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
                      //maxWidth: 100,
                      maxHeight: MediaQuery.of(context).size.width * 0.28,
                    ),
                    child: requirement.thumbUrl == null
                        ? null
                        : GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageView(
                                    imageUrl: requirement.imageUrl,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: requirement.thumbUrl,
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
                                text: '${requirement.customerName}',
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
                                text: '${requirement.customerNumber}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Text("${requirement.jewelleryType}", overflow: TextOverflow.fade,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Text("${requirement.productCategoryType}", overflow: TextOverflow.fade,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    //   child: RichText(
                    //     overflow: TextOverflow.fade,
                    //     text: new TextSpan(
                    //       style: new TextStyle(
                    //         fontSize: 12.0,
                    //         color: Colors.black,
                    //       ),
                    //       children: <TextSpan>[
                    //         //new TextSpan(text: 'item type: '),
                    //         new TextSpan(
                    //             text:
                    //                 '${requirement.jewelleryType}\n${requirement.productCategoryType}',
                    //             style:
                    //                 new TextStyle(fontWeight: FontWeight.bold)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
                                text:
                                    '${requirement.createdAt.substring(0, 10)}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: requirement.remark != null,
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
                                  text: '${requirement.remark}',
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
                    _editRequirement(index);
                  },
                  child: Text("Edit"),
                ),
                RaisedButton(
                  onPressed: () {
                    _deleteRequirement(index);
                  },
                  child: Text("Delete"),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: statusList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text(
                      " ${requirement.status} ",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: requirement.status == "open"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    // value:  initalValue,
                    onChanged: (String newValue) {
                      // setState(() {
                      //   initalValue = newValue;
                      // });
                      _updateStatus(
                          status: newValue.toLowerCase(), index: index);
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
      _requirements.clear();
    });

    RequirementService.search(param).then((res) {
      List<Requirement> requirements = Requirement.listFromJson(res['data']);
      if (mounted)
        setState(() {
          _requirements.addAll(requirements);
          //_requirements = res;
          _error = null;
          isLoading = false;
        });
    }).catchError((err) {
      if (mounted)
        setState(() {
          _requirements.clear();
          _error = err;
          isLoading = false;
        });
    });
  }

  _fetchRequirements() {
    setState(() => isLoading = true);

    RequirementService.getAll(params).then((res) {
      List<Requirement> repairs = Requirement.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      if (mounted)
        setState(() {
          _requirements.addAll(repairs);
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

  _createRequirement() async {
    final refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => CreateRequirement()));
    if (refresh != null && refresh) {
      _requirements = [];
      params['page'] = 1;
      this._fetchRequirements();
    }
  }

  _editRequirement(int index) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => EditRequirement(requirement: _requirements[index]),
      ),
    )
        .then((res) {
      if (res != null) {
        setState(() => _requirements[index] = res);
      }
    });
  }

  _updateStatus({String status, int index}) async {
    setState(() => isLoading = true);

    Requirement data = _requirements[index];
    data.status = status;
    FormData formData = FormData.fromMap(data.toJson());

    RequirementService.update(formData).then((res) {
      setState(() {
        _requirements[index] = res;
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

  _deleteRequirement(int index) async {
    final result = await _showConfirmationDialog();
    if (result == 'yes') {
      RequirementService.delete(
              id: _requirements[index].id, userId: _requirements[index].userId)
          .then((res) {
        setState(() => _requirements.removeAt(index));
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
            'Are you sure you want to remove this requirement item?',
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
