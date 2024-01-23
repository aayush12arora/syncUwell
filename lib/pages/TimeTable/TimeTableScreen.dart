import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/pages/TimeTable/time-tablecontroller.dart';
import 'package:syncuwell/pages/TimeTable/timetabledayform.dart';

class TimetableScreen extends StatefulWidget {
 final UserCredential userCredential;
final String  name;
 final String  email;
   TimetableScreen({ required this.userCredential, required this.name, required this.email});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool loading = false;
  // Ensure TimetableController is properly initialized
  final TimetableController timetableController =
  Get.put(TimetableController(), permanent: true);
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];


  // Firestore collection reference
  final CollectionReference timetableCollection =
  FirebaseFirestore.instance.collection('timetable');


  Future<void> saveTimeTabletoLocalStorage( Map<String, dynamic> documentData) async {
    // Save the timetable data map to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('timetable_data', json.encode(documentData));

  }
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Submit timetable data to Firestore
  Future<void> submitTimetableToFirestore() async {
    try {
      setState(() {
        loading = true;
      });

      final String userName = widget.name;

      Map<String, dynamic> documentData = {
        'name': userName,
      };

      List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

      for (int i = 0; i < days.length; i++) {
        final dayEntries = timetableController.timetable[i];

        if (dayEntries != null && dayEntries.isNotEmpty) {
          documentData[days[i]] = dayEntries.map((entry) => {
            'title': entry.title,
            'startTime': formatTimeOfDay(entry.start_time!),
            'endTime': formatTimeOfDay(entry.endTime!),
            'isPermanent': entry.isPermanent,
          }).toList();
        }
      }

      // TODO: Save timetable data to local storage
       await saveTimeTabletoLocalStorage(documentData);
      await timetableCollection.doc(widget.userCredential.user!.uid).set(documentData);

      print('Timetable data submitted to Firestore!');
      setState(() {
        loading = false;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation(1)));
      });
    } catch (e) {
      print('Error submitting timetable data to Firestore: $e');
      setState(() {
        loading = false;
      });
    }
  }







  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text('Add your time-table entries'),
           SizedBox(width: screenSize.width*0.07,),
            Padding(

              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () async {
                  print('uploading to firestore');
                await  submitTimetableToFirestore();
                },
                child: Container(
                  height: screenSize.height*0.05,
                  width: screenSize.width*0.12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25)
                  ),
                  child: Center(child: IconButton(onPressed: () {     print('uploading to firestore');
                  submitTimetableToFirestore();}, icon: Center(child: Icon(Icons.upload,color: Colors.white,)),)),
                ),
              ),
            ),
          ],
        ),

      ),
      body: loading?Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      ):Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, dayIndex) {
                return TimetableDayFormWidget(dayIndex: dayIndex);
              },
            ),
          ),

        ],
      ),
    );
  }



}

