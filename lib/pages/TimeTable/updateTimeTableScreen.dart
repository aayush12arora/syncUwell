import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/models/timetable.dart';
import 'package:syncuwell/pages/TimeTable/time-tablecontroller.dart';
import 'package:syncuwell/pages/TimeTable/timetabledayform.dart';
import 'package:syncuwell/pages/TimeTable/update-time-table-day-form.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';

class UpdateTimetableScreen extends StatefulWidget {


  @override
  State<UpdateTimetableScreen> createState() => _UpdateTimetableScreenState();
}

class _UpdateTimetableScreenState extends State<UpdateTimetableScreen> {
  bool loading = false;
  // Ensure TimetableController is properly initialized
  final TimetableController timetableController =
  Get.put(TimetableController(), permanent: true);
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
String name="";
String email="";
String? uid="";
  // Firestore collection reference

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }


  final CollectionReference timetableCollection =
  FirebaseFirestore.instance.collection('timetable');

  Future<void> getData() async {
    setState(() {
      loading=true;
    });
    var db = FirebaseFirestore.instance;
   uid = await getUID();
    DocumentSnapshot userData = await db.collection('Users').doc(uid).get();
    name = userData['name'];

    email = userData['email'];


await fetchTimetableFromFirestore(uid!);
    setState(() {
      loading = false;
    });
  }






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



  Future<void> fetchTimetableFromFirestore(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await timetableCollection.doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

        List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

        for (String day in days) {
          if (documentData.containsKey(day)) {
            List<Map<String, dynamic>> dayEntries = List<Map<String, dynamic>>.from(documentData[day]);

            List<Timetable> timetableEntries = dayEntries.map((entry) {
              List<String> startTimeParts = entry['startTime'].split(':');
              List<String> endTimeParts = entry['endTime'].split(':');

              TimeOfDay startTime = TimeOfDay(
                hour: int.parse(startTimeParts[0]),
                minute: int.parse(startTimeParts[1]),
              );

              TimeOfDay endTime = TimeOfDay(
                hour: int.parse(endTimeParts[0]),
                minute: int.parse(endTimeParts[1]),
              );

              return Timetable(
                title: entry['title'],
                start_time: startTime,
                endTime: endTime,
                isPermanent: entry['isPermanent'],
              );
            }).toList();

            int dayIndex = days.indexOf(day);

            // Check if the timetableController.timetable list exists
            if (timetableController.timetable.length <= dayIndex) {
              timetableController.timetable.add(<Timetable>[]); // Initialize the list if it doesn't exist
            }

            // Add timetable entries to the list
            if (timetableController.timetable[dayIndex].length == 0) {
              timetableController.timetable[dayIndex].addAll(timetableEntries);
              timetableController.update();
            }
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


  // Submit timetable data to Firestore
  Future<void> submitTimetableToFirestore() async {
    try {
      setState(() {
        loading = true;
      });

      final String userName = name;

      Map<String, dynamic> documentData = {
        // 'name': userName,
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
            'date': DateTime.now().toIso8601String(),
          }).toList();
        }
      }

      // TODO: Save timetable data to local storage
      await saveTimeTabletoLocalStorage(documentData);
      await timetableCollection.doc(uid).set(documentData);

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
      appBar: AppBar(     backgroundColor: Color(0xffff914d),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text('Update Entries'),
            SizedBox(width: screenSize.width*0.23,),
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
                      color: Colors.black,
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
                return UpdateTimetableDayFormWidget(dayIndex: dayIndex);
              },
            ),
          ),

        ],
      ),
    );
  }



}

