import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonaar_retailer/models/category.dart';
import 'package:sonaar_retailer/models/product_type.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:sonaar_retailer/services/requirement_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

enum RequirementType {_old,_new}

class CreateRequirement extends StatefulWidget {
  @override
  _CreateRequirementState createState() => _CreateRequirementState();
}

class _CreateRequirementState extends State<CreateRequirement> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  RequirementType _requirementType = RequirementType._old;
  String initalValue;
  File _image;
  var statusList = ['open', 'close'];
  List<ProductType> typeList = [];
  List<Category> categoryList = [];
  bool isLoading = false;
  Category _selectedCategory;
  ProductType _selectedProductType;

  TextEditingController _noController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();

  List<UserContact> _contacts = [];
  ScrollController _scrollController;
  bool isSyncing = false;  

  @override
  void initState() {
    super.initState();
    _fetchCategoryList();
    _fetchTypeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Create Requirement"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 10, right: 10, bottom: 30),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 20, left: 15, right: 15),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    syncContacts();
                                  },
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                  ),
                                )
                              ),
                          ),
                        ),
                            SizedBox(height: 20),
                            Text(
                              "Requirement of",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Old",
                                      style: TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w400),
                                    ),
                                    Radio(
                                      value: RequirementType._old,
                                      groupValue: _requirementType,
                                      onChanged: (RequirementType value) {
                                        setState(() {
                                          _requirementType = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "New",
                                      style: TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w400),
                                    ),
                                    Radio(
                                      value: RequirementType._new,
                                      groupValue: _requirementType,
                                      onChanged: (RequirementType value) {
                                        setState(() {
                                          _requirementType = value;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 55,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    //hintText: 'Select Product category type'
                                ),
                                value: _selectedProductType,
                                hint: Text(_selectedProductType == null 
                                  ? "Select jewellery type" 
                                  : _selectedProductType.name,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (ProductType newValue) {
                                  setState(() {
                                    _selectedProductType = newValue;
                                  });
                                },
                                items: typeList.map((ProductType value) {
                                  return DropdownMenuItem<ProductType>(
                                    value: value,
                                    child: Text(value.name, style: TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 55,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    //hintText: 'Select Product category type'
                                ),
                                value: _selectedCategory,
                                hint: Text(_selectedCategory == null 
                                  ? "Select Product category type" 
                                  : _selectedCategory.name,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (Category newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: categoryList.map((Category value) {
                                  return DropdownMenuItem<Category>(
                                    value: value,
                                    child: Text(value.name, style: TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 15),
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
                              height: 55,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                ),
                                value: initalValue,
                                hint: Text(initalValue == null 
                                  ? "Select Status" 
                                  : initalValue,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    initalValue = newValue;
                                  });
                                },
                                items: statusList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: RaisedButton(
                              onPressed: isLoading
                                ? null
                                : () {
                                  if (_formKey.currentState.validate()) {
                                    _submit();
                                  }
                                },
                                child: Text('Submit'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.0)),
          ),
        ],
      ),
    );
  }


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

  _fetchCategoryList(){
    setState(() => isLoading = true);

    ProductService.getCategories().then((res){
      List<Category> categories = res;
      if(mounted){
        setState(() {
          categoryList.addAll(categories);
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

  _fetchTypeList(){
    setState(() => isLoading = true);

    ProductService.getTypes().then((res){
      List<ProductType> productTypes = res;
      if(mounted){
        setState(() {
          typeList.addAll(productTypes);
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

  _submit() async{
    if(_image == null){
      ToastService.error(_scaffoldKey, 'Please pick image');
      return;
    }
    if(initalValue== null){
      ToastService.error(_scaffoldKey, 'Please choose status value');
      return;
    }
    if(_selectedCategory == null){
      ToastService.error(_scaffoldKey, 'Please choose category');
      return;
    }
    if(_selectedProductType == null){
      ToastService.error(_scaffoldKey, 'Please choose jewellery type');
      return;
    }
    
    final Map<String, dynamic> data = {
      'customer_name': _nameController.text,
      'customer_number': _noController.text,
      'image': await MultipartFile.fromFile(_image.path),
      'remark': _remarkController.text,
      'requirement_of' : _requirementType == RequirementType._old ? "Old" : "New",
      'jewellery_type' : _selectedProductType.name,
      'product_category_type' : _selectedCategory.name,
      'status': initalValue,
      'user_id': AuthService.user.id,
    };

    FormData formData = FormData.fromMap(data);

    setState(() => this.isLoading = true);

    RequirementService.create(formData).then((res) {
        Navigator.pop(context, true);
      }).catchError((err) {
        _showError(err.toString());
      }).whenComplete(() {
        setState(() => this.isLoading = false);
      });
  }

  //contacts

  void dialog(BuildContext context) {
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
  }

  void syncContacts() async {
    bool granted = await _checkPermissions();
    if (!granted) return;

    setState(() {
      isSyncing = true;
    });

    // phone contacts
    final Iterable<Contact> pContacts =
    await ContactsService.getContacts(withThumbnails: false);

    // temp contacts array
    final List<UserContact> newContacts = [];

    for (var pc in pContacts) {
      for (var phone in pc.phones) {
        final mobile = normalizeMobileNumber(phone.value);
        if (mobile == null) continue;

        newContacts.add(UserContact(
            name: pc.displayName, mobile: mobile));
      }
    }

    if (newContacts.length > 0) {
      setState(() {
        _contacts = newContacts;
        isSyncing = false;
        dialog(context);
      });
    }else{
      setState(() => isSyncing = false);
    }
  }


  Future<bool> _checkPermissions() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);

    if (permission == PermissionStatus.granted) return true;

    Map status = await PermissionHandler()
        .requestPermissions([PermissionGroup.contacts]);

    if (status[PermissionGroup.contacts] == PermissionStatus.granted)
      return true;

    bool showRationale = await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.contacts);

    if (showRationale) {
      // return _checkPermissions();
      return false;
    } else {
      //openSettings();
    }

    return false;
  }
  
  String normalizeMobileNumber(String mobile) {
    if (mobile == null || mobile.length < 10) return null;

    mobile = mobile.replaceAll(new RegExp(r"[^\d]+"), "");
    if (mobile.length > 10) mobile = mobile.substring(mobile.length - 10);

    return mobile;
  }

  ///show dialog listview
  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount:_contacts.length,
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
                _noController.text = contact.mobile;
                Navigator.pop(context);
              });
            });
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
