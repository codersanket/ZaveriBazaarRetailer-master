import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonaar_retailer/main.dart';
import 'package:sonaar_retailer/pages/reset_pass2.dart';
//import 'package:sonaar_retailer/pages/reset_password_page.dart';
import 'package:sonaar_retailer/pages/signup-contacts.dart';
import 'package:sonaar_retailer/pages/signup_new2_page.dart';
import 'package:sonaar_retailer/pages/signup_new_page.dart';
import 'package:sonaar_retailer/pages/signup_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final bool afterSignup;

  final List<String> pathSegments;

  const LoginPage({Key key, this.afterSignup = false, this.pathSegments})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    AuthService.logout();

    /*if (widget.afterSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastService.info(
          _scaffoldKey,
          'Signup complete! We are reviewing your account. Please login after 24 hours.',
          duration: Duration(minutes: 1),
        );
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
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
                              // Username
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  controller: usernameController,
                                  cursorColor: Theme.of(context).primaryColor,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
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

                              // Password
                              Padding(
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
                                    return v.isEmpty
                                        ? 'Please enter password'
                                        : null;
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
                                          if (_formKey.currentState
                                              .validate()) {
                                            _login(usernameController.text,
                                                passwordController.text);
                                          }
                                        },
                                  child: loading
                                      ? SizedBox(
                                          height: 20.0,
                                          width: 20.0,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.0))
                                      : Text('LOGIN'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Forgot password
                    FlatButton(
                      child: Text('Forgot password? Reset here'),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: resetPassword,
                    ),

                    // Signup
                    FlatButton(
                      child: Text('New to Zaveri Bazaar? SIGNUP HERE'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // builder: (_) => SignupPage(),
                            // builder: (_) => SignupNewPage(),
                            builder: (_) => SignupNew2Page(),
                            //builder: (_) => ContactsPage(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  resetPassword() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => ResetPasswordPage()),
    // );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResetPasswordPage()),
    );
  }

  _login(String username, String password) {
    setState(() => loading = true);

    AuthService.login(username, password).then((res) async {
      Future.delayed(Duration(seconds: 2), () async {
        setState(() => loading = false);
        // await navigatorKey.currentState
        //     .push(MaterialPageRoute(builder: ));
        if (widget.pathSegments != null) {
          navigatorKey.currentState.pushReplacement(MaterialPageRoute(
              builder: (_) =>
                  WholesalerViewPage(wholesalerId: widget.pathSegments.last)));
        } else
          Navigator.pushReplacementNamed(context, '/main');
      });
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }
}
