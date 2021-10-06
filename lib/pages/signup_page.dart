import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonaar_retailer/pages/login_page.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/city_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> states = [], cities = [];

  final _formKey = GlobalKey<FormState>();
  final firmNameController = TextEditingController();
  final nameController = TextEditingController();
  final pincodeController = TextEditingController();
  final mobileController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  Map<String, dynamic> state;
  Map<String, dynamic> city;
  File image;

  bool _showPassword = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    AuthService.logout();

    fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                height: 250,
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 32),

                  // App logo
                  Image(
                    image: AssetImage('images/ic_launcher.png'),
                    width: 80,
                    height: 80,
                  ),

                  SizedBox(height: 16),

                  // App name
                  Text(
                    'Zaveri Bazaar',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    'retailers',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Form
                  Card(
                    margin: EdgeInsets.all(16.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            // Visiting card image
                            buildVisitingCard(),

                            // Full Name
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: nameController,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (v) {
                                  return v.isEmpty
                                      ? 'Please enter your name'
                                      : null;
                                },
                              ),
                            ),

                            // Firm Name
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: firmNameController,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  hintText: 'Office Name',
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator: (v) {
                                  return v.isEmpty
                                      ? 'Please enter your office\'s name'
                                      : null;
                                },
                              ),
                            ),

                            // Firm pincode
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: pincodeController,
                                cursorColor: Theme.of(context).primaryColor,
                                maxLength: 6,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Office pincode',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                                validator: (v) {
                                  if (v.isEmpty)
                                    return 'Please enter office\'s pincode';
                                  else if (v.length != 6 ||
                                      !RegExp(r'[0-9]+').hasMatch(v))
                                    return 'Please enter valid pincode';
                                  else
                                    return null;
                                },
                              ),
                            ),

                            // Mobile number
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: mobileController,
                                cursorColor: Theme.of(context).primaryColor,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Office Whatsapp number',
                                  prefixIcon: Icon(Icons.phone_android),
                                ),
                                validator: (v) {
                                  if (v.isEmpty)
                                    return 'Please enter mobile number';
                                  else if (!RegExp(r'[0-9]{10}').hasMatch(v))
                                    return 'Please enter valid mobile number';
                                  else
                                    return null;
                                },
                              ),
                            ),

                            // State
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField(
                                isDense: true,
                                value: state,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: 'Select state',
                                  prefixIcon: Icon(Icons.location_city),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: DropdownButtonFormField(
                                isDense: true,
                                value: city,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: 'Select city',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                items: cities
                                    .map((c) => DropdownMenuItem(
                                          child: Text(c['name']),
                                          value: c,
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => city = value),
                              ),
                            ),

                            // Username
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: usernameController,
                                cursorColor: Theme.of(context).primaryColor,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                decoration: InputDecoration(
                                  hintText: 'Mobile number (Username)',
                                  helperText: 'Use as username for login',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (v) {
                                  if (v.isEmpty)
                                    return 'Please enter mobile number';
                                  else if (!RegExp(r'[0-9]{10}').hasMatch(v))
                                    return 'Please enter valid mobile number';
                                  else
                                    return null;
                                },
                              ),
                            ),

                            // Password
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                cursorColor: Theme.of(context).primaryColor,
                                obscureText: !this._showPassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: this._showPassword
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() => this._showPassword =
                                          !this._showPassword);
                                    },
                                  ),
                                ),
                                validator: (v) {
                                  return v.isEmpty
                                      ? 'Please enter password'
                                      : null;
                                },
                              ),
                            ),

                            // Confirm password
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                obscureText: true,
                                controller: confirmController,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  hintText: 'Confirm password',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please enter confirm password';
                                  else if (value.length < 6)
                                    return 'Must be atleast 6 characters long';
                                  else if (value != passwordController.text)
                                    return 'Password doesn\'t match';
                                  else
                                    return null;
                                },
                              ),
                            ),

                            // Submit
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(horizontal: 75),
                                onPressed: loading
                                    ? null
                                    : () {
                                        if (_formKey.currentState.validate()) {
                                          signup();
                                        }
                                      },
                                child: loading
                                    ? SizedBox(
                                        height: 20.0,
                                        width: 20.0,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0))
                                    : Text('SIGNUP'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVisitingCard() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(16),
        width: double.infinity,
        height: 120.0,
        color: Colors.grey.shade300,
        child: image == null
            ? Center(child: Text('Pick visiting card image'))
            : Image(image: FileImage(image), fit: BoxFit.cover),
      ),
      onTap: pickImage,
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

    setState(() => image = file);
  }

  fetchStates() async {
    setState(() => loading = true);

    try {
      states = await CityService.getStates();
    } catch (ignored) {}

    setState(() => loading = false);
  }

  signup() async {
    if (city == null) {
      ToastService.error(_scaffoldKey, 'Please select your state and city');
      return;
    }

    final Map<String, dynamic> data = {
      'name': nameController.text,
      'retailer_firm_name': firmNameController.text,
      'pincode': pincodeController.text,
      'mobile': mobileController.text,
      'username': usernameController.text,
      'password': passwordController.text,
      'city_id': city['id'].toString(),
      'visiting_card': await MultipartFile.fromFile(image.path),
    };

    setState(() => loading = true);
    AuthService.signup(data).then((res) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(
            afterSignup: true,
          ),
        ),
      );
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }
}
