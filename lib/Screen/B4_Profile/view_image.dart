import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImageScreen extends StatelessWidget{
  final String imgUrl;
  ViewImageScreen({this.imgUrl});

  @override
 Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back)
      ),
      elevation: 0.0,
    ),
    body: Center(
      child: Container(
        child: PhotoView(
          imageProvider: NetworkImage(imgUrl),
        )
      )
    )
   );
 }
}