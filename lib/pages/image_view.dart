import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final String imageUrl, heroTag;

  const ImageView({Key key, this.imageUrl, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black54),
      body: Center(
        child: PhotoView(
          heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
          imageProvider: CachedNetworkImageProvider(imageUrl),
          loadingBuilder: (context, event) {
            return Container(
              child: CircularProgressIndicator(strokeWidth: 2.0),
              color: Colors.black,
              alignment: Alignment.center,
            );
          },
        ),
      ),
    );
  }
}
