import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
import 'package:sonaar_retailer/services/toast_service.dart';

class WholesalerRatingEditForm extends StatefulWidget {
  final WholesalerRating wholesalerEdit;

  const WholesalerRatingEditForm(this.wholesalerEdit);

  @override
  _WholesalerRatingEditFormState createState() =>
      _WholesalerRatingEditFormState(wholesalerEdit);
}

class _WholesalerRatingEditFormState extends State<WholesalerRatingEditForm> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final WholesalerRating wholesalerEdit;

  bool isLoading = false;

  File image;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();

  _WholesalerRatingEditFormState(this.wholesalerEdit);

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = wholesalerEdit.name;
    _reviewCtrl.text = wholesalerEdit.review;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text('Edit wholesaler rating')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // Image
                Container(
                  width: 120.0,
                  height: 120.0,
                  child: GestureDetector(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image(
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          color: Colors.black38,
                          colorBlendMode: BlendMode.darken,
                          image: getImage(),
                        ),
                        Icon(Icons.edit, color: Colors.white)
                      ],
                    ),
                    onTap: () async {
                      final i = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      setState(() => image = i);
                    },
                  ),
                ),

                SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      InputDecoration(labelText: 'Firm name', filled: true),
                ),

                SizedBox(height: 16),

                // Review
                TextFormField(
                  controller: _reviewCtrl,
                  decoration: InputDecoration(
                    labelText: 'Review',
                    filled: true,
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  minLines: 5,
                ),

                SizedBox(height: 16),

                // Submit
                RaisedButton(
                  child: isLoading
                      ? SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : Text('UPDATE'),
                  onPressed: isLoading ? null : editRating,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getImage() {
    if (image != null) {
      return FileImage(image);
    } else if (widget.wholesalerEdit.imageUrl != null) {
      return CachedNetworkImageProvider(widget.wholesalerEdit.imageUrl);
    } else {
      return AssetImage('images/placeholder.png');
    }
  }

  void editRating() async {
    final Map<String, dynamic> data = {
      'name': _nameCtrl.text,
      'review': _reviewCtrl.text,
    };

    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path);
    }

    FormData formData = FormData.fromMap(data);

    setState(() => isLoading = true);
    WholesalerRatingService.update(widget.wholesalerEdit.id, formData)
        .then((res) {
      Navigator.pop(context, res);
    }).catchError((err) {
      ToastService.error(scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }
}
