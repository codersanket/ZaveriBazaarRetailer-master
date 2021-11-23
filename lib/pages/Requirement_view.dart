import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/requirement.dart';
import 'package:sonaar_retailer/pages/Requirement_create.dart';
import 'package:sonaar_retailer/pages/Requirement_edit.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/services/requirement_service.dart';

enum SingingCharacter { lafayette, jefferson }

class ViewRequirement extends StatefulWidget {
  @override
  _ViewRequirementState createState() => _ViewRequirementState();
}

class _ViewRequirementState extends State<ViewRequirement> {
  String initalValue = 'Status';
  var statusList = ['Open', 'Close'];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, _error, totalPage = 0, rowCount = 0;
  List<Requirement> _requirements = [];

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('View Requirements'),
      ),
      body: _error != null
          ? buildErrorWidget()
          : Stack(
              children: <Widget>[
                _buildListView(),
                Visibility(
                  visible: isLoading,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
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
                  padding: const EdgeInsets.only(top: 20,bottom: 20,left: 15,right: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ConstrainedBox(
                            constraints:  BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.35,
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
                                  new TextSpan(text: '${requirement.customerName}', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                  new TextSpan(text: '${requirement.customerNumber}', style: new TextStyle(fontWeight: FontWeight.bold)),
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
                                  //new TextSpan(text: 'item type: '),
                                  new TextSpan(text: '${requirement.jewelleryType}  ${requirement.productCategoryType}', style: new TextStyle(fontWeight: FontWeight.bold)),
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
                                  new TextSpan(text: '${requirement.createdAt.substring(0,10)}', style: new TextStyle(fontWeight: FontWeight.bold)),
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
                                    new TextSpan(text: '${requirement.remark}', style: new TextStyle(fontWeight: FontWeight.bold)),
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
                                  backgroundColor: requirement.status == "open" ? Colors.green : Colors.red,
                                ),
                                ),
                              // value:  initalValue,
                              onChanged: (String newValue) {
                                // setState(() {
                                //   initalValue = newValue;
                                // });
                                _updateStatus(status: newValue.toLowerCase(), index: index);
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

  _fetchRequirements() {
    setState(() => isLoading = true);

    RequirementService.getAll(params).then((res){
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
    }).catchError((err){
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

  _updateStatus({String status, int index}) async{
    setState(() => isLoading = true);

    Requirement data = _requirements[index];
    data.status = status;
    FormData formData = FormData.fromMap(data.toJson());

    RequirementService.update(formData).then((res){
      setState(() {
        _requirements[index] = res;
      });
    }).catchError((err){
      _showError(err.toString());
      if (mounted)      
        setState(() {
          isLoading = false;
        });
    }).whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
  }

  _deleteRequirement(int index) async {
    final result = await _showConfirmationDialog();
    if (result == 'yes') {
      RequirementService.delete(id: _requirements[index].id, userId: _requirements[index].userId).then((res) {
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


  // SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(
  //                 top: 40, left: 10, right: 10, bottom: 40),
  //             child: Card(
  //               child: Padding(
  //                 padding: const EdgeInsets.only(
  //                     top: 25, bottom: 25, left: 15, right: 15),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Text('Customer Name:',
  //                             style: TextStyle(
  //                                 fontSize: 17, fontWeight: FontWeight.bold)),
  //                         Text(
  //                           'Karan Patel',
  //                           style: TextStyle(fontSize: 17),
  //                         )
  //                       ],
  //                     ),
  //                     SizedBox(height: 20),
  //                     Row(
  //                       children: [
  //                         Text(
  //                           'Customer Number:',
  //                           style: TextStyle(
  //                               fontSize: 17, fontWeight: FontWeight.bold),
  //                         ),
  //                         Text(
  //                           '1234567892',
  //                           style: TextStyle(fontSize: 17),
  //                         )
  //                       ],
  //                     ),
  //                     // SizedBox(height: 20),
  //                     // Text(
  //                     //   "Requirement of",
  //                     //   style: TextStyle(
  //                     //       fontSize: 16, fontWeight: FontWeight.bold),
  //                     // ),
  //                     // Row(
  //                     //   children: [
  //                     //     Row(
  //                     //       children: [
  //                     //         Text(
  //                     //           "Old",
  //                     //           style: TextStyle(
  //                     //               fontSize: 17, fontWeight: FontWeight.w400),
  //                     //         ),
  //                     //         Radio(
  //                     //           value: SingingCharacter.lafayette,
  //                     //           groupValue: _character,
  //                     //           onChanged: (SingingCharacter value) {
  //                     //             setState(() {
  //                     //               _character = value;
  //                     //             });
  //                     //           },
  //                     //         ),
  //                     //       ],
  //                     //     ),
  //                     //     Row(
  //                     //       children: [
  //                     //         Text(
  //                     //           "New",
  //                     //           style: TextStyle(
  //                     //               fontSize: 17, fontWeight: FontWeight.w400),
  //                     //         ),
  //                     //         Radio(
  //                     //           value: SingingCharacter.jefferson,
  //                     //           groupValue: _character,
  //                     //           onChanged: (SingingCharacter value) {
  //                     //             setState(() {
  //                     //               _character = value;
  //                     //             });
  //                     //           },
  //                     //         ),
  //                     //       ],
  //                     //     )
  //                     //   ],
  //                     // ),
  //                     SizedBox(height: 15),
  //                     Row(
  //                       children: [
  //                         Text('jewellery type:',
  //                             style: TextStyle(
  //                                 fontSize: 17, fontWeight: FontWeight.bold)),
  //                         Text(
  //                           'Gold',
  //                           style: TextStyle(fontSize: 17),
  //                         )
  //                       ],
  //                     ),
  //                     SizedBox(height: 15),
  //                     Row(
  //                       children: [
  //                         Text('Category type:',
  //                             style: TextStyle(
  //                                 fontSize: 17, fontWeight: FontWeight.bold)),
  //                         Text(
  //                           'Finger Ring',
  //                           style: TextStyle(fontSize: 17),
  //                         )
  //                       ],
  //                     ),
  //                     SizedBox(height: 15),
  //                     Container(
  //                       height: 150,width: double.infinity,
  //                       child: Align(
  //                         alignment: Alignment.center,
  //                         child: Image.network(
  //                             'https://i.pinimg.com/originals/fa/e7/b9/fae7b9d5e63f4de1af63dc3726b4a567.jpg'),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     Row(
  //                       children: [
  //                         Text('Remark:',
  //                             style: TextStyle(
  //                                 fontSize: 17, fontWeight: FontWeight.bold)),
  //                         Text(
  //                           'Pure Gold Finger Ring.',
  //                           style: TextStyle(fontSize: 17),
  //                         )
  //                       ],
  //                     ),

  //                     SizedBox(height: 20),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         RaisedButton(
  //                           onPressed: () {
  //                             Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => EditRequirement()));
  //                           },
  //                           child: Text('Edit'),
  //                         ),
  //                         RaisedButton(
  //                           onPressed: () {},
  //                           child: Text('Delete'),
  //                         ),
  //                         DropdownButtonHideUnderline(
  //                           child: DropdownButton(
  //                             items: statusList.map((String value) {
  //                               return DropdownMenuItem<String>(
  //                                 value: value,
  //                                 child: Text(value),
  //                               );
  //                             }).toList(),
  //                             hint: Text(initalValue),
  //                             // value:  initalValue,
  //                             onChanged: (String newValue) {
  //                               setState(() {
  //                                 initalValue = newValue;
  //                               });
  //                             },
  //                           ),
  //                         )
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),




