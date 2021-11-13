import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/services/user_contact_service.dart';

class RepairAdd extends StatefulWidget {
  @override
  _RepairAddState createState() => _RepairAddState();
}

class _RepairAddState extends State<RepairAdd> {
  DateTime selectedDate = DateTime.now();
  File _image;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  List<UserContact> _contacts = [];
  ScrollController _scrollController;
  var isLoading = false, isSyncing = false, totalPage = 0, rowCount = 0;
  Map<String, dynamic> params = {'page': 1, 'per_page': 50};
  double progress = 0;
  String deviceId;
  int selectedIndex;

  TextEditingController _datetimeController = TextEditingController();
  TextEditingController _noController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading) {
          if ((params['page'] + 1) <= totalPage) {
            params['page'] = params['page'] + 1;
            fetchContacts();
          }
        }
      }
    });

    checkStatusAndInit();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Repair Add"),
      ),
      body: Container(
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
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Customer Number',
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Contact"),
                                      content: Container(
                                        width: double.maxFinite,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(child: _buildListView())
                                          ],
                                        ),
                                      ),
                                    );
                                  });
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
                        labelText: 'Repair date',
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
                      validator: (v) {
                        return v.isEmpty ? 'Please enter Remark data' : null;
                      },
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
                      validator: (v) {
                        return v.isEmpty ? 'Please enter Weight' : null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 75),
                      child: Text("Submit"),
                      onPressed: loading
                          ? null
                          : () {
                        if (_formKey.currentState.validate()) {
                          print(_nameController.text);
                          print(_noController.text);
                          print(_datetimeController.text);
                          print(_remarkController.text);
                          print(_weightController.text);
                          print(_image.path);
                        }
                        Navigator.pop(context, true);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
///get Contact
  fetchContacts() async {
    setState(() {
      isLoading = true;
      if (params['page'] == 1) {
        _contacts.clear();
        rowCount = 0;
      }
    });

    UserContactService.getAll(params).then((res) {
      List<UserContact> posts = UserContact.listFromJson(res['data']);
      totalPage = res['last_page'];
      if (rowCount == 0) rowCount = res['total'];

      setState(() {
        _contacts.addAll(posts);
        isLoading = false;
      });
    }).catchError((err) {
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

    // Directory tempDir = await getTemporaryDirectory();
    // String targetPath = tempDir.path + randomAlpha(5);
    // file = await FlutterImageCompress.compressAndGetFile(
    //   file.absolute.path,
    //   targetPath,
    //   quality: 80,
    // );
    setState(() => _image = file);
  }
}
