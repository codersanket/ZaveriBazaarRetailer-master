import 'package:flutter/material.dart';
import 'package:sonaar_retailer/pages/Repair_edit.dart';
import 'package:sonaar_retailer/pages/Repair_add.dart';

class Repair extends StatefulWidget {
  @override
  _RepairState createState() => _RepairState();
}

class _RepairState extends State<Repair> {
  String initalValue = "Change Status";

  var itemList = ['Unassigned', 'Assigned', 'Received', 'Delivered', 'Cancel'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initalValue = itemList[1].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Repairing Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 30),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 20,left: 15,right: 15),
                  child: Column(
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
                              labelText: 'Customer number'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 45,
                        child: TextFormField(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RepairEdit()));
                            },
                            child: Text("Edit"),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            child: Text("Delete"),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: itemList.map((String value) {
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
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RepairAdd()));
        },
      ),
    );
  }
}
