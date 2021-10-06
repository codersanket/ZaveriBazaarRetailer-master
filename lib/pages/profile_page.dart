import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/user.dart';
import 'package:sonaar_retailer/pages/profile_edit.dart';
import 'package:sonaar_retailer/pages/widgets/drawer_widget.dart';
import 'package:sonaar_retailer/services/auth_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/pages/image_view.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User user;
  String error;

  AuthService authService;

  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    authService = new AuthService(context);

    authService.profile().then((res) {
      setState(() {
        user = res;
        print(user);
      });
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zaveri Bazaar', style: TextStyle(fontFamily: 'serif')),
      ),
      key: scaffoldKey,
      drawer: DrawerWidget(scaffoldKey: scaffoldKey),
      body: user == null
          ? Center(child: CircularProgressIndicator(strokeWidth: 2.0))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Details
                  Card(
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        // Name
                        GestureDetector(
                          child: ListTile(
                            leading: Align(
                              child: user.thumbUrl != null
                                  ? Hero(
                                      tag: "profile_pic",
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          user.thumbUrl,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.person, size: 36),
                              alignment: Alignment.center,
                              widthFactor: 1,
                            ),
                            title: Text(user.name),
                            subtitle: Text('@${user.username}'),
                          ),
                          onTap: user.imageUrl != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImageView(
                                        imageUrl: user.imageUrl,
                                        heroTag: 'profile_pic',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // Mobile number
                        ListTile(
                          title: Text(user.mobile ?? 'NA'),
                          leading: Icon(Icons.phone),
                          subtitle: Text('Whatsapp number'),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        //retailer_firm_name
                        ListTile(
                          title: Text(user.retailerFirmName ??
                              'Office name not available'),
                          subtitle: Text('Office name'),
                          leading: Icon(Icons.business),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // Address
                        ListTile(
                          title: Text(user.getExtraValue('address') ?? '-'),
                          leading: Icon(Icons.location_city),
                          subtitle: Text('Address'),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // City
                        ListTile(
                          title: Text(user.city ?? 'City not available'),
                          leading: Icon(Icons.location_city),
                          subtitle:
                              Text(user.pincode ?? 'Pincode not available'),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // Establishment
                        ListTile(
                          title: Text(user.getExtraValue('estd') ?? '-'),
                          leading: Icon(Icons.calendar_today),
                          subtitle: Text('Year of establishment'),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // GST Number
                        ListTile(
                          title: Text(user.getExtraValue('gst') ?? '-'),
                          leading: Icon(Icons.insert_drive_file),
                          subtitle: Text('GST Number'),
                        ),

                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),
                      ],
                    ),
                  ),

                  // Actions
                  Card(
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        // Edit profile
                        ListTile(
                          onTap: editProfile,
                          leading: Icon(Icons.edit, color: Colors.teal),
                          trailing: Icon(Icons.chevron_right),
                          title: Text('Edit profile'),
                        ),
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // Change password
                        ListTile(
                          onTap: () async {
                            var result =
                                await _showChangePasswordDialog(context);
                            if (result == 'success')
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Password updated!'),
                              ));
                          },
                          leading: Icon(Icons.lock, color: Colors.blue),
                          trailing: Icon(Icons.chevron_right),
                          title: Text('Change password'),
                        ),
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade300),

                        // Logout
                        ListTile(
                          onTap: () async {
                            var result = await _showLogoutDialog();
                            if (result == 'success') {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  '/login', (Route<dynamic> route) => false);
                            }
                          },
                          leading: Icon(Icons.exit_to_app, color: Colors.red),
                          trailing: Icon(Icons.chevron_right),
                          title: Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  editProfile() async {
    final result = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditPage()),
    );
    if (result != null) {
      setState(() => user = result);
      ToastService.success(scaffoldKey, 'Profile updated successfully!');
    }
  }

  Future<String> _showChangePasswordDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change password'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Current password
                  TextFormField(
                    obscureText: true,
                    controller: oldPasswordController,
                    decoration: InputDecoration(hintText: 'Current password'),
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Please enter current password';
                      else if (value.length < 6)
                        return 'Must be atleast 6 characters long';
                      else
                        return null;
                    },
                  ),

                  SizedBox(height: 16.0),

                  // New password
                  TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(hintText: 'New password'),
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Please enter new password';
                      else if (value.length < 6)
                        return 'Must be atleast 6 characters long';
                      else
                        return null;
                    },
                  ),

                  SizedBox(height: 16.0),

                  // Confirm password
                  TextFormField(
                    obscureText: true,
                    controller: confirmController,
                    decoration: InputDecoration(hintText: 'Confirm password'),
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
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop('cancelled');
              },
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Update'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _changePassword(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _changePassword(BuildContext context) {
    AuthService.updatePassword(
      oldPasswordController.text,
      passwordController.text,
    ).then(
      (res) {
        Navigator.of(context).pop('success');
      },
    ).catchError((err) {
      if (mounted)
        setState(() {
          error = err;
        });
    });
  }

  Future<String> _showLogoutDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop('cancelled');
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop('success');
              },
            ),
          ],
        );
      },
    );
  }
}
