import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonaar_retailer/models/status.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/repair_service.dart';
import 'package:sonaar_retailer/services/homepage_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/user_contact_service.dart';

class RepairAdd extends StatefulWidget {
  @override
  _RepairAddState createState() => _RepairAddState();
}

class _RepairAddState extends State<RepairAdd> {
  DateTime selectedDate = DateTime.now();
  File _image;
  Status _statusValue;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<UserContact> _contacts = [];
  //List<Contact> _contacts = [];
  ScrollController _scrollController;
  var isLoading = false, isSyncing = false, totalPage = 0, rowCount = 0;
  Map<String, dynamic> params = {'page': 1, 'per_page': 50};
  double progress = 0;
  String deviceId;
  int selectedIndex;
  List<Status> _status = [];

  TextEditingController _datetimeController = TextEditingController();
  TextEditingController _noController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStatusList();
    // _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels >=
    //       _scrollController.position.maxScrollExtent - 200) {
    //     if (!isLoading) {
    //       if ((params['page'] + 1) <= totalPage) {
    //         params['page'] = params['page'] + 1;
    //         fetchContacts();
    //       }
    //     }
    //   }
    // });

    // checkStatusAndInit();
  }

  checkStatusAndInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    deviceId = prefs.getString('device_id');
    params['device_id'] = deviceId;

    fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Repair item"),
      ),
      body: Stack(
        children: [
          Container(
          child: SingleChildScrollView(
            child: Padding(
              padding:
              const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Customer Name',
                            prefixIcon: Icon(Icons.person)),
                        validator: (v) {
                          return v.isEmpty ? 'Please enter Name' : null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      child: TextFormField(
                        controller: _noController,
                        validator: (v) {
                          return v.isEmpty ? 'Please select customer contact' : v.length > 12 || v.length < 10 ? 'Please enter valid number': null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Customer Number',
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                // showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: Text("Contact"),
                                //         content: Container(
                                //           width: double.maxFinite,
                                //           child: Column(
                                //             mainAxisSize: MainAxisSize.min,
                                //             children: [
                                //               Expanded(child: _buildListView())
                                //             ],
                                //           ),
                                //         ),
                                //       );
                                //     });
                              },
                              child: Icon(
                                Icons.phone,
                                color: Colors.blue,
                              ),
                            )),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      child: TextFormField(
                        controller: _datetimeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Repair issue date',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (v) {
                          return v.isEmpty ? 'Please select Date' : null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Material(
                      //color: Colors.white,
                      child: ListTile(
                        onTap: pickImage,
                        trailing: Icon(Icons.image, color: Colors.blue),
                        title: Text('Photo'),
                        subtitle: _image == null
                            ? null
                            : Container(
                          padding: EdgeInsets.only(top: 8.0),
                          height: 200.0,
                          child: Image.file(_image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      child: TextFormField(
                        controller: _remarkController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Remark',
                        ),
                        // validator: (v) {
                        //   return v.isEmpty ? 'Please enter Remark data' : null;
                        // },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      child: TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Weight',
                        ),
                        // validator: (v) {
                        //   return v.isEmpty ? 'Please enter Weight' : null;
                        // },
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: _status.map((Status value) {
                                  return DropdownMenuItem<Status>(
                                    value: value,
                                    child: Text(value.statusName),
                                  );
                                }).toList(),
                                hint: Text(
                                  _statusValue == null ? "choose initial status" : _statusValue.statusName,
                                  ),
                                onChanged: (Status newValue) {
                                  setState(() {
                                    _statusValue = newValue;
                                  });
                                },
                              ),
                            ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(horizontal: 75),
                        child: Text("Submit"),
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState.validate()) {
                            // print(_nameController.text);
                            // print(_noController.text);
                            // print(_datetimeController.text);
                            // print(_remarkController.text);
                            // print(_weightController.text);
                            // print(_image.path);
                            _submit();
                          }
                          //Navigator.pop(context, true);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
          Visibility(
                  visible: isLoading,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
                ),
        ] 
      ),
    );
  }
///get Contact
  fetchContacts() async {
    setState(() {
      isLoading = true;
      // if (params['page'] == 1) {
      //   _contacts.clear();
      //   rowCount = 0;
      // }
    });

    // UserContactService.getAll(params).then((res) {
    //   List<UserContact> posts = UserContact.listFromJson(res['data']);
    //   totalPage = res['last_page'];
    //   if (rowCount == 0) rowCount = res['total'];

    //   setState(() {
    //     _contacts.addAll(posts);
    //     isLoading = false;
    //   });
    // }).catchError((err) {
    //   setState(() {
    //     isLoading = false;
    //   });
    // });

    ContactsService.getContacts(withThumbnails: false).then((res){
      
    }).catchError((err){
     if (mounted)
        setState(() {
          isLoading = false;
        });
    });
  }
///show dialog listview
  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: _contacts.length,
      //separatorBuilder: (ctx, i) => Divider(height: 0),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
            title: Text(
              contact.name,
              style: TextStyle(color: Colors.black),
            ),
            subtitle: Text(contact.mobile),
            onTap: () {
              setState(() {
                selectedIndex = index;
                _noController.text = contact.mobile;
                print(contact.mobile);
                Navigator.pop(context);
              });
            });
      },
    );
  }

  ///select date
  _selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
        _datetimeController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    //_datetimeController.text=selectedDate.toString().DateFormat("yyyy-MM-dd").format(selectedDate);
  }

  ///pick image from camera & Gallery
  void pickImage() async {
    final source = await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text('Select image from'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('Camera', style: TextStyle(fontSize: 16.0)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('Gallery', style: TextStyle(fontSize: 16.0)),
            )
          ],
        );
      },
    );

    var file = await ImagePicker.pickImage(source: source);
    setState(() => _image = file);
  }

  _submit() async{
    if(_image == null){
      ToastService.error(_scaffoldKey, 'Please pick image');
      return;
    }
    if(_statusValue== null){
      ToastService.error(_scaffoldKey, 'Please choose status value');
      return;
    }
    
    final Map<String, dynamic> data = {
      'customer_name': _nameController.text,
      'customer_number': _noController.text,
      'inward_date': _datetimeController.text,
      'image': await MultipartFile.fromFile(_image.path),
      'remark': _remarkController.text,
      'weight': _weightController.text,
      'assign_status': _statusValue.id,
      'user_id': AuthService.user.id,
    };

    FormData formData = FormData.fromMap(data);

    setState(() => this.isLoading = true);

    RepairService.create(formData).then((res) {
        Navigator.pop(context, true);
      }).catchError((err) {
        _showError(err.toString());
      }).whenComplete(() {
        setState(() => this.isLoading = false);
      });
  }

  _fetchStatusList(){
    setState(() => isLoading = true);

    HomePageService.getAllStatus({"repairing" : "1"}).then((res){
      List<Status> status = Status.listFromJson(res["data"]);
      if(mounted){
        setState(() {
          _status.addAll(status);
          isLoading=false;
        });
      }

    }).catchError((err){
      _showError(err.toString());
      if (mounted)
        setState(() {
          isLoading = false;
        });
    });
  }

  void _showError(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
    ));
  }


}
