
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/pages/Auth/login.dart';
import 'package:syncuwell/pages/Auth/sign_Up_Page.dart';
import 'package:syncuwell/pages/TimeTable/TimeTableScreen.dart';
import 'package:syncuwell/pages/chat/chat_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SyncUwell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen()
    );
  }
}

