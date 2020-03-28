import 'package:flutter/material.dart';

class Saves extends StatefulWidget {
  @override
  _SavesState createState() => _SavesState();
}

class _SavesState extends State<Saves> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        crossAxisCount: 3,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 2),
      ),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Image.network(
            'https://d2x51gyc4ptf2q.cloudfront.net/content/uploads/2020/01/20104912/Mo-Salah-Football365-700x366.jpg',
            height: 100,
            width: 50,
            fit: BoxFit.cover,
          ),
        );
      },
      itemCount: 20,
    );
  }
}
