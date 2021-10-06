import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:sonaar_retailer/pages/follows/contacts_page.dart';
//import 'package:sonaar_retailer/pages/contacts_page.dart';
import 'package:sonaar_retailer/pages/login_page.dart';
import 'package:sonaar_retailer/pages/signup-contacts.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/city_service.dart';
//import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class SignupNew2Page extends StatefulWidget {
  @override
  _SignupNew2PageState createState() => _SignupNew2PageState();
}

class _SignupNew2PageState extends State<SignupNew2Page> {
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
  File image = null;
  bool _showPassword = false;
  bool isCityVisible = false;
  bool loading = false;
  List<String> _choices = [
    "Bullion Trader",
    "Manufacturer",
    "Super Wholesaler",
    "Semi Wholesaler",
    "Retailer"
  ];
  List<String> _filters = [];

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
                                  hintText: 'Firm Name',
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator: (v) {
                                  return v.isEmpty
                                      ? 'Please enter your office\'s name'
                                      : null;
                                },
                              ),
                            ),

                            // Username
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                controller: mobileController,
                                cursorColor: Theme.of(context).primaryColor,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                decoration: InputDecoration(
                                  hintText: 'Mobile number',
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

                            // Mobile number
                            /*Padding(
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
                            ),*/

                            // Firm pincode
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextFormField(
                                /*onFieldSubmitted: (value) {
                                  print("Pin Code Entered = " + value);
                                  fetchCity(int.parse(value));
                                  //setState(() => fetchCity(int.parse(value)));
                                },*/
                                onChanged: (value) {
                                  if (value.length == 6) {
                                    print("onChanged " + value);
                                    fetchCity(int.parse(value));
                                  }
                                },
                                controller: pincodeController,
                                cursorColor: Theme.of(context).primaryColor,
                                maxLength: 6,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Pin Code',
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

                            // State
                            Visibility(
                              visible: isCityVisible,
                              child: Column(
                                children: [
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
                                ],
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
                                keyboardType: TextInputType.number,
                                cursorColor: Theme.of(context).primaryColor,
                                obscureText: !this._showPassword,
                                decoration: InputDecoration(
                                  hintText: 'Login Pin',
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
                                  if (v.isEmpty)
                                    return 'Please enter confirm pin';
                                  else if (v.length < 4)
                                    return 'Must be atleast 4 characters long';
                                  else
                                    return null;
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
                                keyboardType: TextInputType.number,
                                controller: confirmController,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Pin',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please enter confirm pin';
                                  else if (value.length < 4)
                                    return 'Must be atleast 4 characters long';
                                  else if (value != passwordController.text)
                                    return 'pin doesn\'t match';
                                  else
                                    return null;
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Dealer Type",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            //Dealer Type
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Wrap(
                                        children: companyPosition.toList(),
                                      ),
                                    ])),

                            /*Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 8.0,
                              ),
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                children: List<Widget>.generate(
                                    _choices.length, // place the length of the array here
                                        (int index) {
                                      return FilterChip(
                                        showCheckmark: false,
                                        backgroundColor: Colors.grey[200],
                                        label: Text(
                                          _choices[index],
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        selected: _filters.contains(_choices[index]),
                                        selectedColor: Colors.grey[500],
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              _filters.add(_choices[index]);
                                            } else {
                                              _filters.removeWhere((String name) {
                                                return name == _choices[index];
                                              });
                                            }
                                          });
                                        },
                                      );
                                    }
                                ).toList(),
                                  ),
                            ),*/

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

  Iterable<Widget> get companyPosition sync* {
    for (String company in _choices) {
      yield Padding(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          showCheckmark: false,
          backgroundColor: Colors.grey[200],
          label: Text(
            company,
            style: TextStyle(fontSize: 12),
          ),
          selected: _filters.contains(company),
          selectedColor: Colors.grey[500],
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _filters.add(company);
              } else {
                _filters.removeWhere((String name) {
                  return name == company;
                });
              }
            });
          },
        ),
      );
    }
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

  fetchCity(int pinCode) async {
    setState(() => loading = true);
    try {
      Map<String, dynamic> city1 =
          await CityService.getCityFromPinCode(pinCode);
      setState(() {
        for (var i = 0; i < states.length; i++) {
          if (city1['state'] == states[i]['name']) {
            state = states[i];
            cities = state['cities'];
            for (var i = 0; i < cities.length; i++) {
              if (city1['id'] == cities[i]['id']) {
                city = cities[i];
                //isCityVisible = true;
                break;
              }
            }
            loading = false;
          }
        }
      });
    } catch (ignored) {
      print(ignored.toString());
      setState(() {
        isCityVisible = true;
      });
    }
  }

  signup() async {
    if (image == null) {
      ToastService.error(_scaffoldKey, 'Please pick visiting card');
      return;
    }

    if (city == null) {
      ToastService.error(_scaffoldKey, 'Please select your state and city');
      return;
    }

    if (_filters.isEmpty) {
      ToastService.error(_scaffoldKey, 'Please select dealer type');
      return;
    } else if (_filters.length > 2) {
      ToastService.error(
          _scaffoldKey, 'Please select upto 3 dealer types only');
      return;
    }

    final Map<String, dynamic> data = {
      'name': nameController.text,
      'retailer_firm_name': firmNameController.text,
      'pincode': pincodeController.text,
      'mobile': mobileController.text,
      'username': mobileController.text,
      'password': passwordController.text,
      'city_id': city['id'].toString(),
      'dealer_type': _filters.join(', '),
      'visiting_card': await MultipartFile.fromFile(image.path),
    };
    print("/////////////////////////////////////////////////////////");
    print(data);

    setState(() => loading = true);
    AuthService.quickSignup(data).then((res) {
      print("/////////////////////////////////////////////////////////");
      print(res);
      final Map<String, dynamic> dataVerifyOTP = {
        'mobile': mobileController.text,
        'otp': '00000',
      };
      AuthService.verifyOTP(dataVerifyOTP).then((res) {
        print("verifyOTP Success");
      }).catchError((err) {
        print("verifyOTP Error:" + err.toString());
      });

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => LoginPage(
      //       afterSignup: true,
      //     ),
      //   ),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ContactsPage(),
        ),
      );
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }
}
