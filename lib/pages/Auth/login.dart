import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/pages/Auth/sign_Up_Page.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late FToast flutterToast;

  bool loading = false;
  @override
  void initState() {
    super.initState();
    flutterToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    flutterToast.init(context);
  getLoggedInStatus();
  }



  _showToast(String s) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        children: [
          Icon(Icons.mail),
          SizedBox(width: 6.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width, // Adjust as needed
                  child: Text(
                    s, // Your text here
                    maxLines: 5,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    flutterToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );

    // Custom Toast Position
    flutterToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 5),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 16.0,
            left: 16.0,
          );
        });
  }



  Future<void> saveTimeTabletoLocalStorage( Map<String, dynamic> documentData) async {
    // Save the timetable data map to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving timetable data to local storage');
    print('Timetable Data: ${json.encode(documentData)}');
    prefs.setString('timetable_data', json.encode(documentData));

  }



  // Firestore collection reference
  final CollectionReference timetableCollection =
  FirebaseFirestore.instance.collection('timetable');
  String userid= '';// fetch it
  Future<void> fetchTimetableFromFirestore(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await timetableCollection.doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

      await  saveTimeTabletoLocalStorage(documentData);

        String userName = documentData['name'];
        print('User Name: $userName');

        List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

        for (String day in days) {
          if (documentData.containsKey(day)) {
            List<Map<String, dynamic>> dayEntries = List<Map<String, dynamic>>.from(documentData[day]);
            print('$day Entries: $dayEntries');

            // Now you can use dayEntries as needed
          }
        }

        print('Timetable data fetched from Firestore!');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching timetable data from Firestore: $e');
    }
  }
  Future<void> getLoggedInStatus() async {
    setState(() {
      loading= true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status =prefs.getBool('LogedIn') ?? false;
    if(status){
      setState(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomNavigation(1)));
        loading= false;
      });

    }else{
      setState(() {
        loading= false;
      });
    }
  }
  Future<void> saveUID(String uid) async {
    // Save the timetable data map to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);

  }

  Future<void> setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('LogedIn', true);
  }

  Future<void> loginUser() async {
    try {
      setState(() {
        print('login user called');
        loading = true;
      });

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the user's email is verified
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        GetStorage().write('uid', userCredential.user!.uid);
        await saveUID(uid);
        print('User UID: $uid');
        // Successfully logged in and email is verified
        await setLoggedIn();

        await fetchTimetableFromFirestore(uid);

        // Move setState outside the asynchronous block
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNavigation(1)),
          );
          loading = false;
        });
      } else {
        // Email is not verified
        _showToast("Please enter valid credentials");
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Error during login: $e");
      _showToast("Login failed. Please check your credentials.");
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(color: Colors.black),
        ),
      )
          : SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: height * .07),

              Container(

                child: Image.asset(
                  'assets/Logo black.png',
                  width: width * 0.6,
                  height: height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: 60,
                width: 360,
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ),
              SizedBox(
                height: height * .005,
              ),
              // Email Field
              Container(
                margin: EdgeInsets.only(left: 55, right: 55),
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: TextFormField(
                    controller: _emailController,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      fillColor: AppColors.primaryColor,
                      filled: true,
                      // errorStyle: TextStyle(height: 0.5),
                      hintStyle: TextStyle(color: Color(0xB310100E)),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .02,
              ),

              // Password Text Field
              Container(
                margin: EdgeInsets.only(left: 55, right: 55),
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: TextFormField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      fillColor: AppColors.primaryColor,
                      filled: true,
                      hintStyle: TextStyle(color: Color(0xB310100E)),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .012,
              ),

// Login Button
              InkWell(
                onTap: () async {
                await loginUser();
                },
                child: Container(
                  margin: EdgeInsets.only(left: 55, right: 55),
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      "Log In",
                      style:
                     const TextStyle(
                            color:Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),

                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .007,
              ),
              // Change Password  Button
              InkWell(
                onTap: () {
               //   Get.to(() => ChangePassword());
                },
                child: Text(
                  "Forgot password?",
                  style:
            const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),

                ),
                // child: Container(
                //   margin: EdgeInsets.only(left: 55, right: 55),
                //   height: 40,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(25),
                //   ),
                //   child: Center(
                //     child: Text(
                //       "Forgot Password?",
                //       style: GoogleFonts.poppins(
                //         textStyle: const TextStyle(
                //             decoration: TextDecoration.underline,
                //             color: AppColors.primaryColor,
                //             fontSize: 20,
                //             fontWeight: FontWeight.w400),
                //       ),
                //     ),
                //   ),
                // ),
              ),
              SizedBox(
                height: height * .04,
              ),
              //Sign Up Button
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()));
                },
                child: Text(
                  "Sign-Up",
                  style:
                  const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),

                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              // Continue as guest button
              // InkWell(
              //   onTap: () {
              //     Navigator.pushReplacement(
              //         context,
              //         MaterialPageRoute(
              //             builder: (_) => BottomNavigation(0)));
              //   },
              //   child: Text(
              //     "Continue as guest",
              //     style: const TextStyle(
              //           decoration: TextDecoration.underline,
              //           color: Colors.black,
              //           fontSize: 16,
              //           fontWeight: FontWeight.w400),
              //
              //   ),
              // ),
              Container(
                height: height * 1,
                width: width,
                // child: Stack(
                //   children: [
                //     Positioned(
                //       top: height * 0.31,
                //       child: Image.asset(
                //         'assets/blackbg.png',
                //         width: width,
                //         height: height * .5,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     Positioned(
                //       top: height * 0.31,
                //       child: Image.asset(
                //         'assets/appbarback.png',
                //         width: width,
                //         height: height * .2,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     Positioned(
                //       top: height * .015,
                //       left: width * 0.07,
                //       child: Image.asset(
                //         'assets/runner.png',
                //         width: width * 0.9,
                //         height: height * 0.5,
                //         fit: BoxFit.contain,
                //       ),
                //     ),
                //   ],
                // ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
