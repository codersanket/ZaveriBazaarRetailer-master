import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sonaar_retailer/pages/Requirement_create.dart';
import 'package:sonaar_retailer/pages/Requirement_edit.dart';

enum SingingCharacter { lafayette, jefferson }

class ViewRequirement extends StatefulWidget {
  @override
  _ViewRequirementState createState() => _ViewRequirementState();
}

class _ViewRequirementState extends State<ViewRequirement> {
  SingingCharacter _character = SingingCharacter.lafayette;
  String initalValue = 'Status';
  File _image;
  var statusList = ['Open', 'Close'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Requirement'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, left: 10, right: 10, bottom: 40),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 25, bottom: 25, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Customer Name:',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            'Karan Patel',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Customer Number:',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '1234567892',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      // SizedBox(height: 20),
                      // Text(
                      //   "Requirement of",
                      //   style: TextStyle(
                      //       fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      // Row(
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           "Old",
                      //           style: TextStyle(
                      //               fontSize: 17, fontWeight: FontWeight.w400),
                      //         ),
                      //         Radio(
                      //           value: SingingCharacter.lafayette,
                      //           groupValue: _character,
                      //           onChanged: (SingingCharacter value) {
                      //             setState(() {
                      //               _character = value;
                      //             });
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //     Row(
                      //       children: [
                      //         Text(
                      //           "New",
                      //           style: TextStyle(
                      //               fontSize: 17, fontWeight: FontWeight.w400),
                      //         ),
                      //         Radio(
                      //           value: SingingCharacter.jefferson,
                      //           groupValue: _character,
                      //           onChanged: (SingingCharacter value) {
                      //             setState(() {
                      //               _character = value;
                      //             });
                      //           },
                      //         ),
                      //       ],
                      //     )
                      //   ],
                      // ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text('jewellery type:',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            'Gold',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text('Category type:',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            'Finger Ring',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 150,width: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.network(
                              'https://i.pinimg.com/originals/fa/e7/b9/fae7b9d5e63f4de1af63dc3726b4a567.jpg'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text('Remark:',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            'Pure Gold Finger Ring.',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),

                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditRequirement()));
                            },
                            child: Text('Edit'),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            child: Text('Delete'),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: statusList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              hint: Text(initalValue),
                              // value:  initalValue,
                              onChanged: (String newValue) {
                                setState(() {
                                  initalValue = newValue;
                                });
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateRequirement()));
        },
      ),
    );
  }
}
