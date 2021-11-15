import 'dart:io';

import 'package:flutter/material.dart';

enum SingingCharacter { lafayette, jefferson }

class EditRequirement extends StatefulWidget {
  @override
  _EditRequirementState createState() => _EditRequirementState();
}

class _EditRequirementState extends State<EditRequirement> {
  SingingCharacter _character = SingingCharacter.lafayette;
  String initalValue = 'Status';
  File _image;
  var statusList = ['Open', 'Close'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Requirement'),
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
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'jewellery type'),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Category type'),
                        ),
                      ),
                      SizedBox(height: 15),
                      Material(
                        //color: Colors.white,
                        child: ListTile(
                          // onTap: pickImage,
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
                        height: 45,
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Status'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                          child: RaisedButton(
                        onPressed: () {},
                        child: Text('Submit'),
                      ))
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
