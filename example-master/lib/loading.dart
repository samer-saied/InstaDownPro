import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader_example/screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'logic.dart';

class Loading extends StatelessWidget {
  int i;
  Loading(this.i);
  @override
  Widget build(BuildContext context) {
    Logic logic = Provider.of(context, listen: false);
    var size = MediaQuery.of(context).size;
    logic.screen = Screen(size: size);
    var screen = logic.screen;
    var height = screen.height;
    var width = screen.width;

    return Padding(
      padding: EdgeInsets.all(screen.convert(10, screen.aspectRatio)),
      child: Column(
        children: <Widget>[
          Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Shimmer.fromColors(
                  enabled: true,
                  baseColor: Color(0xffE9E9E9),
                  highlightColor: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: screen.convert(65, width),
                    height: screen.convert(65, height),
                  )),
              Padding(padding: EdgeInsets.only(left: 10)),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Shimmer.fromColors(
                      enabled: true,
                      baseColor: Color(0xffE9E9E9),
                      highlightColor: Colors.white,
                      child: Container(
                        height: screen.convert(12, height),
                        width: screen.convert(150, width),
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(top: screen.convert(10, height))),
                    Shimmer.fromColors(
                      enabled: true,
                      baseColor: Color(0xffE9E9E9),
                      highlightColor: Colors.white,
                      child: Container(
                        height: screen.convert(10, height),
                        width: screen.convert(120, width),
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  logic.cancelableOperation.cancel().then((x) {
                    logic.posts.removeAt(i);
                    logic.notifyListeners();
                  });
                },
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: Material(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                    type: MaterialType.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: <Widget>[
                for (int i = 1; i < 6; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        top: screen.convert(5, height),
                        bottom: screen.convert(5, height),
                        right: screen.convert(5.0 * i, width),
                        left: screen.convert(10, width)),
                    child: Shimmer.fromColors(
                      enabled: true,
                      baseColor: Color(0xffE9E9E9),
                      highlightColor: Colors.white,
                      child: Container(
                        height: screen.convert(5, height),
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Shimmer.fromColors(
            enabled: false,
            baseColor: Color(0xffE9E9E9),
            highlightColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              height: screen.convert(400, height),
              width: screen.convert(330, width),
            ),
          ),
        ],
      ),
    );
  }
}
