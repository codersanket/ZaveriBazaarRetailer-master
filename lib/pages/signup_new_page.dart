import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonaar_retailer/pages/login_page.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/city_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class SignupNewPage extends StatefulWidget {
  @override
  _SignupNewPageState createState() => _SignupNewPageState();
}

class _SignupNewPageState extends State<SignupNewPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _showPassword = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    AuthService.logout();

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
                                  hintText: 'Mobile Number',
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

  signup() async {

    final Map<String, dynamic> data = {
      'name': nameController.text,
      'mobile': mobileController.text,
      'password': passwordController.text,
    };

    setState(() => loading = true);
    AuthService.quickSignup(data).then((res) {

      final Map<String, dynamic> dataVerifyOTP = {
        'mobile': mobileController.text,
        'otp': '00000',
      };
      AuthService.verifyOTP(dataVerifyOTP).then((res) {
        print("verifyOTP Success");
      }).catchError((err) {
        print("verifyOTP Error:" + err.toString());
      });

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
