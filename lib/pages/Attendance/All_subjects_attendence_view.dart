import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/models/AttendanceModel.dart';
import 'package:syncuwell/models/classModel.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';


class AllSubjectAttendancePage extends StatefulWidget {
  const AllSubjectAttendancePage({super.key});

  @override
  State<AllSubjectAttendancePage> createState() => _AllSubjectAttendancePageState();
}

class _AllSubjectAttendancePageState extends State<AllSubjectAttendancePage> {
  List<ClassModel> classes = [];
  late DateTime selectedDate;
  late bool _isPresent;
  bool loading = false;

  List<Map<String, dynamic>> subjectData = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    selectedDate = DateTime.now();
    _isPresent = true;
    fetchAttendanceRecords('CSD111', DateTime.now());
    fetchSubjectData();

  }



  Future<void> fetchSubjectData() async {
    setState(() {
      loading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      String? uid = await getUID();

      // Get the reference to the subjects document
      DocumentReference subjref = firestore.collection('Attend').doc(uid);

      // Check if the document exists
      DocumentSnapshot subjectsSnapshot = await subjref.get();
      if (!subjectsSnapshot.exists) {
        // If the document doesn't exist, clear subjectData and return
        subjectData.clear();
        setState(() {
          loading = false;
        });
        return;
      }

      // Extract data from the document
      Map<String, dynamic> data = subjectsSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subjectsList = (data['subjects'] as List<dynamic>);

      // Clear subjectData before populating it with new data
      subjectData.clear();

      // Iterate through each subject and fetch attendance records
      for (var subject in subjectsList) {
        // Get attendance records for the current subject
        QuerySnapshot attendanceRecordsSnapshot = await firestore
            .collection('Attendance')
            .doc(uid)
            .collection('Subjects')
            .doc(subject)
            .collection('Records')
            .get();

        print('Attendance records snapshot for $subject: ${attendanceRecordsSnapshot.docs.length} documents');

        // Convert attendance records to a list of data maps
        List<Map<String, dynamic>> attendanceRecords = attendanceRecordsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Calculate attendance percentage
        double attendancePercentage = calculateAttendancePercentage(attendanceRecords);

        // Add subject data to the subjectData list
        subjectData.add({
          'subject': subject,
          'attendance': attendancePercentage,
        });
      }

      // Update loading state
      setState(() {
        loading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error fetching subject data: $error');
      setState(() {
        loading = false;
      });
    }
  }


  double calculateAttendancePercentage(List<Map<String, dynamic>> attendanceRecords) {
    final totalRecords = attendanceRecords.length;
    final attendedRecords = attendanceRecords.where((record) => record['present'] == true).length;

    if (totalRecords == 0) {
      return 0.0; // Avoid division by zero
    }

    return (attendedRecords / totalRecords) * 100;
  }















  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Attendance Records'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: loading
                ? Center(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: const CircularProgressIndicator(
                    color: Color(0xff912C2E)),
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  loading = true;
                });
                await fetchSubjectData();

              },
              child: Container(
                height: height * 0.8,
                width: width * 0.88,
                child: ListView.builder(
                    itemCount:subjectData.length,
                    itemBuilder: (context, index) {
                      final attendance = subjectData[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            showAttendanceDetailsDialog(context,attendance['subject'] );
// if face matching has already been done

                          },
                          child: ClassCard(
                            atten_percent:
                            attendance['attendance'],
                            classm:attendance['subject'] ,
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ));
  }



  void showAttendanceDetailsDialog(BuildContext context, String subject) {
    showDialog(

      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(1),

             child: Container(
                width: MediaQuery.of(context).size.width * 0.87, // Adjust the width as needed
                height: MediaQuery.of(context).size.height * 0.79, // Adjust the height as needed
                padding: EdgeInsets.all(10),
                child: FutureBuilder(
                  future: fetchAttendanceRecords(subject, selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while fetching data
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Map<String, dynamic>> attendanceRecords = snapshot.data as List<Map<String, dynamic>>;
                      return Column(
                        children: [
                          Text('Attendance Details for $subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.now(),
                            focusedDay: selectedDate,
                            selectedDayPredicate: (day) {
                              return isSameDay(selectedDate, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                selectedDate = selectedDay;
                              });
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Color(0xffff914d), // Color for today's date
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.blue, // Color for the selected date
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'Attendance for ${DateFormat('MMM d, yyyy').format(selectedDate)}:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Table(
                              border: TableBorder.all(),
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Date'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Attendance'),
                                      ),
                                    ),
                                  ],
                                ),
                                // Populate table with attendance records
                                for (var record in attendanceRecords)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(record['present'] ? 'Present' : 'Absent',style: TextStyle(color:record['present']?Colors.green:Colors.redAccent),),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

            );
          },
        );
      },
    );
  }


  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(String subject, DateTime date) async {
    String? uid = await getUID();
    final firestore = FirebaseFirestore.instance;

    // Format the date to match the document ID format
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    print('formattedDate:$formattedDate');
    final attendanceRecordsSnapshot = await firestore
        .collection('Attendance')
        .doc(uid)
        .collection('Subjects')
        .doc(subject)
        .collection('Records')
        .doc(formattedDate) // Use the formatted date as the document ID
        .get();

    // Check if the document exists
    if (attendanceRecordsSnapshot.exists) {
      // If the document exists, return its data
      print('here');
      return [attendanceRecordsSnapshot.data() as Map<String, dynamic>];
    } else {
      // If the document doesn't exist, return an empty list
      print('notihng');
      return [];
    }
  }


}



class ClassCard extends StatefulWidget {
  final String classm;
  final num atten_percent;

  ClassCard({required this.classm, required this.atten_percent});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(17)),
      height: height * 0.12,
      child: Center(
        child: ListTile(
          leading: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.grey,
            child: Icon(Icons.edit_calendar_outlined, color: Colors.white),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              widget.classm,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              widget.classm,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          trailing: Container(
            width: width * 0.22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Center vertically
              children: [
                CircularPercentIndicator(
                  radius: height * 0.024, // Adjusted for responsiveness
                  lineWidth: 4.0,
                  percent: widget.atten_percent / 100,
                  center: Text(
                    widget.atten_percent.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  progressColor: Colors.green,
                ),
                SizedBox(width: 12),

              ],
            ),
          ),
        ),
      ),
    );
  }

  //dialog box


}