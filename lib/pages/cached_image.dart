import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double width, height;
  final IconData placeholderIcon;

  CachedImage({
    Key key,
    @required this.imageUrl,
    @required this.width,
    @required this.height,
    this.placeholderIcon = Icons.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: imageUrl == null
          ? Icon(this.placeholderIcon)
          : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: imageUrl,
              errorWidget: (c, u, e) => Icon(Icons.warning),
              placeholder: (c, u) => Center(
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
    );
  }
}
