import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {


  AttendanceScreen();

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
   // Default is present, change as per your requirement
final _studentIdController = TextEditingController();
final _subjectIdController = TextEditingController();
  StudentUid? selectedItem;
  late DateTime selectedDate;
  late bool _isPresent;


  var loading = false;
List<StudentUid>uids=[StudentUid(uid: 'ccbqktdwIOg7YaZGfflu590VFEG2', name:'Aayush'),
  StudentUid(uid: '7QULkBCXsvMMjXSuOZBpD1ntwTs1', name:'Sanidhya'),
  StudentUid(uid: 'KtPwmEWa6mNBGTmiBIf1RxyOC6A3', name:'Subhasri S'),
  StudentUid(uid: '9yVCoRocTIUlimUdArGPAyTjhiP2', name:'Shreya')];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _isPresent = true; // Default is present, change as per your requirement
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
      ),
      body:  loading
          ? Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(
              color: Color(0xff912C2E)),
        ),
      ):Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                    });
                  },
                ),
                Text(
                  'Mark attendance for ${selectedDate}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Present'),
                    Switch(
                      value: _isPresent,
                      onChanged: (value) {
                        setState(() {
                          _isPresent = value;
                        });
                      },
                    ),
                    Text('Absent'),
                  ],
                ),
                SizedBox(height: 20),

                  // Dropdown button widget
                  DropdownButton<StudentUid>(
                    // Value to display in the dropdown button
                    value: selectedItem,
                    // List of items to display in the dropdown menu
                    items: uids.map((StudentUid item) {
                      return DropdownMenuItem<StudentUid>(
                        value: item,
                        child: Text(item.name),
                      );
                    }).toList(),
                    // Called when the user selects an item from the dropdown menu
                    onChanged: (StudentUid? newValue) {
                      setState(() {
                        selectedItem = newValue;
                      });
                    },
                  ),
                  // Display the selected item
                  SizedBox(height: 20),
                  Text(selectedItem != null ? '${selectedItem!.name}' : 'No item selected'),

                SizedBox(height: 20),
                Center(
                  child: TextField(

                    controller: _subjectIdController,
                    decoration: InputDecoration(
                      labelText: 'Sub ID',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if(selectedItem?.uid!=null){
                      String SubID = _subjectIdController.text;
                    await  markAttendance(selectedItem!.uid,SubID);
                    }
                    setState(() {
                      selectedItem=null;
                      _subjectIdController.clear();
                    });

                  },
                  child: Text('Save Attendance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<void> markAttendance(String uid, String SubID) async {
  setState(() {
    loading = true;
  });

  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String formattedDatedoc = DateFormat('yyyy-MM-dd').format(selectedDate);
    DocumentReference subjref = firestore.collection('Attend').doc(uid);

    // Check if the document exists
    DocumentSnapshot subjSnapshot = await subjref.get();
    bool documentExists = subjSnapshot.exists;

    if (!documentExists) {
      // If the document doesn't exist, create it with an empty subjects list
      await subjref.set({'subjects': []});
    }

    // Retrieve subjects list from the document data or initialize an empty list
    List<dynamic> subjectsList = (subjSnapshot.data() as Map<String, dynamic>?)?['subjects'] ?? [];

    // Check if the subject exists in the list
    if (!subjectsList.contains(SubID)) {
      // Add the subject to the list if it doesn't exist
      subjectsList.add(SubID);
      // Update the Firestore document with the updated list of subjects
      await subjref.update({'subjects': subjectsList});
      print('Subject added to the list.');
    } else {
      print('Subject already exists in the list.');
    }

    // Reference to the attendance record document for the selected date
    DocumentReference attendanceRef = firestore
        .collection('Attendance')
        .doc(uid)
        .collection('Subjects')
        .doc(SubID)
        .collection('Records')
        .doc(formattedDatedoc);

    // Set attendance record
    await attendanceRef.set({'present': _isPresent});

    // Update loading state and show success message
    setState(() {
      loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked successfully!'),
      ),
    );
  } catch (error) {
    // Handle errors
    setState(() {
      loading = false;
    });
    print('Error marking attendance: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to mark attendance. Please try again.'),
      ),
    );
  }
}

}


class StudentUid{
  final String uid;
  final String name;
  StudentUid({required this.uid,required this.name});
}


