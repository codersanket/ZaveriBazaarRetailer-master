import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/services/dialog_service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/user_contact_service.dart';

class AllContactsPage extends StatefulWidget {
  @override
  _AllContactsPageState createState() => _AllContactsPageState();
}

class _AllContactsPageState extends State<AllContactsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  Map<String, dynamic> params = {'page': 1, 'per_page': 50};
  var isLoading = false, isSyncing = false, totalPage = 0, rowCount = 0;
  double progress = 0;
  String deviceId;

  List<UserContact> _contacts = [];

  // search
  final searchController = TextEditingController();

  @override
  void initState() {
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
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('All contacts'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: syncContacts,
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            // Search
            Card(
              margin: EdgeInsets.all(8.0),
              elevation: 2,
              child: TextFormField(
                onFieldSubmitted: searchContacts,
                textInputAction: TextInputAction.search,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                      searchContacts(null);
                    },
                    icon: Icon(Icons.clear, size: 18),
                  ),
                ),
              ),
            ),

            // Contacts
            Expanded(
              child: Stack(
                children: <Widget>[
                  Visibility(
                    visible: !isSyncing,
                    child: _buildListView(),
                  ),
                  Visibility(
                    visible: isLoading || isSyncing,
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(strokeWidth: 2.0)
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      "Searching for your contacts available on Zaveri Bazaar..."),
                                  SizedBox(height: 16.0),
                                  LinearProgressIndicator(value: progress),
                                  SizedBox(height: 8.0),
                                  Text((progress * 100).round().toString() +
                                      "%"),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Visibility(
                    visible: !isLoading && !isSyncing && _contacts.length == 0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'No contacts found!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.0, height: 1.3),
                            ),
                            SizedBox(height: 16),
                            FlatButton(
                              onPressed: syncContacts,
                              child: Text('REFRESH'),
                              color: Theme.of(context).accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _contacts.length,
      separatorBuilder: (ctx, i) => Divider(height: 0),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.mobile),
          trailing: FlatButton(
            disabledTextColor: Colors.grey.shade500,
            child: Text(
              getActionText(contact),
              style: TextStyle(letterSpacing: 1),
            ),
            color: Theme.of(context).accentColor,
            onPressed: contact.canFollow || contact.canInvite
                ? () async {
                    if (contact.canFollow) {
                      _followWholesaler(contact, index);
                    } else {
                      _inviteWholesaler(contact);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }

  String getActionText(UserContact contact) {
    if (contact.canInvite) return 'INVITE';
    if (contact.canFollow) return 'FOLLOW';
    return 'FOLLOWING';
  }

  void syncContacts() async {
    bool granted = await _checkPermissions();
    if (!granted) return;

    setState(() {
      isSyncing = true;
      progress = 0;
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
            name: pc.displayName, mobile: mobile, deviceId: deviceId));
      }
    }

    if (newContacts.length > 0) {
      try {
        await UserContactService.sync(newContacts, (int sent, int total) {
          setState(() => progress = sent / total);
        });
      } catch (ignored) {}
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('contacts_synced', true);

    setState(() => isSyncing = false);

    fetchContacts();
  }

  void _followWholesaler(UserContact contact, int index) {
    setState(() => isLoading = true);
    FollowService.create(mobile: contact.mobile).then((res) {
      ToastService.success(
          _scaffoldKey, 'You are now following ${contact.name}!');

      setState(() {
        isLoading = false;
        contact.canFollow = false;
      });

      // widget.onChange();
    }).catchError((err) {
      ToastService.error(_scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void _inviteWholesaler(UserContact contact) {
    Share.share(
        'Join Zaveri Bazaar, download app now: https://zaveribazaar.co.in');
  }

  searchContacts(String text) {
    params['query'] = text;
    params['page'] = 1;
    fetchContacts();
  }

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
      return _checkPermissions();
    } else {
      openSettings();
    }

    return false;
  }

  openSettings() async {
    final result = await DialogService.confirm(context, 'Allow contacts access',
        'Please open permission settings for this app and allow Contacts permission to see which contacts are available on Zaveri Bazaar app.');

    if (result != 'yes') {
      Navigator.pop(context);
      return;
    }

    await PermissionHandler().openAppSettings();
    Navigator.pop(context);
  }

  String normalizeMobileNumber(String mobile) {
    if (mobile == null || mobile.length < 10) return null;

    mobile = mobile.replaceAll(new RegExp(r"[^\d]+"), "");
    if (mobile.length > 10) mobile = mobile.substring(mobile.length - 10);

    return mobile;
  }
}
