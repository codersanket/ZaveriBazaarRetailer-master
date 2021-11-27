import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/category.dart';
import 'package:sonaar_retailer/models/product_type.dart';
import 'package:sonaar_retailer/models/requirement.dart';
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:sonaar_retailer/services/requirement_service.dart';

enum RequirementType {_old,_new}

class EditRequirement extends StatefulWidget {
  final Requirement requirement;
  EditRequirement({this.requirement});
  @override
  _EditRequirementState createState() => _EditRequirementState();
}

class _EditRequirementState extends State<EditRequirement> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RequirementType _requirementType = RequirementType._old;
  String initalValue = 'Status';
  File _image;
  var statusList = ['Open', 'Close'];

  bool isLoading = false;
  Requirement _edited;

  // Category _selectedCategory;
  // ProductType _selectedProductType;
  // List<ProductType> typeList = [];
  // List<Category> categoryList = [];
  List<String> typeList = [];
  List<String> categoryList = [];
  String _selectedCategory;
  String _selectedProductType;

  TextEditingController _noController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _edited = widget.requirement;
    _fetchCategoryList();
    _fetchTypeList();
    _noController.text =  widget.requirement.customerNumber;
    _nameController.text = widget.requirement.customerName;
    _remarkController.text =  widget.requirement.remark ?? null;
    _requirementType = widget.requirement.requirementOf == "Old" ? RequirementType._old: RequirementType._new;
    _selectedCategory = widget.requirement.productCategoryType;
    _selectedProductType = widget.requirement.jewelleryType;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Requirement'),
      ),
      body: Stack(
        children :[
          SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 35, left: 10, right: 10, bottom: 30),
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
                                  labelText: 'Customer name',
                                  //hintText: widget.repair.customerName
                                  ),
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
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                 return v.isEmpty ? 'Please select customer contact' : v.length > 12 || v.length < 10 ? 'Please enter valid number': null;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Customer number',
                                  //hintText: widget.repair.customerNumber
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
                                  : _selectedProductType,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _selectedProductType = newValue;
                                  });
                                },
                                items: typeList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(fontSize: 12)),
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
                                  : _selectedCategory,
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: categoryList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                            ),
                          SizedBox(height: 15),
                          ConstrainedBox(
                                constraints:  BoxConstraints(
                                  maxWidth: 200,
                                  maxHeight: 200,
                                  ),
                                child: widget.requirement.thumbUrl == null
                                  ? null
                                    : CachedNetworkImage(
                                    imageUrl: widget.requirement.thumbUrl,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorWidget: (c, u, e) => Image.asset(
                                      "images/ic_launcher.png",
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                    ),
                                    ),
                                  ),
                          // Material(
                          //   //color: Colors.white,
                          //   child: ListTile(
                          //     // onTap: pickImage,
                          //     trailing: Icon(Icons.image, color: Colors.blue),
                          //     title: Text('Photo'),
                          //     subtitle: _image == null
                          //         ? null
                          //         : Container(
                          //             padding: EdgeInsets.only(top: 8.0),
                          //             height: 200.0,
                          //             child: Image.file(_image, fit: BoxFit.cover),
                          //           ),
                          //   ),
                          // ),
                          SizedBox(height: 20),
                          Container(
                            height: 45,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Remark'),
                            ),
                          ),
                          SizedBox(height: 20),
                          RaisedButton(
                            onPressed: () {
                              // print(_nameController.text);
                              // print(_noController.text);
                              // print(_dateController.text);
                              if (_formKey.currentState.validate()) {
                                _submit();
                              }
                            },
                            child: Text("Submit"),
                          ),
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
        ]
         
      ),
    );
  }


  _fetchCategoryList(){
    setState(() => isLoading = true);

    ProductService.getCategories().then((res){
      List<Category> categories = res;
      if(mounted){
        setState(() {
          //categoryList.addAll(categories);
          categories.forEach((element) {categoryList.add(element.name);});
          isLoading=false;
          //_selectedCategory = categoryList.firstWhere((element) => element.name == widget.requirement.productCategoryType);
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
          //typeList.addAll(productTypes.map((e) => e.name).toList());
          productTypes.forEach((element) {typeList.add(element.name);});
          isLoading=false;
          //_selectedProductType = typeList.firstWhere((element) => element.name == widget.requirement.jewelleryType);
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
    setState(() => isLoading = true);

    _edited.customerName = _nameController.text;
    _edited.customerNumber = _noController.text;
    _edited.remark = _remarkController.text;

    FormData formData = FormData.fromMap(_edited.toJson());

    RequirementService.update(formData).then((res){
      Navigator.pop(context, res);
    }).catchError((err){
      _showError(err.toString());
      setState(() {
        isLoading = false;
      });
    }).whenComplete((){
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
