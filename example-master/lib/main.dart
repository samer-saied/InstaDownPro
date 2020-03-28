import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_downloader_example/logic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'download.dart';

String localPath;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await FirebaseAdMob.instance.initialize(appId: Constants.adAppId);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: GoogleFonts.cairo().fontFamily,
            accentColor: Colors.purple,
            scaffoldBackgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white)),
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider(
          child: DownloadPage(),
          create: (ctx) => Logic(this, ctx),
        ));
  }
}
