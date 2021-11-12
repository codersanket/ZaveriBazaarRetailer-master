import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';

class Repair extends StatefulWidget {
  @override
  _RepairState createState() => _RepairState();
}

class _RepairState extends State<Repair> {
  DateTime selectedDate = DateTime.now();
  File _image;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _datetimeController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Repair"),
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
                    controller: _idController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Repair Id'),
                  ),
                ),
                SizedBox(height: 20),
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
                    controller: _datetimeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Repair date',
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
                       print(_idController.text,);
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
}
