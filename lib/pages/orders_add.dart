import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddOrder extends StatefulWidget {
  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  DateTime selectedDate = DateTime.now();
  File _image;
  List images = [];
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _datetimeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Order"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 45,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Customer Name',
                        prefixIcon: Icon(Icons.person)),
                    validator: (v) {
                      return v.isEmpty ? 'Please enter Name' : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 45,
                  child: TextFormField(
                    controller: _nameController,
                    //maxLength: 10,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone)),
                    validator: (v) {
                      return v.isEmpty ? 'Please enter number' : v.length < 10 ? "Enter valid number": null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 45,
                  child: TextFormField(
                    controller: _datetimeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Order date',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    validator: (v) {
                      return v.isEmpty ? 'Please select Date' : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Material(
                //   //color: Colors.white,
                //   child: ListTile(
                //     onTap: pickImage,
                //     trailing: Icon(Icons.image, color: Colors.blue),
                //     title: Text('Photo'),
                //     subtitle: _image == null
                //         ? null
                //         : Container(
                //             padding: EdgeInsets.only(top: 8.0),
                //             height: 200.0,
                //             child: Image.file(_image, fit: BoxFit.cover),
                //           ),
                //   ),
                // ),
                Column(
                  children: [
                    Padding(padding: const EdgeInsets.all(10.0),child: Text("Add order details"),),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 35,
                                child: TextFormField(
                                controller: _nameController,
                                //maxLength: 10,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Product name',
                                  //prefixIcon: Icon(Icons.phone)
                                  ),
                                validator: (v) {
                                  return v.isEmpty ? 'Please enter product name': null;
                                },
                              ),
                          ),
                            ),
                          
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 35,
                                child: TextFormField(
                                controller: _nameController,
                                keyboardType : TextInputType.number,
                                //maxLength: 10,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Weight',
                                ),
                                validator: (v) {
                                  return v.isEmpty ? 'Please enter weight' : null;
                                },
                              ),
                          ),
                            ),
                          
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 35,
                                child: TextFormField(
                                controller: _nameController,
                                //maxLength: 10,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Melting',
                                ),
                                validator: (v) {
                                  return v.isEmpty ? 'Please enter melting' : null;
                                },
                              ),
                          ),
                            ),
                            
                            
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 45,
                  child: TextFormField(
                    controller: _remarkController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Remark',
                    ),
                    validator: (v) {
                      return v.isEmpty ? 'Please enter Remark data' : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 45,
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Weight',
                    ),
                    validator: (v) {
                      return v.isEmpty ? 'Please enter Weight' : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(horizontal: 75),
                    child: Text("Submit"),
                    onPressed: loading
                        ? null
                        : () {
                      if (_formKey.currentState.validate()) {
                       print(_nameController.text);
                       print(_datetimeController.text);
                       print(_remarkController.text);
                       print(_weightController.text);
                      }
                      // _idController.clear();
                      // _nameController.clear();
                      // _datetimeController.clear();
                      // _remarkController.clear();
                      // _weightController.clear();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
        _datetimeController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    //_datetimeController.text=selectedDate.toString().DateFormat("yyyy-MM-dd").format(selectedDate);
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

  // Widget buildGridView() {
  //   return GridView.builder(
  //     itemCount: images.length + 1,
  //     padding: EdgeInsets.only(bottom: 70),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       childAspectRatio: 0.7,
  //       crossAxisSpacing: 2,
  //       mainAxisSpacing: 2,
  //     ),
  //     itemBuilder: (context, i) {
  //       if (i == images.length) return buildGridAddItem(context);
  //       return buildGridProductItem(context, i);
  //     },
  //   );
  // }

  // Widget buildGridAddItem(BuildContext context) {
  //   final isMax = images.length == 10;
  //   return GridTile(
  //     child: GestureDetector(
  //       onTap: isMax ? null : () => pickImages(),
  //       child: Container(
  //         color: Colors.grey.shade300,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Icon(isMax ? Icons.error_outline : Icons.add_photo_alternate),
  //             SizedBox(height: 4),
  //             Text(
  //               isMax ? 'Max 10 images\nare allowed' : 'Add images',
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
