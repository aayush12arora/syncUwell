import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/pages/TimeTable/planner-time-table-screen.dart';
import 'package:syncuwell/pages/TimeTable/updateTimeTableScreen.dart';
import 'package:syncuwell/pages/Todays-Tasks/todays-task.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';
import 'package:syncuwell/pages/tracker/dashboard.dart';
import 'dart:math';

import '../../Utils/headerfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
bool loading = false;
  String? name ;
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
    setState(() {
loading= false;
    });
    // Return null if the document doesn't exist or 'name' field is missing
  }
  final List<String> _randomLabels = [

    'Progress',
    'TimeTable',

    'Personalized Planners',
   'Todo'
  ];

  final List<String> assetname = [

    'Research.png',
    'Schedule.png',
    'Student.png',
    'Student.png',

  ];

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
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 75),
          child: HeaderL(),
        ),
        body: Container(
          margin:  EdgeInsets.all(20),
          padding: EdgeInsets.all(10),
          height: screenSize.height * 0.7,
          width: screenSize.width * 0.9,
          decoration: BoxDecoration(
            color: Color(0xffd9e3f1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Good Evening ${name},",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
              Container(
               margin:  EdgeInsets.only(top: 19),
                padding: EdgeInsets.all(4),
                height: screenSize.height * 0.47,
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  //color: Colors.redAccent
                   color: Color(0xffd9e3f1),
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 19.0,
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
                      },
                      child: GridItem(
                       assetName: assetname[index % _randomIcons.length],
                        label: _randomLabels[index % _randomLabels.length],
                      ),
                    );
                  },
                ),
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String todayKey = DateFormat('dMMMyyyy').format(DateTime.now());
                String sa= 'todo_tasks';
                sa+= '_$todayKey';

                prefs.remove(sa);
              },
              child: Container(
                  margin: EdgeInsets.only(top: 20,left: 2,right: 15),
                  height: 55,
                  width: screenSize.width*0.55,
                  decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(25)),

                  child: Center(
                    child: Text(
                      "Ask me Anything",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  )
              ),
            ),

            Container(
                margin: EdgeInsets.only(top: 20,left: 2,right: 5),
                height: 65,
                width: screenSize.width*0.15,
                decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(15)),

                child: Center(
                  child: Icon(Icons.headset_mic_rounded,color: Colors.white,),
                )
            ),
          ],


        )
            ],
          ),
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
            height: 70,
            width: 70,
          ),
          SizedBox(height: 8),
          Text(label,textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}
