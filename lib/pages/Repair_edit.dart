import 'package:flutter/material.dart';


class RepairEdit extends StatefulWidget {
  @override
  _RepairEditState createState() => _RepairEditState();
}

class _RepairEditState extends State<RepairEdit> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _noController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 30),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 15, right: 15),
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Customer name'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: _noController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Customer number'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Issue date'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 200,
                        width: 200,
                        child: Image.network(
                          "https://wi.wallpapertip.com/wsimgs/62-627190_gold-jewellery-wallpaper.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: () {
                          print(_nameController.text);
                          print(_noController.text);
                          print(_dateController.text);
                        },
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
