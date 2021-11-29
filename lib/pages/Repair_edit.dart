import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sonaar_retailer/models/repairs.dart';
import 'package:sonaar_retailer/services/repair_service.dart';


class RepairEdit extends StatefulWidget {
  final Repairs repair;
  RepairEdit({this.repair});
  @override
  _RepairEditState createState() => _RepairEditState();
}

class _RepairEditState extends State<RepairEdit> {

  Repairs _edited;
  bool isLoading = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _noController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _edited = widget.repair;
    _nameController.text = widget.repair.customerName;
    _noController.text = widget.repair.customerNumber;
    _dateController.text = widget.repair.inwardDate;
    _remarkController.text = widget.repair.remark ?? null;
    _weightController.text = widget.repair.weight.toString() ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 30),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
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
                                  labelText: 'Customer name',
                                  //hintText: widget.repair.customerName
                                  ),
                              validator: (v) {
                                return v.isEmpty ? 'Please enter Name' : null;
                            },
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 45,
                            child: TextFormField(
                              controller: _noController,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                 return v.isEmpty ? 'Please select customer contact' : v.length > 12 || v.length < 10 ? 'Please enter valid number': null;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Customer number',
                                  //hintText: widget.repair.customerNumber
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45,
                                  child: TextFormField(
                                    controller: _dateController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Issue date',
                                    ),
                                    validator: (v) {
                                      return v.isEmpty ? 'Please select Date' : null;
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: (){_selectDate(context);},
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                  )
                              ),

                            ],
                          ),
                          // Container(
                          //   height: 45,
                          //   child: TextFormField(
                          //     controller: _dateController,
                          //     validator: (v) {
                          //       return v.isEmpty ? 'Please select Date' : null;
                          //     },
                          //     decoration: InputDecoration(
                          //         border: OutlineInputBorder(),
                          //         labelText: 'Issue date',
                          //         //hintText: widget.repair.inwardDate
                          //         ),
                          //   ),
                          // ),
                          SizedBox(height: 20),
                          // Container(
                          //   height: 200,
                          //   width: 200,
                          //   child: Image.network(
                          //     "https://wi.wallpapertip.com/wsimgs/62-627190_gold-jewellery-wallpaper.jpg",
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                          ConstrainedBox(
                            constraints:  BoxConstraints(
                              maxWidth: 200,
                              maxHeight: 200,
                              ),
                            child: widget.repair.thumbUrl == null
                              ? null
                                : CachedNetworkImage(
                                imageUrl: widget.repair.thumbUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                errorWidget: (c, u, e) => Image.asset(
                                  "images/ic_launcher.png",
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
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
                                  //hintText: widget.repair.inwardDate
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 45,
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Weight',
                                  //hintText: widget.repair.inwardDate
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                          RaisedButton(
                            onPressed: () {
                              // print(_nameController.text);
                              // print(_noController.text);
                              // print(_dateController.text);
                              if (_formKey.currentState.validate()) {
                                _submit();
                              }
                            },
                            child: Text("Submit"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
          Visibility(
            visible: isLoading,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2.0)),
          ),
        ],
        
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
        _dateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    //_datetimeController.text=selectedDate.toString().DateFormat("yyyy-MM-dd").format(selectedDate);
  }
  _submit() async{
    setState(() => isLoading = true);

    _edited.customerName = _nameController.text;
    _edited.customerNumber = _noController.text;
    _edited.inwardDate = _dateController.text;
    _edited.remark = _remarkController.text;
    _edited.weight = int.parse(_weightController.text);

    FormData formData = FormData.fromMap(_edited.toJson());

    RepairService.update(formData).then((res){
      Navigator.pop(context, res);
    }).catchError((err){
      _showError(err.toString());
      setState(() {
        isLoading = false;
      });
    }).whenComplete((){
      setState(() {
        isLoading = false;
      });
    });

  }

  void _showError(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
    ));
  }

}
