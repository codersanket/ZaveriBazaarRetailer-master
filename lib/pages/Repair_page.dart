import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/repairs.dart';
import 'package:sonaar_retailer/pages/Repair_edit.dart';
import 'package:sonaar_retailer/pages/Repair_add.dart';
import 'package:sonaar_retailer/pages/image_view.dart';
import 'package:sonaar_retailer/services/repair_service.dart';

class Repair extends StatefulWidget {
  @override
  _RepairState createState() => _RepairState();
}

class _RepairState extends State<Repair> {
  String initalValue = "Change Status";

  var statusList = ['Unassigned', 'Assigned', 'Received', 'Delivered', 'Cancel'];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 30};

  var isLoading = true, _error, totalPage = 0, rowCount = 0;
  List<Repairs> _repairs = [];


  @override
  void initState() {
    super.initState();
    //initalValue = statusList[1].toString();

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

    _fetchRepairs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Repairing Page"),
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
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RepairAdd()));
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


   Widget _buildListItem(BuildContext context, int index) {
    final heroTag = 'post - ${_repairs[index].id}';
    final repair = _repairs[index];
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
                                  new TextSpan(text: '${repair.customerName}', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                  new TextSpan(text: '${repair.customerNumber}', style: new TextStyle(fontWeight: FontWeight.bold)),
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
                                  new TextSpan(text: '${repair.inwardDate}', style: new TextStyle(fontWeight: FontWeight.bold)),
                                ],
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RepairEdit()));
                            },
                            child: Text("Edit"),
                          ),
                          RaisedButton(
                            onPressed: () {},
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
                                " ${repair.statusDetails.statusName} ",
                                style: TextStyle(
                                  color: Colors.white,
                                  // backgroundColor: repair.assignedStatus == 3 || repair.assignedStatus == 4 ?
                                  //   repair.assignedStatus == 3 ? Colors.green : Colors.red : Colors.grey.shade400,
                                ),
                                ),
                              // value:  initalValue,
                              onChanged: (String newValue) {
                                // setState(() {
                                //   initalValue = newValue;
                                // });
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

  _fetchRepairs() {
    setState(() => isLoading = true);

    RepairService.getAll(params).then((res){
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
    }).catchError((err){
      if (mounted)
        setState(() {
          _error = err;
          isLoading = false;
        });
    });
}
  //   PostService.getAll(params).then((res) {
  //     List<Post> posts = Post.listFromJson(res['data']);
  //     totalPage = res['last_page'];
  //     if (rowCount == 0) rowCount = res['total'];

  //     if (mounted)
  //       setState(() {
  //         _posts.addAll(posts);
  //         //print(_posts[0]);
  //         _error = null;
  //         isLoading = false;
  //       });
  //   }).catchError((err) {
  //     if (mounted)
  //       setState(() {
  //         _error = err;
  //         isLoading = false;
  //       });
  //   });
  // }
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