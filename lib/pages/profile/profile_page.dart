import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Utils/headerfile.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/main.dart';
import 'package:syncuwell/pages/TimeTable/time-tablecontroller.dart';
import 'package:syncuwell/pages/TimeTable/updateTimeTableScreen.dart';
import 'package:syncuwell/pages/profile/change_avatart.dart';
import 'package:syncuwell/pages/tracker/dashboard.dart';

import '../Auth/login.dart';

Future<String?> getUID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('uid');

  if (uid != null ) {

    return uid;
  } else {
    // If the data is not available in SharedPreferences
    return ''; // or handle it according to your use case
  }
}


Future<void> removeStringFromPrefs(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TimetableController timetableController =
  Get.put(TimetableController(), permanent: true);
  final _nameController = TextEditingController();
  bool profileEdit = false;
  String name = "syncUwell";
  bool loading = false;
  Future<void> getData() async {
    setState(() {
      loading = true;
    });
    var db = FirebaseFirestore.instance;
    String? uid = await getUID();
    DocumentSnapshot userData = await db.collection('Users').doc(uid).get();

    // Check if the document exists and has data before accessing 'name' field
    if (userData.exists) {
      Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name')) {
        setState(() {
          loading = false;
          name = data['name'];
        });
      }
    }

    // Return null if the document doesn't exist or 'name' field is missing
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width, 75),
          child: HeaderL(),
        ),
        body:   loading
            ?  Center(
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1),
            child: const CircularProgressIndicator(color: Colors.black),
          ),
        )
        :SingleChildScrollView(
          child: Column(

              children: [

            SizedBox(height: height*.04,),
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(
                        width: 2.5,
                        color: Color(0xFFE2E1FA),
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: FluttermojiCircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 50,
                  ),
                ),
                Positioned(
                  bottom: -5, // Adjust this value to align the icon properly
                  right: -5, // Adjust this value to align the icon properly
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Add your edit functionality here
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangeAvatar()));
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height*.03,),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: SizedBox(
                // color: Colors.amber,
                height: 40,
                width: 160,
                child: Text(
                  'Hey, $name',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,

                    color: Color(0xff350257),
                  ),
                ),
              ),
          ),
            //
            //const Positioned(left: 20, top: 110, child: MainOptions()),
            Padding(
              padding: const EdgeInsets.only(left: 33.0,right: 33.0),
              child: MainOptions(),
            ),
            ContactUs(),
            SizedBox(height: height*.03,),
                // ElevatedButton(onPressed: (){
                //   Navigator.push(context, MaterialPageRoute(builder: (c)=>TaskDashBoard()));
                // }, child: Text('See your Progress'))
          ]),
        ),
      ),
    );
  }
}

class MainOptions extends StatefulWidget {
  const MainOptions({super.key});

  @override
  State<MainOptions> createState() => _MainOptionsState();
}

class _MainOptionsState extends State<MainOptions> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailidController = TextEditingController();
  final _schoolnameController = TextEditingController();

  final _cityController = TextEditingController();

  final _institutenameController = TextEditingController();

  bool loading = false;
  bool shareLoading = false;
  bool profileEdit = false;
  String inputValue = '';

  bool isTap = true;

  Future<void> getData() async {
    var db = FirebaseFirestore.instance;
    String? uid = await getUID();
    DocumentSnapshot userData = await db.collection('Users').doc(uid).get();
    _nameController.text = userData['name'];
    _numberController.text = userData['phoneNumber'];
    _emailidController.text = userData['email'];
    _institutenameController.text = userData['university'];


    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailidController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _institutenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    return loading
        ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ))
        : Column(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isTap == true
                    ? TextButton(
                    onPressed: () async {
                      setState(() {
                        isTap = !isTap;
                        profileEdit = !profileEdit;
                      });
                      setState(() {
                        loading = true;
                      });
                      var db = FirebaseFirestore.instance;
                      String? uid = await getUID();
                      await db.collection('Users').doc(uid).update({
                        'name': _nameController.text,
                        'email': _emailidController.text,
                        'coaching': _institutenameController.text,
                        'city': _cityController.text
                      });
                      setState(() {
                        loading = false;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontFamily: "Montserrat",
                            color: Color(0xFF0A0C19),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 22,
                          color: Color(0xFF0A0C19),
                        )
                      ],
                    ))
                    : TextButton(
                  onPressed: () async {
                    setState(() {
                      isTap = !isTap;
                      profileEdit = !profileEdit;
                    });
                    setState(() {
                      loading = true;
                    });
                    var db = FirebaseFirestore.instance;
                    String? uid = await getUID();
                    await db.collection('Users').doc(uid).update({
                      'name': _nameController.text,
                      'email': _emailidController.text,
                      'university':_institutenameController.text,
                      'phoneNumber': _numberController.text,

                    });
                    setState(() {
                      loading = false;
                    });
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      fontFamily: "Montserrat",
                      color: Color(0xFF0A0C19),
                    ),
                  ),
                ),
              ],
            ),
            ProfileTextFiled(
              controller: _nameController,
              hintText: "Name",
              enabled: profileEdit,
              enabledColor: Colors.red[100]!, // Specify the desired color here
            ),
            ProfileTextFiled(
              controller: _numberController,
              hintText: "Mobile Number",
              enabled: profileEdit,
              enabledColor: Colors.red[100]!, // Specify the desired color here
            ),
            ProfileTextFiled(
              controller: _emailidController,
              hintText: "Email Id",
              enabled: profileEdit,
              enabledColor: Colors.red[100]!, // Specify the desired color here
            ),

            ProfileTextFiled(
              controller: _institutenameController,
              hintText: "Institute",
              enabled: profileEdit,
              enabledColor: Colors.red[100]!, // Specify the desired color here
            ),
            SizedBox(
              height: 5,
            ),

            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.73,
              decoration: BoxDecoration(
                color: Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4c0a0c19),
                    offset: Offset(1, 2),
                    blurRadius: 2.5,
                  ),
                ],
              ),
              child: ListTile(
                // title:
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Time Table",
                      style: TextStyle(
                        color: Color(0xff350257),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        fontFamily: "Montserrat",
                      ),
                    ),
                    // SizedBox(width: MediaQuery.of(context).size.width*0.04,),
                    // SizedBox(width: 20,),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: editOption(context),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primaryColor
                  ),
                  onPressed: () async {
                    _onAlertButtonsPressed(context);
                  },
                  child: const Text('Log out')),
            ),
          ],
        ),
      ],
    );
  }

  _onAlertButtonsPressed(context) {
    Alert(
      context: context,
      type: AlertType.warning,
     style: AlertStyle(
       overlayColor: Colors.grey.withOpacity(0.5),
     ),
      title: "LOGOUT",
      desc: "Do you want to logout ?",
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut().then((value) async {
              //delete uid from getstorage.

             // await removeStringFromPrefs('uid');
              GetStorage().remove('uid');
              await removeStringFromPrefs('timetable_data');
              String todayKey = DateFormat('dMMMyyyy').format(DateTime.now());
              String sa= 'todo_tasks';
              sa+= '_$todayKey';

              await removeStringFromPrefs(sa);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('LogedIn', false);
              timetableController.timetable.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // Remove all routes until now.
              );
            });
          },
          color: AppColors.primaryColor,
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color:  AppColors.primaryColor,
        )
      ],
    ).show();
  }
}

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.of(context).size;
    // final double height = screenSize.height;
    return Container(
      // color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Need Help ",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                // fontFamily: "Montserrat",
                ),
          ),
          SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {
            //  Get.to(() => Contactus());
            },
            child: Text(
              "Contact US",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  // fontFamily: "Montserrat",

                  color: Color(0xFFFF6000)),
            ),
          ),
        ],
      ),
    );
  }
}

editOption(BuildContext context) {
  return TextButton(
      onPressed: () async {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        //TODO: add time table selection screen
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UpdateTimetableScreen()));
      },
      child: Row(
        children: [
          Text(
            "Edit",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              fontFamily: "Montserrat",
              color: Color(0xFF0A0C19),
            ),
          ),
          SizedBox(
            width: 2,
          ),
          Icon(
            Icons.edit_outlined,
            size: 17,
            color: Color(0xFF0A0C19),
          )
        ],
      ));
}

class ProfileTextFiled extends StatelessWidget {
  final controller;
  final String hintText;
  final bool enabled;
  final Color enabledColor;

  const ProfileTextFiled({
    super.key,
    required this.enabledColor,
    required this.controller,
    required this.hintText,
    required this.enabled,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: SizedBox(
        height: 35,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListTile(
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Container(
              decoration: BoxDecoration(
                color: enabled ? enabledColor : Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: enabled ? Colors.white : Color(0x4c0a0c19),
                    offset: Offset(1, 2),
                    blurRadius: 2.5,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  // fontFamily: 'Merriweather',

                  color: enabled
                      ? Color(0xff350257)
                      : Color(0xff60046E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  enabled: enabled,
                  filled: true,
                  fillColor: enabled ? enabledColor : Colors.transparent,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 3, //<-- SEE HERE
                      color: Color.fromARGB(255, 204, 204, 204),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 3, //<-- SEE HERE
                      color: Color.fromARGB(255, 204, 204, 204),
                    ),
                  ),
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    // fontFamily: "Montserrat",

                    color: Color.fromARGB(255, 125, 125, 125),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  hoverColor: const Color(0xff60046E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
