import 'package:flutter/material.dart';

class DialogService {
  static Future<String> confirm(
    BuildContext context,
    String titleText,
    String contentText,
  ) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop('no'),
            ),
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop('yes'),
            ),
          ],
        );
      },
    );
  }

  static Future<String> info(
      BuildContext context,
      String titleText,
      String contentText,
      ) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop('yes'),
            ),
          ],
        );
      },
    );
  }
}
