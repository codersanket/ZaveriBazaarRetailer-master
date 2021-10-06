import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/pages/wholesaler_rating_contacts.dart';
import 'package:sonaar_retailer/services/toast_service.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';

class WholesalerRatingAddPage extends StatefulWidget {
  @override
  _WholesalerRatingAddPageState createState() =>
      _WholesalerRatingAddPageState();
}

class _WholesalerRatingAddPageState extends State<WholesalerRatingAddPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  File image;
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final reviewCtrl = TextEditingController();
  double rating = 0;
  bool recommend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Rate wholesaler')),
      body: SingleChildScrollView(child: buildForm()),
    );
  }

  Form buildForm() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Image
            buildImage(),

            SizedBox(height: 16),

            // Rating
            RatingBar.builder(
              onRatingUpdate: (r) => setState(() => rating = r),
              initialRating: 0,
              minRating: 1,
              itemCount: 5,
              glow: false,
              itemSize: 32,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),

            SizedBox(height: 16),

            // Name
            TextFormField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Firm name',
                filled: true,
              ),
              validator: (v) {
                if (v.isEmpty)
                  return 'Please enter firm name';
                else
                  return null;
              },
            ),

            SizedBox(height: 16),

            // Mobile number
            Stack(
              children: <Widget>[
                // Field
                TextFormField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Mobile number',
                    filled: true,
                  ),
                  validator: (v) {
                    if (v.isEmpty)
                      return 'Please enter mobile number';
                    else if (!RegExp(r'[0-9]{10}').hasMatch(v))
                      return 'Please enter valid mobile number';
                    else
                      return null;
                  },
                ),

                // Contacts button
                Positioned(
                  right: 0,
                  top: 2,
                  child: IconButton(
                    icon: Icon(Icons.contacts, color: Colors.grey.shade700),
                    onPressed: pickContact,
                    tooltip: 'Pick from contacts',
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Review
            TextFormField(
              controller: reviewCtrl,
              maxLines: null,
              minLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Review',
                filled: true,
                alignLabelWithHint: true,
              ),
            ),

            SizedBox(height: 16),

            // Recommend
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: recommend,
                    onChanged: (value) {
                      setState(() => recommend = value);
                    },
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  child: Text('Recommend to others'),
                  onTap: () {
                    setState(() => recommend = !recommend);
                  },
                )
              ],
            ),

            SizedBox(height: 16),

            // Submit
            RaisedButton(
              onPressed: isLoading ? null : rate,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: isLoading
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : Text('RATE'),
            ),
          ],
        ),
      ),
    );
  }

  Container buildImage() {
    return Container(
      width: 120.0,
      height: 120.0,
      child: ClipOval(
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
                image: image == null
                    ? AssetImage('images/placeholder.png')
                    : FileImage(image),
              ),
              Icon(Icons.edit, color: Colors.white)
            ],
          ),
          onTap: () async {
            final i = await ImagePicker.pickImage(source: ImageSource.gallery);
            setState(() => image = i);
          },
        ),
      ),
    );
  }

  void pickContact() async {
    final UserContact contact = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WholesalerRatingContactsPage()),
    );

    if (contact != null) {
      nameCtrl.text = contact.name;
      mobileCtrl.text = contact.mobile;
    }
  }

  void rate() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    if (rating == 0) {
      ToastService.error(scaffoldKey, 'Please select a rating from 1 to 5');
      return;
    }

    final Map<String, dynamic> data = {
      'name': nameCtrl.text,
      'mobile': mobileCtrl.text,
      'review': reviewCtrl.text,
      'rating': rating.toInt(),
      'recommended': recommend ? 'yes' : 'no',
    };

    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path);
    }

    FormData formData = FormData.fromMap(data);

    setState(() => isLoading = true);
    WholesalerRatingService.create(formData).then((res) {
      Navigator.pop(context, 'rated');
    }).catchError((err) {
      ToastService.error(scaffoldKey, err.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }
}
