import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatelessWidget {
  String imageUrl;
  PhotoViewer(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return PhotoView(
      backgroundDecoration: BoxDecoration(color: Colors.white),
      imageProvider: NetworkImage(imageUrl),
    );
  }
}
