import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  final String url, whatsNew;

  const UpdatePage({
    Key key,
    @required this.url,
    @required this.whatsNew,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/ic_launcher.png',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Text(
                'New update.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 48),
              Text(widget.whatsNew),
              SizedBox(height: 64),
              RaisedButton(
                onPressed: () => launch(widget.url),
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('UPDATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
