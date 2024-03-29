import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/Utils/popup.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/pages/Attendance/All_subjects_attendence_view.dart';
import 'package:syncuwell/pages/Attendance/markAttendace.dart';
import 'package:syncuwell/pages/TimeTable/planner-time-table-screen.dart';
import 'package:syncuwell/pages/TimeTable/updateTimeTableScreen.dart';
import 'package:syncuwell/pages/Todays-Tasks/todays-task.dart';
import 'package:syncuwell/pages/imp-question-Answers/question-answer.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';
import 'package:syncuwell/pages/tracker/dashboard.dart';
import 'dart:math';
import 'package:syncuwell/pages/imp-question-Answers/select-Subject.dart';
import '../../Utils/headerfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
bool loading = false;
  String? name ;
  String tiptoDisplay = "Welcome to Syncuwell";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }




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
        name = data['name'];

      }
    }
QuerySnapshot tipssnapshot = await db.collection('tips').get();
List<DocumentSnapshot> tips = tipssnapshot.docs;
// Check if the document exists and has data before accessing 'name' field
if (tipssnapshot.docs.isNotEmpty) {
  int randomIndex = Random().nextInt(tips.length);
  DocumentSnapshot randomtip = tips[randomIndex];

  // Access the random document data
  Map<String,dynamic> tipmap = randomtip.data() as Map<String, dynamic>;
  tiptoDisplay = tipmap['tip'];
}
    setState(() {
loading= false;
    });
    // Return null if the document doesn't exist or 'name' field is missing
  }
  final List<String> _randomLabels = [

    'Progress',
    'TimeTable',

    'Personalized Planners',
   'Todo',
    'Mark Attendance',
    'See Attendance',
    'Flash Cards'
  ];

  final List<String> assetname = [

    'progress-report.png',
    'timetable.png',
    '7-days.png',
    'list.png',
    'Quiz.png',
    'people.png',
   'flash-cards.png'

  ];
bool _isPopupVisible = true;
  final List<IconData> _randomIcons = [
    Icons.bar_chart_rounded,
    Icons.favorite,
    Icons.music_note,
    Icons.camera,
    Icons.games,
    Icons.lightbulb,
    Icons.directions_run,
    Icons.shopping_cart,
    Icons.movie,
  ];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child:  loading
          ? Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(color: Colors.black),
        ),
      )
          :Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 75),
          child: HeaderL(),
        ),
        body: Stack(
          children: [
            Container(
              margin:  EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              height: screenSize.height * 0.7,
              width: screenSize.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Hello, ${name}",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                  Container(
                   margin:  EdgeInsets.only(top: 19),
                    padding: EdgeInsets.all(2),
                    height: screenSize.height * 0.47,
                    width: screenSize.width * 0.9,
                    decoration: BoxDecoration(
                      //color: Colors.redAccent
                       color: Colors.white,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.3,
                        mainAxisSpacing: 39.0,
                      ),
                      itemCount: _randomLabels.length, // 3 rows x 3 columns
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){
                            if(index==3){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>TaskListView()));
                             } else if(index==0){
                                Navigator.push(context, MaterialPageRoute(builder: (r)=>TaskDashBoard()));
                            }
                            else if(index==1){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>UpdateTimetableScreen()));
                            }
                            else if(index==2){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>PlannerTimetableScreen()));
                            }
                            else if(index==4){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>AttendanceScreen()));
                            }
                            else if(index==5){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>AllSubjectAttendancePage()));
                            }
                            else if(index==6){
                              Navigator.push(context, MaterialPageRoute(builder: (r)=>SelectSubject()));
                            }
                          },
                          child: GridItem(
                           assetName: assetname[index % _randomIcons.length],
                            label: _randomLabels[index % _randomLabels.length],
                          ),
                        );
                      },
                    ),
                  ),
            Container(
margin: EdgeInsets.only(top:15,left: 2,right: 15) ,
              height: screenSize.height*0.07,
              decoration: BoxDecoration(
                  color: Color(0xffff914d),
                borderRadius: BorderRadius.circular(25)),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                 Navigator.push(context, MaterialPageRoute(builder: (r)=>BottomNavigation(2)));
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 2,right: 15),
                        height: 55,
                        width: screenSize.width*0.55,
                        decoration: BoxDecoration(
                            color:Color(0xffff914d),
                            borderRadius: BorderRadius.circular(25)),

                        child: Center(
                          child: Text(
                            "Ask me Anything",
                            style: TextStyle(fontSize: 20,color: Colors.black),
                          ),
                        )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Image.asset('assets/bot.png',
                      height: 40,
                      width: 40,
                    )
                  )

                  //TODO bot logo in this mic and extended


                ],


              ),
            )
                ],
              ),
            ),
            if (_isPopupVisible) ...[
              // Blur and darken background
              Container(
                color: Colors.black.withOpacity(0.5), // Adjust opacity for darkness
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              // Popup message
              Positioned(
top: screenSize.height * 0.425,
                left: screenSize.width * 0.06,
                right: screenSize.width * 0.06,

                child: PopupMessage(
                  message:
                  tiptoDisplay,
                  onClose: () {
                    setState(() {
                      _isPopupVisible = false;
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final String assetName;
  final String label;

  const GridItem({required this.assetName, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // color: Colors.yellowAccent[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/$assetName',
            height: 60,
            width: 60,
          ),
          SizedBox(height: 8),
          Text(label,textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}
