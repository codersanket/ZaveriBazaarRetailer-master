import 'package:flutter/material.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                height: 250,
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 8),

                  // App name
                  Text(
                    'Reset password',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 8),

                  //
                  Text(
                    'OTP will be sent on your registered mobile number.',
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 32),

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
                            // Username
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                controller: usernameController,
                                cursorColor: Theme.of(context).primaryColor,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                enabled: !otpSent,
                                decoration: InputDecoration(
                                  hintText: 'Mobile number',
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

                            // OTP
                            Visibility(
                              visible: otpSent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  controller: otpController,
                                  cursorColor: Theme.of(context).primaryColor,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    hintText: 'OTP',
                                    prefixIcon: Icon(Icons.message),
                                  ),
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return 'Please enter otp';
                                    } else if (v.length != 6) {
                                      return 'OTP must be 6 digits long';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),

                            // Password
                            Visibility(
                              visible: otpSent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  controller: passwordController,
                                  cursorColor: Theme.of(context).primaryColor,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return 'Please enter otp';
                                    } else if (v.length < 6) {
                                      return 'Must be atleast 6 characters long';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),

                            // Submit
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(horizontal: 75),
                                onPressed: loading ? null : onSubmit,
                                child: loading
                                    ? SizedBox(
                                        height: 20.0,
                                        width: 20.0,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0))
                                    : Text('SUBMIT'),
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

  onSubmit() {
    if (!_formKey.currentState.validate()) return;

    setState(() => loading = true);

    if (!otpSent) {
      AuthService.resetPassword(usernameController.text).then((res) {
        setState(() => otpSent = true);
        ToastService.success(_scaffoldKey, 'OTP sent to your phone');
      }).catchError((err) {
        ToastService.error(_scaffoldKey, err.toString());
      }).whenComplete(() {
        setState(() => loading = false);
      });
    } else {
      AuthService.resetPassword(
        usernameController.text,
        otp: otpController.text,
        password: passwordController.text,
      ).then((res) {
        Navigator.pushReplacementNamed(context, '/main');
      }).catchError((err) {
        ToastService.error(_scaffoldKey, err.toString());
      }).whenComplete(() {
        setState(() => loading = false);
      });
    }
  }
}
