import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_downloader_example/post.dart';
import 'package:flutter_downloader_example/screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';

enum AdStatus { rewarded, unRewarded, loading, loaded }

class Logic with ChangeNotifier {
  RegExp instagramUrlRegex =
      RegExp(r"instagram\.com/\D+/[-a-zA-Z0-9()@:%_\+.~#?&=]*/?");
  Animation<Offset> errorTextFieldAnim;
  AnimationController errorTextFieldCont;
  bool permissionState = true;
  bool permissionIsCheckingNow = true;
  AdStatus adStatus = AdStatus.loading;
  ScrollController scrollController = ScrollController();
  var textFieldKey = GlobalKey<FormState>();
  CancelableOperation<List<http.Response>> cancelableOperation;
  var posts = List<Post>();
  ReceivePort _port = ReceivePort();
  int postIndex;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  Screen screen;
  bool reverse = false;

  RewardedVideoAd rewardedVideoAd;
  Tween<Offset> tween =
      Tween<Offset>(begin: Offset(0.0, 0), end: Offset(0.0, 0));
  ProgressDialog progressDialog;
  InterstitialAd interstitialAd;
  TextEditingController controller = TextEditingController();
  BuildContext context;
  Directory saveDirectory;
  Directory imagesDirectory;
  Directory videosDirectory;
  String LocalPath;
  String copiedText = '';
  bool dontShowAgainCheckBox = true;

  Logic(TickerProvider tickerProvider, BuildContext context) {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    saveDirectory = Directory(Constants.path);
    imagesDirectory = Directory(Constants.imagesPath);
    videosDirectory = Directory(Constants.videosPath);
    rewardedVideoAd = RewardedVideoAd.instance;
    initializeRewardAdListener();
    loadRewardedVideoAd();
    interstitialAd = createInterstitialAd();
    interstitialAd.load();

    Future.wait([
      checkPermission(),
      saveDirectory.exists(),
      imagesDirectory.exists(),
      videosDirectory.exists()
    ]).then((result) async {
      permissionState = result[0];
      if (!result[1]) {
        await saveDirectory.create();
      }
      if (!result[2]) {
        await imagesDirectory.create();
      }
      if (!result[3]) {
        await videosDirectory.create();
      }
      permissionIsCheckingNow = false;
      notifyListeners();
    });

    progressDialog = new ProgressDialog(
      context,
      showLogs: true,
      isDismissible: false,
      type: ProgressDialogType.Normal,
    );

    this.context = context;
    errorTextFieldCont = AnimationController(
        vsync: tickerProvider, duration: Duration(milliseconds: 200));
    errorTextFieldAnim = tween.animate(
        CurvedAnimation(curve: Curves.bounceInOut, parent: errorTextFieldCont));
  }

  void showMore(int index) {
    this.postIndex = index;
    posts[index].fullTitle = !posts[index].fullTitle;
    notifyListeners();
  }

  Future<void> pasteUrl() async {
    var data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) {
      showTextFieldError();
    } else {
      if (data.text.isEmpty) {
        showTextFieldError();
      } else {
        controller.text = data.text;
        textFieldKey.currentState.validate();
      }
    }
  }

  void showTextFieldError() {
    if (tween.begin == Offset(0.0, 0.0)) {
      tween.begin = Offset(-0.02, 0.0);
      tween.end = Offset(0.02, 0.0);
    }

    TickerFuture tickerFuture = errorTextFieldCont.repeat(
      reverse: true,
    );

    tickerFuture.timeout(Duration(milliseconds: 600), onTimeout: () async {
      errorTextFieldCont.animateBack(0.5);
    });
  }

  String textFieldValidator(String text) {
    if (text.isEmpty) {
      showTextFieldError();
      showSnackBar('لم يتم ادخال الرابط', false);
      return '';
    }
    if (instagramUrlRegex.allMatches(text).toList().length != 1) {
      showTextFieldError();
      showSnackBar('الرابط المدخل غير صحيح', false);
      return '';
    } else {
      return null;
    }
  }

  Future<bool> loadRewardedVideoAd() async {
    return await rewardedVideoAd.load(
        adUnitId: Constants.adRewardId, targetingInfo: MobileAdTargetingInfo());
  }

  Future<void> copy(BuildContext context, String text) async {
    if (adStatus == AdStatus.loaded) {
      this.copiedText = text;
      await progressDialog.show();
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      if (sharedPref.getBool('dontShowAgain') == null) {
        await sharedPref.setBool('dontShowAgain', false);
      }

      if (sharedPref.getBool('dontShowAgain')) {
        await rewardedVideoAd.show();
      } else {
        progressDialog.dismiss();
        showWarningDialog(sharedPref);
      }
    } else {
      showSnackBar('انتظر قليلا جاري تهيئه الاعلان', false);
    }
  }

  void initializeRewardAdListener() {
    rewardedVideoAd.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      print(event);
      if (event == RewardedVideoAdEvent.closed) {
        if (adStatus == AdStatus.rewarded) {
          showSnackBar('تم النسخ بنجاح', true);
        } else {
          showSnackBar('للاسف يجب انهاء الاعلان اولا لكي تستطيع النسخ', false);
        }
        adStatus = AdStatus.loading;
        notifyListeners();

        progressDialog.dismiss();

        await loadRewardedVideoAd();
      } else if (event == RewardedVideoAdEvent.failedToLoad) {
        adStatus = AdStatus.loading;
        await loadRewardedVideoAd();
      } else if (event == RewardedVideoAdEvent.loaded) {
        adStatus = AdStatus.loaded;
        notifyListeners();
      } else if (event == RewardedVideoAdEvent.rewarded ||
          event == RewardedVideoAdEvent.completed) {
        adStatus = AdStatus.rewarded;
        await Clipboard.setData(ClipboardData(text: this.copiedText));
      }
    };
  }

  void showWarningDialog(SharedPreferences sharedPref) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  AlertDialog(
                titleTextStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showSnackBar(
                            'يجب مشاهده الاعلان اولا كى تستطيع النسخ', false);
                      },
                      child: Text('لا أوافق')),
                  FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        if (this.dontShowAgainCheckBox) {
                          await sharedPref.setBool('dontShowAgain', true);
                        }
                        await this.rewardedVideoAd.show();
                      },
                      child: Text('نعم اوافق')),
                ],
                title: Center(
                    child: Text(
                  'إخطار',
                  style: TextStyle(color: Colors.black),
                )),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'هل توافق على مشاهده اعلان قبل عمليه النسخ ؟',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'لا أريد رؤيه هذا مجددا',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Checkbox(
                          value: this.dontShowAgainCheckBox,
                          onChanged: (bool value) {
                            setState(() {
                              this.dontShowAgainCheckBox = value;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void showSnackBar(String text, bool success) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  Future<void> confirm(BuildContext context) async {
    var isValid = textFieldKey.currentState.validate();

    if (isValid) {
      var text = controller.text;
      controller.clear();

      var regex = RegExp(r"instagram\.com/\D+/[-a-zA-Z0-9()@:%_\+.~#?&=]*/?");
      var url = regex.stringMatch(text);
      if (!url.endsWith('/')) {
        url += '/';
      }

      posts.add(Post(infoStatus: InfoStatus.loading, url: url));
      int index = posts.length - 1;
      notifyListeners();
      if (posts.length > 1) {
        showSnackBar('جاري تحميل المنشور', true);
      }
      posts[index] = await getVideoInfo(context, 'https://' + url);
      if (posts[index] == null) {
        posts.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    controller.clear();
  }

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void cancelDownload(String id) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  CancelableOperation<String> cancelableOperationn;
  Future<void> startDownload(BuildContext context, int index) async {
    posts[index].downloadIsLocked = true;
    notifyListeners();
    if (await DataConnectionChecker().hasConnection) {
      if (await interstitialAd.isLoaded()) {
        await interstitialAd?.show();

        posts[index].taskId = await FlutterDownloader.enqueue(
          savedDir: posts[index].isVideo
              ? Constants.videosPath
              : Constants.imagesPath,
          fileName: '${Uuid().v1()}',
          url: posts[index].downloadUrl,
        );
      } else {
        posts[index].downloadIsLocked = false;
        showSnackBar('لم يتم تحميل الاعلان انتظر قليلا', false);
      }
    } else {
      showSnackBar('يبدو ان هناك مشكله فى إتصالك بالإنترنت', false);
      posts[index].downloadIsLocked = false;
      notifyListeners();
    }
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: Constants.adInterId,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.closed ||
            event == MobileAdEvent.failedToLoad) {
          interstitialAd?.dispose();
          interstitialAd = createInterstitialAd();
          interstitialAd.load();
        }
      },
    );
  }

  void openDownload(String id) async {
    await FlutterDownloader.open(taskId: id);
  }

  Future<Post> getVideoInfo(BuildContext context, String url) async {
    cancelableOperation = CancelableOperation.fromFuture(
        Future.wait([http.get(url + '?__a=1'), http.get(url)]),
        onCancel: () {});

    List<http.Response> responses;
    try {
      responses = await cancelableOperation.value;
    } on SocketException {
      showSnackBar('يبدو ان هناك مشكله فى إتصالك بالإنترنت', false);
      return Post(infoStatus: InfoStatus.connectionError, url: url);
    } catch (e) {
      showSnackBar(
          'حاول مره اخري قد يكون الرابط المدخل به محتوي لا ندعمه الآن او به مشكله',
          false);

      return null;
    }
    var apiResponse = responses[0];
    var htmlResponse = responses[1];
    if (apiResponse.statusCode == 200 && htmlResponse.statusCode == 200) {
      try {
        var htmlDocument = parse(htmlResponse.body);
        var type = htmlDocument
            .querySelector('meta[property="og:type"]')
            .attributes['content'];
        String propertyHashtagName;
        if (type == 'video') {
          propertyHashtagName = 'video:tag';
        } else {
          propertyHashtagName = 'instapp:hashtags';
        }
        String hashtags = '';
        var hashtagList = htmlDocument
            .querySelectorAll('meta[property="$propertyHashtagName"]');
        if (hashtagList.isNotEmpty) {
          for (var hashtag in hashtagList) {
            hashtags += '#${hashtag.attributes['content']} ';
          }
        }
        Map<String, dynamic> responseBody = jsonDecode(apiResponse.body);
        Map<String, dynamic> root = responseBody['graphql']['shortcode_media'];
        Map<String, dynamic> ownerRoot = root['owner'];
        var userName = ownerRoot['username'];
        var profilePic = ownerRoot['profile_pic_url'];
        var user = await http.get('https://instagram.com/$userName/?__a=1');
        var profilePicHd =
            jsonDecode(user.body)['graphql']['user']['profile_pic_url_hd'];
        var date = root['taken_at_timestamp'];
        var thumbnail = root['display_url'];
        String downloadUrl;
        bool isVideo;
        if (root.containsKey('edge_sidecar_to_children')) {
          var node = root['edge_sidecar_to_children']['edges'][0]['node'];
          isVideo = node['is_video'];
          if (isVideo) {
            downloadUrl = node['video_url'];
          } else {
            downloadUrl = thumbnail;
          }
        } else {
          isVideo = root['is_video'];
          if (isVideo) {
            downloadUrl = root['video_url'];
          } else {
            downloadUrl = thumbnail;
          }
        }
        String title = '';
        List titleEdges = root['edge_media_to_caption']['edges'];
        if (titleEdges.isNotEmpty) {
          title = titleEdges[0]['node']['text'];
        }
        return Post(
            infoStatus: InfoStatus.success,
            title: title,
            timeStamp: date,
            downloadUrl: downloadUrl,
            hashtags: hashtags,
            thumbnail: thumbnail,
            isVideo: isVideo,
            owner: Owner(
                profilePicHd: profilePicHd,
                profilePic: profilePic,
                userName: userName));
      } catch (e) {
        print(e.toString() + '!');

        showSnackBar('يبدو ان هناك مشكله فى الرابط المدخل', false);
      }
    } else {
      showSnackBar('يبدو ان هناك مشكله فى الرابط المدخل', false);

      return null;
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send(DownloadCallbackModel(progress, status, id));
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      DownloadCallbackModel downloadCallbackModel = data;
      int index = posts.indexWhere((post) {
        if (post.taskId == downloadCallbackModel.taskId) {
          return true;
        } else {
          return false;
        }
      });
      posts[index].downloadCallbackModel = downloadCallbackModel;
      posts[index].downloadIsLocked = false;

      if (posts[index].isGoingToCancel) {
        cancelDownload(posts[index].taskId);
      }
      notifyListeners();
    });
  }
}
