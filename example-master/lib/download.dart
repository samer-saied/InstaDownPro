import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_downloader_example/photo_view.dart';
import 'package:flutter_downloader_example/post.dart';
import 'package:flutter_downloader_example/screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'loading.dart';
import 'logic.dart';
import 'myButton.dart';

class DownloadPage extends StatelessWidget {
  Widget build(BuildContext context) {
    Logic logic = Provider.of(context, listen: false);
    var size = MediaQuery.of(context).size;
    logic.screen = Screen(size: size);
    logic.screen = Screen(size: size);
    var screen = logic.screen;
    var height = screen.height;
    var width = screen.width;
    var aspectRatio = screen.aspectRatio;
    return Consumer<Logic>(
      builder: (BuildContext context, Logic logic, Widget child) => SafeArea(
          child: Scaffold(
              floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: IconThemeData(size: 22.0),
                closeManually: false,
                curve: Curves.bounceIn,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                onOpen: () => print('OPENING DIAL'),
                onClose: () => print('DIAL CLOSED'),
                tooltip: 'خصائص',
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                elevation: 8.0,
                shape: CircleBorder(),
                children: [
                  SpeedDialChild(
                      child: Icon(Icons.arrow_upward),
                      backgroundColor: Colors.green,
                      onTap: () {
                        logic.scrollController.jumpTo(0.0);
                      }),
                  SpeedDialChild(
                    child: Icon(Icons.arrow_downward),
                    backgroundColor: Colors.red,
                    onTap: () {
                      logic.scrollController.jumpTo(
                          logic.scrollController.position.maxScrollExtent);
                    },
                  ),
                  /*SpeedDialChild(
                    child: Icon(Icons.delete_forever),
                    backgroundColor: Colors.red,
                    onTap: () {
                      FlutterDownloader.cancelAll();
                    },
                  ),*/
                ],
              ),
              key: logic.scaffoldKey,
              endDrawer: Drawer(
                child: Column(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size.fromHeight(screen.convert(250, height)),
                      child: DrawerHeader(
                        child: Center(
                            child: Column(
                          textDirection: TextDirection.rtl,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'assets/logo.png',
                              height: screen.convert(80, height),
                              width: screen.convert(80, width),
                              fit: BoxFit.contain,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screen.convert(5, height))),
                            Text(
                              'Insta Down Pro',
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: screen.convert(30, aspectRatio),
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        )),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: screen.convert(10, width)),
                      onTap: () {
                        Share.share(
                            'شارك تطبيقانا مع اصدقائك لتعم الفائده  https://play.google.com/store/apps/details?id=com.HNY.qurancareem',
                            subject: 'Look what I made!');
                      },
                      trailing: Icon(
                        FontAwesomeIcons.share,
                        color: Colors.orange,
                        textDirection: TextDirection.rtl,
                      ),
                      title: Text(
                        'شارك التطبيق',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: screen.convert(20, aspectRatio),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      onTap: () {
                        LaunchReview.launch(androidAppId: "com.usatolebanese");
                      },
                      trailing: Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: screen.convert(28, aspectRatio),
                      ),
                      title: Text(
                        'اعطنا تقييم',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: screen.convert(20, aspectRatio),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      onTap: () async {
                        const url =
                            'https://t.me/joinchat/AAAAAFQB7H0Zwq7l4vI4Yg';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          logic.showSnackBar('هذا الرابط معطل الآن', false);
                        }
                      },
                      trailing: Icon(
                        FontAwesomeIcons.telegram,
                        color: Colors.orange,
                        size: screen.convert(28, aspectRatio),
                      ),
                      title: Text(
                        'تابعنا علي قناة التلجرام',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: screen.convert(20, aspectRatio),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: logic.permissionIsCheckingNow
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : logic.permissionState
                        ? ScrollConfiguration(
                            behavior: ScrollBehavior(),
                            child: CustomScrollView(
                                physics: BouncingScrollPhysics(),
                                controller: logic.scrollController,
                                slivers: <Widget>[
                                  SliverAppBar(
                                    centerTitle: true,
                                    actions: <Widget>[SizedBox.shrink()],
                                    leading: IconButton(
                                        onPressed: () {
                                          logic.scaffoldKey.currentState
                                              .openEndDrawer();
                                        },
                                        icon: Icon(Icons.menu)),
                                    iconTheme:
                                        IconThemeData(color: Colors.black),
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    expandedHeight: screen.convert(310, height),
                                    flexibleSpace: FlexibleSpaceBar(
                                      background: Padding(
                                        padding: EdgeInsets.only(
                                            top: screen.convert(70, height)),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: screen.convert(
                                                      30, width)),
                                              child: SlideTransition(
                                                position:
                                                    logic.errorTextFieldAnim,
                                                child: Form(
                                                  key: logic.textFieldKey,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      TextFormField(
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                        controller:
                                                            logic.controller,
                                                        validator: (text) => logic
                                                            .textFieldValidator(
                                                                text),
                                                        decoration:
                                                            InputDecoration(
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .symmetric(
                                                                  vertical: screen
                                                                      .convert(
                                                                          20,
                                                                          height),
                                                                  horizontal: screen
                                                                      .convert(
                                                                          20,
                                                                          screen
                                                                              .width),
                                                                ),
                                                                hintStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2)),
                                                                helperText: '',
                                                                hintText:
                                                                    'instagram.com/dummy/dummy',
                                                                errorStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(
                                                                          screen.convert(
                                                                              10,
                                                                              aspectRatio))),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: screen.convert(
                                                                        screen.convert(
                                                                            1.8,
                                                                            aspectRatio),
                                                                        width),
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.link,
                                                                  color: Colors
                                                                      .purple,
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(
                                                                          screen.convert(
                                                                              10,
                                                                              aspectRatio))),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: screen
                                                                        .convert(
                                                                            1.8,
                                                                            width),
                                                                    color: Colors
                                                                        .purple,
                                                                  ),
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(
                                                                          screen.convert(
                                                                              10,
                                                                              aspectRatio))),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .purple,
                                                                      width: screen
                                                                          .convert(
                                                                              1,
                                                                              width)),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(
                                                                          screen.convert(
                                                                              10,
                                                                              aspectRatio))),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .purple,
                                                                      width: screen
                                                                          .convert(
                                                                              1,
                                                                              width)),
                                                                ),
                                                                labelStyle: GoogleFonts.cairo(
                                                                    color: Colors
                                                                        .green),
                                                                labelText:
                                                                    'الصق الرابط هنا'),
                                                      ),
                                                      Positioned.fill(
                                                        child: Align(
                                                          alignment: Alignment(
                                                              -0.92, -0.40),
                                                          child: InkWell(
                                                            onTap: () {
                                                              print('!!');
                                                              logic.clear();
                                                            },
                                                            child: Container(
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  size: screen
                                                                      .convert(
                                                                          15,
                                                                          aspectRatio),
                                                                ),
                                                              ),
                                                              width: screen
                                                                  .convert(25,
                                                                      width),
                                                              height: screen
                                                                  .convert(25,
                                                                      width),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: screen.convert(
                                                      50, height)),
                                              child: ButtonTheme(
                                                height:
                                                    screen.convert(60, height),
                                                minWidth:
                                                    screen.convert(150, width),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    MyButton(
                                                        'تأكيد', Colors.green,
                                                        () {
                                                      logic.confirm(context);
                                                    }),
                                                    MyButton(
                                                        'لصق', Colors.purple,
                                                        () {
                                                      logic.pasteUrl();
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height:
                                                  screen.convert(10, height),
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (context, int i) {
                                      if (logic.posts[i].infoStatus ==
                                          InfoStatus.loading)
                                        return Loading(i);
                                      else if (logic.posts[i].infoStatus ==
                                          InfoStatus.success)
                                        return Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: screen.convert(
                                                      20, height),
                                                  top: screen.convert(
                                                      10, height),
                                                  right:
                                                      screen.convert(10, width),
                                                  left: screen.convert(
                                                      10, width)),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Material(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    PhotoViewer(logic
                                                                        .posts[
                                                                            i]
                                                                        .owner
                                                                        .profilePicHd)));
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                            child:
                                                                CachedNetworkImage(
                                                              placeholder:
                                                                  (context,
                                                                      text) {
                                                                return SizedBox(
                                                                    height: screen
                                                                        .convert(
                                                                            65,
                                                                            height),
                                                                    width: screen
                                                                        .convert(
                                                                            65,
                                                                            width),
                                                                    child: Center(
                                                                        child:
                                                                            CircularProgressIndicator()));
                                                              },
                                                              width: screen
                                                                  .convert(65,
                                                                      width),
                                                              height: screen
                                                                  .convert(65,
                                                                      height),
                                                              fit: BoxFit.cover,
                                                              imageUrl: logic
                                                                  .posts[i]
                                                                  .owner
                                                                  .profilePic,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              left: screen
                                                                  .convert(10,
                                                                      width))),
                                                      Expanded(
                                                        flex: 9,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Text(
                                                              logic
                                                                  .posts[i]
                                                                  .owner
                                                                  .userName,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: screen
                                                                      .convert(
                                                                          20,
                                                                          aspectRatio)),
                                                            ),
                                                            Text(
                                                              logic
                                                                  .posts[i].date
                                                                  .toString(),
                                                              style: GoogleFonts.cairo(
                                                                  fontSize: screen
                                                                      .convert(
                                                                          12,
                                                                          aspectRatio)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: InkWell(
                                                          onTap: () {
                                                            var post =
                                                                logic.posts[i];
                                                            var status = post
                                                                .downloadCallbackModel
                                                                ?.status;
                                                            if (status ==
                                                                    DownloadTaskStatus
                                                                        .running ||
                                                                logic.posts[i]
                                                                    .downloadIsLocked) {
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  context:
                                                                      context,
                                                                  builder: (con) =>
                                                                      AlertDialog(
                                                                        actions: <
                                                                            Widget>[
                                                                          FlatButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (logic.posts[i].downloadIsLocked) {
                                                                                logic.posts[i].isGoingToCancel = true;
                                                                              } else {
                                                                                logic.cancelDownload(logic.posts[i].taskId);
                                                                              }
                                                                              Navigator.pop(context);
                                                                              logic.showSnackBar('تم ايقاف التنزيل', false);
                                                                            },
                                                                            child:
                                                                                Text('نعم'),
                                                                          ),
                                                                          FlatButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Text('لا'),
                                                                          )
                                                                        ],
                                                                        content:
                                                                            Text('هل تريد الغاء هذا التنزيل ؟'),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(15))),
                                                                      ));
                                                            } else {
                                                              logic.posts
                                                                  .removeAt(i);
                                                              logic
                                                                  .notifyListeners();
                                                            }
                                                          },
                                                          child: SizedBox(
                                                            height:
                                                                screen.convert(
                                                                    30, height),
                                                            width:
                                                                screen.convert(
                                                                    30, width),
                                                            child: Material(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: Colors.red,
                                                              type: MaterialType
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                screen.convert(
                                                                    20,
                                                                    height)),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          '${logic.posts[i].getTitle}',
                                                          style: TextStyle(
                                                              fontSize: screen
                                                                  .convert(15,
                                                                      aspectRatio),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        logic.posts[i].title
                                                                    .length >
                                                                40
                                                            ? InkWell(
                                                                onTap: () {
                                                                  logic
                                                                      .showMore(
                                                                          i);
                                                                },
                                                                child: Text(
                                                                    logic
                                                                            .posts[
                                                                                i]
                                                                            .fullTitle
                                                                        ? 'عرض اقل'
                                                                        : 'عرض المزيد',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              )
                                                            : SizedBox.shrink(),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        child:
                                                            CachedNetworkImage(
                                                          placeholder:
                                                              (context, text) {
                                                            return SizedBox(
                                                                height: screen
                                                                    .convert(
                                                                        400,
                                                                        height),
                                                                width: screen
                                                                    .convert(
                                                                        330,
                                                                        width),
                                                                child: Center(
                                                                    child:
                                                                        CircularProgressIndicator()));
                                                          },
                                                          imageUrl: logic
                                                              .posts[i]
                                                              .thumbnail,
                                                          height:
                                                              screen.convert(
                                                                  400, height),
                                                          fit: BoxFit.cover,
                                                          width: screen.convert(
                                                              330, width),
                                                        ),
                                                      ),
                                                      Positioned.fill(
                                                        child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.9, -0.9),
                                                            child: Icon(logic
                                                                    .posts[i]
                                                                    .isVideo
                                                                ? FontAwesomeIcons
                                                                    .video
                                                                : FontAwesomeIcons
                                                                    .image)),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: screen.convert(
                                                              20, height))),
                                                  LinearProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.green),
                                                    value: logic
                                                                    .posts[i]
                                                                    .downloadCallbackModel
                                                                    ?.progress ==
                                                                null ||
                                                            logic
                                                                    .posts[i]
                                                                    .downloadCallbackModel
                                                                    .status ==
                                                                DownloadTaskStatus
                                                                    .canceled
                                                        ? 0
                                                        : logic
                                                                .posts[i]
                                                                .downloadCallbackModel
                                                                .progress
                                                                .toDouble() /
                                                            100,
                                                    backgroundColor: Colors
                                                        .purple
                                                        .withOpacity(0.1),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: screen.convert(
                                                        20,
                                                        height,
                                                      ),
                                                    ),
                                                    child: ButtonTheme(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius
                                                                        .circular(
                                                                            5))),
                                                        minWidth: width,
                                                        height: screen.convert(
                                                            70, height),
                                                        child: FlatButton.icon(
                                                            colorBrightness:
                                                                Brightness.dark,
                                                            color: Colors.green,
                                                            onPressed:
                                                                logic.posts[i]
                                                                            .downloadIsLocked ||
                                                                        logic.posts[i].downloadCallbackModel?.status ==
                                                                            DownloadTaskStatus
                                                                                .running ||
                                                                        logic.posts[i].downloadCallbackModel?.status ==
                                                                            DownloadTaskStatus.enqueued
                                                                    ? null
                                                                    : () {
                                                                        if (logic
                                                                            .posts[
                                                                                i]
                                                                            .isGoingToCancel)
                                                                          logic.posts[i].isGoingToCancel =
                                                                              false;
                                                                        if (logic.posts[i].buttonText ==
                                                                            'اكتمل التحميل افتح الآن') {
                                                                          logic.openDownload(logic
                                                                              .posts[i]
                                                                              .taskId);
                                                                        } else {
                                                                          logic.startDownload(
                                                                              context,
                                                                              i);
                                                                        }
                                                                      },
                                                            icon: Icon(
                                                              FontAwesomeIcons
                                                                  .download,
                                                              size: screen.convert(
                                                                  24,
                                                                  aspectRatio),
                                                            ),
                                                            label: Text(
                                                              logic.posts[i]
                                                                      .downloadIsLocked
                                                                  ? 'جاري الاتصال بالانترنت'
                                                                  : logic
                                                                      .posts[i]
                                                                      .buttonText,
                                                              style: TextStyle(
                                                                  fontSize: screen
                                                                      .convert(
                                                                          17,
                                                                          aspectRatio),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ))),
                                                  ),
                                                  logic.posts[i].title
                                                              .isEmpty &&
                                                          logic.posts[i]
                                                              .hashtags.isEmpty
                                                      ? SizedBox.shrink()
                                                      : ButtonTheme(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                          textTheme:
                                                              ButtonTextTheme
                                                                  .primary,
                                                          buttonColor:
                                                              Colors.pink,
                                                          minWidth: logic
                                                                      .posts[i]
                                                                      .title
                                                                      .isEmpty ||
                                                                  logic
                                                                      .posts[i]
                                                                      .hashtags
                                                                      .isEmpty
                                                              ? width / 1.5
                                                              : screen.convert(
                                                                  150, width),
                                                          height:
                                                              screen.convert(
                                                                  65, height),
                                                          child: Row(
                                                            mainAxisAlignment: logic
                                                                        .posts[
                                                                            i]
                                                                        .title
                                                                        .isEmpty ||
                                                                    logic
                                                                        .posts[
                                                                            i]
                                                                        .hashtags
                                                                        .isEmpty
                                                                ? MainAxisAlignment
                                                                    .center
                                                                : MainAxisAlignment
                                                                    .spaceAround,
                                                            children: <Widget>[
                                                              logic
                                                                      .posts[i]
                                                                      .hashtags
                                                                      .isEmpty
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : RaisedButton(
                                                                      onPressed: logic.adStatus ==
                                                                              AdStatus.loaded
                                                                          ? () {
                                                                              logic.copy(context, logic.posts[i].hashtags);
                                                                            }
                                                                          : null,
                                                                      child: Text(
                                                                        logic.adStatus ==
                                                                                AdStatus.loaded
                                                                            ? 'نسخ الهاشتاق'
                                                                            : 'جاري التجهيز',
                                                                        style: TextStyle(
                                                                            fontSize: screen.convert(16,
                                                                                aspectRatio),
                                                                            fontWeight:
                                                                                FontWeight.w900),
                                                                      )),
                                                              logic
                                                                      .posts[i]
                                                                      .title
                                                                      .isEmpty
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : RaisedButton(
                                                                      onPressed: logic.adStatus ==
                                                                              AdStatus.loaded
                                                                          ? () {
                                                                              logic.copy(context, logic.posts[i].title);
                                                                            }
                                                                          : null,
                                                                      child: Text(
                                                                        logic.adStatus ==
                                                                                AdStatus.loaded
                                                                            ? 'نسخ المحتوى'
                                                                            : 'جاري التجهيز',
                                                                        style: TextStyle(
                                                                            fontSize: screen.convert(16,
                                                                                aspectRatio),
                                                                            fontWeight:
                                                                                FontWeight.w700),
                                                                      )),
                                                            ],
                                                          ),
                                                        )
                                                ],
                                              ),
                                            ),
                                            Divider()
                                          ],
                                        );
                                      else if (logic.posts[i].infoStatus ==
                                          null)
                                        return SizedBox.shrink();
                                      else
                                        return Column(
                                          children: <Widget>[
                                            Stack(
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.all(
                                                        screen.convert(
                                                            10, aspectRatio)),
                                                    height: screen.convert(
                                                        300, height),
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    child: Center(
                                                        child: Material(
                                                      type: MaterialType.circle,
                                                      color: Colors.green,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50)),
                                                        onTap: () async {
                                                          var url = logic
                                                              .posts[i].url;
                                                          logic.posts[i] = Post(
                                                            infoStatus:
                                                                InfoStatus
                                                                    .loading,
                                                          );
                                                          logic
                                                              .notifyListeners();

                                                          logic.posts[i] =
                                                              await logic
                                                                  .getVideoInfo(
                                                                      context,
                                                                      url);
                                                          logic
                                                              .notifyListeners();
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Icon(
                                                            Icons.replay,
                                                            color: Colors.white,
                                                            size: screen.convert(
                                                                70,
                                                                aspectRatio),
                                                          ),
                                                        ),
                                                      ),
                                                    ))),
                                                Positioned.fill(
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.88, -0.85),
                                                    child: InkWell(
                                                      onTap: () {
                                                        print('!');
                                                        logic.posts.removeAt(i);
                                                        logic.notifyListeners();
                                                      },
                                                      child: SizedBox(
                                                        height: screen.convert(
                                                            30, height),
                                                        width: screen.convert(
                                                            30, width),
                                                        child: Material(
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                          color: Colors.red,
                                                          type: MaterialType
                                                              .circle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider()
                                          ],
                                        );
                                    },
                                    childCount: logic.posts.length,
                                  )),
                                  SliverPadding(
                                      padding: EdgeInsets.only(
                                          bottom: screen.convert(50, height)))
                                ]))
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Spacer(
                                  flex: 2,
                                ),
                                Icon(
                                  Icons.error,
                                  color: Colors.orange,
                                  size: screen.convert(120, aspectRatio),
                                ),
                                ButtonTheme(
                                  minWidth: screen.convert(200, width),
                                  height: screen.convert(60, height),
                                  child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      colorBrightness: Brightness.dark,
                                      color: Colors.purple,
                                      onPressed: () async {
                                        await logic.progressDialog.show();
                                        logic.permissionState =
                                            await logic.checkPermission();
                                        logic.progressDialog.dismiss();

                                        logic.notifyListeners();
                                      },
                                      child: Text('اعطاء الإذن')),
                                ),
                                Spacer(
                                  flex: 4,
                                ),
                              ],
                            ),
                          ),
              ))),
    );
  }
}
