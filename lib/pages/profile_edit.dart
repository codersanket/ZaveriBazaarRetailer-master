import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/city_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  User user;
  File image;

  List<dynamic> states = [], cities = [];

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final pincodeController = TextEditingController();
  final firmNameController = TextEditingController();
  final addressController = TextEditingController();
  final estdController = TextEditingController();
  final gstController = TextEditingController();
  Map<String, dynamic> state;
  Map<String, dynamic> city;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    AuthService.getUser().then((res) {
      setState(() => user = res);
      nameController.text = res.name;
      mobileController.text = res.mobile;
      firmNameController.text = res.retailerFirmName;
      if (res.pincode != null) pincodeController.text = res.pincode.toString();

      if (res.extras != null) {
        addressController.text = res.extras['address'];
        estdController.text = res.extras['estd'];
        gstController.text = res.extras['gst'];
      }

      fetchStates();
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Edit profile')),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: user == null
              ? CircularProgressIndicator(strokeWidth: 2.0)
              : Column(
                  children: <Widget>[
                    // Image
                    Container(
                      margin: EdgeInsets.all(16),
                      width: 120.0,
                      height: 120.0,
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundImage: image == null
                              ? (user.thumbUrl == null
                                  ? AssetImage('images/placeholder.png')
                                  : CachedNetworkImageProvider(user.thumbUrl))
                              : FileImage(image),
                        ),
                        onTap: () async {
                          final i = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          setState(() => image = i);
                        },
                      ),
                    ),

                    // Name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: nameController,
                        cursorColor: Theme.of(context).primaryColor,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          return v.isEmpty ? 'Please enter name' : null;
                        },
                      ),
                    ),

                    // mobile
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: mobileController,
                        cursorColor: Theme.of(context).primaryColor,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Whatsapp mobile number',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          return v.isEmpty
                              ? 'Please enter mobile number'
                              : null;
                        },
                      ),
                    ),

                    // address
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: addressController,
                        cursorColor: Theme.of(context).primaryColor,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          return null;
                        },
                      ),
                    ),

                    // Pincode
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: pincodeController,
                        cursorColor: Theme.of(context).primaryColor,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Pincode',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          if (v.isEmpty)
                            return 'Please enter pincode';
                          else if (v.length != 6 ||
                              !RegExp(r'[0-9]+').hasMatch(v))
                            return 'Please enter valid pincode';
                          else
                            return null;
                        },
                      ),
                    ),

                    // State
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField(
                        isDense: true,
                        value: state,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select state',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: states
                            .map((s) => DropdownMenuItem(
                                  child: Text(s['name']),
                                  value: s,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (state != value) city = null;
                            state = value;
                            cities = state['cities'];
                          });
                        },
                      ),
                    ),

                    // City
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField(
                        isDense: true,
                        value: city,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select city',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: cities
                            .map((c) => DropdownMenuItem(
                                  child: Text(c['name']),
                                  value: c,
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => city = value),
                      ),
                    ),

                    // Firm name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: firmNameController,
                        cursorColor: Theme.of(context).primaryColor,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Office Name',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          return v.isEmpty ? 'Please enter office name' : null;
                        },
                      ),
                    ),

                    // Established
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: estdController,
                        cursorColor: Theme.of(context).primaryColor,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Year of establishment',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          if (v.isEmpty)
                            return null;
                          else if (v.length != 4 ||
                              !RegExp(r'^(18|19|20)\d{2}$').hasMatch(v))
                            return 'Please enter valid year';
                          else
                            return null;
                        },
                      ),
                    ),

                    // GST
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: gstController,
                        cursorColor: Theme.of(context).primaryColor,
                        maxLength: 15,
                        decoration: InputDecoration(
                          labelText: 'GST number',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) {
                          if (v.isEmpty)
                            return null;
                          else if (v.length != 15)
                            return 'Please enter valid gst number';
                          else
                            return null;
                        },
                      ),
                    ),

                    // Submit
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RaisedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (formKey.currentState.validate()) {
                                  updateProfile(
                                      nameController.text,
                                      mobileController.text,
                                      pincodeController.text,
                                      firmNameController.text);
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.0))
                            : Text('UPDATE'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  updateProfile(
      String name, String mobile, String pincode, String firmName) async {
    setState(() => isLoading = true);

    final Map<String, dynamic> data = {
      'name': name,
      'mobile': mobile,
      'pincode': pincode,
      'retailer_firm_name': firmName,
      'extras': jsonEncode({
        'address': addressController.text,
        'estd': estdController.text,
        'gst': gstController.text,
      }),
    };

    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path);
    }

    if (city != null) {
      data['city_id'] = city['id'];
    }

    FormData formData = FormData.fromMap(data);

    AuthService.update(formData).then((res) {
      Navigator.pop(context, res);
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  fetchStates() async {
    setState(() => isLoading = true);

    try {
      states = await CityService.getStates();

      if (user.cityId != null) {
        state = states.firstWhere((s) {
          city = s['cities'].firstWhere(
            (c) => c['id'] == int.parse(user.cityId),
            orElse: () => null,
          );
          return city != null;
        }, orElse: () => null);

        if (state != null) cities = state['cities'];
      }
    } catch (ignored) {}

    setState(() => isLoading = false);
  }
}
