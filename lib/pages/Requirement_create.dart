import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intent/category.dart';

enum SingingCharacter { lafayette, jefferson }

class CreateRequirement extends StatefulWidget {
  @override
  _CreateRequirementState createState() => _CreateRequirementState();
}

class _CreateRequirementState extends State<CreateRequirement> {
  SingingCharacter _character = SingingCharacter.lafayette;
  String initalValue;
  File _image;
  var itemList = ['Gold', 'Sliver', 'Diamond', 'Platinum'];
  var list = ['Finger Ring', 'Bangles', 'Bracelet'];
  var statusList = ['Open', 'Close'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Requirement"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 35, left: 10, right: 10, bottom: 30),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Customer name'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Customer Number'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Requirement of",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Old",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w400),
                              ),
                              Radio(
                                value: SingingCharacter.lafayette,
                                groupValue: _character,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    _character = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "New",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w400),
                              ),
                              Radio(
                                value: SingingCharacter.jefferson,
                                groupValue: _character,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    _character = value;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 55,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select jewellery type'),
                          value: initalValue,
                          onChanged: (String newValue) {
                            setState(() {
                              initalValue = newValue;
                            });
                          },
                          items: itemList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 55,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select Product category type'),
                          value: initalValue,
                          onChanged: (String newValue) {
                            setState(() {
                              initalValue = newValue;
                            });
                          },
                          items: list.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Material(
                        //color: Colors.white,
                        child: ListTile(
                          onTap: pickImage,
                          trailing: Icon(Icons.image, color: Colors.blue),
                          title: Text('Photo'),
                          subtitle: _image == null
                              ? null
                              : Container(
                                  padding: EdgeInsets.only(top: 8.0),
                                  height: 200.0,
                                  child: Image.file(_image, fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Remark'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 55,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select Status'),
                          value: initalValue,
                          onChanged: (String newValue) {
                            setState(() {
                              initalValue = newValue;
                            });
                          },
                          items: statusList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: RaisedButton(
                          onPressed: () {},
                          child: Text('Submit'),
                        ),
                      )
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

    // Directory tempDir = await getTemporaryDirectory();
    // String targetPath = tempDir.path + randomAlpha(5);
    // file = await FlutterImageCompress.compressAndGetFile(
    //   file.absolute.path,
    //   targetPath,
    //   quality: 80,
    // );
    setState(() => _image = file);
  }
}
