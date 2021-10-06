import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/pages/wholesaler_rating_edit.dart';

import 'image_view.dart';

class WholesalerRatingDetail extends StatefulWidget {
  final WholesalerRating wholesaler;
  final Function(WholesalerRating) onChange;

  WholesalerRatingDetail(this.wholesaler, this.onChange);

  @override
  _WholesalerRatingDetailState createState() =>
      _WholesalerRatingDetailState(wholesaler);
}

class _WholesalerRatingDetailState extends State<WholesalerRatingDetail> {
  WholesalerRating wholesaler;

  _WholesalerRatingDetailState(this.wholesaler);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wholesaler rating')),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
//
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//
                wholesaler.imageUrl != null
                    ? GestureDetector(
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.black,
                          child: Hero(
                            tag: "wholesaler${wholesaler.id}",
                            child: CachedNetworkImage(
                              imageUrl: wholesaler.imageUrl,
                              fit: BoxFit.fitHeight,
                              errorWidget: (c, u, e) =>
                                  Icon(Icons.warning, color: Colors.white),
                              placeholder: (c, u) => Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.0)),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ImageView(
                                      imageUrl: wholesaler.imageUrl,
                                      heroTag: "wholesaler${wholesaler.id}",
                                    )),
                          );
                        },
                      )
                    : Container(
                        height: 250,
                        alignment: Alignment.center,
                        color: Colors.grey.shade300,
                        child: Text(
                          'No image uploaded!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                      ),
//
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        wholesaler.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        wholesaler.mobile,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 6),
                      Text(
                        wholesaler.review,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),

//
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: !wholesaler.canModify
          ? null
          : FloatingActionButton(
              child: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (_) => WholesalerRatingEditForm(wholesaler),
                ))
                    .then((res) {
                  if (res != null) {
                    setState(() {
                      wholesaler = res;
                      widget.onChange(res);
                    });
                  }
                });
              },
            ),
    );
  }
}
