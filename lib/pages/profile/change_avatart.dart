import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:fluttermoji/fluttermojiCustomizer.dart';
import 'package:fluttermoji/fluttermojiSaveWidget.dart';
import 'package:fluttermoji/fluttermojiThemeData.dart';

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({Key? key}) : super(key: key);

  @override
  State<ChangeAvatar> createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    setState(() {
      loading = !loading;
    });
    var _width = MediaQuery.of(context).size.width;

    return loading
        ? const Center(
      child: CircularProgressIndicator(
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff60046E),
        elevation: 1,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        // padding:
        //     const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
        color: const Color(0xff60046E),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                right: 5, left: 5, top: 5, bottom: 5),
            child: Container(
              height: MediaQuery.of(context).size.height * 85,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: FluttermojiCircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(
                      width: min(600, _width * 0.85),
                      child: Row(
                        children: [
                          Text(
                            "Customize:",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Spacer(),
                          FluttermojiSaveWidget(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 30),
                      child: FluttermojiCustomizer(
                        scaffoldWidth: min(600, _width * 0.85),
                        autosave: false,
                        theme: FluttermojiThemeData(
                            boxDecoration:
                            BoxDecoration(boxShadow: [BoxShadow()])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
