import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncuwell/Utils/headerfile.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';

class TaskDashBoard extends StatefulWidget {
  const TaskDashBoard({Key? key}) : super(key: key);

  @override
  State<TaskDashBoard> createState() => _TaskDashBoardState();
}

class _TaskDashBoardState extends State<TaskDashBoard> {


  Future<Map<String, dynamic>> getWeeklyData(DateTime startDate, DateTime endDate) async {
    String? userId = await getUID();

    List<Map<String, dynamic>> mappings = [];
    QuerySnapshot weeklyQuery = await FirebaseFirestore.instance
        .collection('Daily_Tracker')
        .doc(userId)
        .collection('completed_tasks')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    List<Map<String, dynamic>> weeklyTasks = [];
  //  for (DateTime date = startDate; date.isBefore(endDate); date = date.add(Duration(days: 1))) {
    for (QueryDocumentSnapshot document in weeklyQuery.docs) {
      dynamic data = document.data();
      // print('Data from Firestore: $data');
      // // print('dates  ${data['date']}');
      // Timestamp timestamp = data['date'];
      // DateTime dateTime = timestamp.toDate();
     //  print('server datetime $dateTime');
// if(dateTime.day == date.day) {
//   print('matchng');
//   print('server datetime $dateTime');
//         }

      if (data['tasks'] is List) {
      //  print('data hai date ${date} ka' );
          weeklyTasks.addAll(
            (data['tasks'] as List).cast<Map<String, dynamic>>());
          mappings.add(data);
      }
    }
  //}
  print('mapping $mappings');
    Map<String, dynamic> weeklyData = {'tasks': weeklyTasks};

    DateTime date = startDate  ;

    for (int i = 0; i < mappings.length&&date.isBefore(endDate); i++, date = date.add(Duration(days: 1))) {
      if(mappings[i]['date'].toDate().day == date.day) {
        print('matchng');
        print('server datetime ${mappings[i]['date'].toDate()}');
        // weeklyTasks.addAll(
        //     (mappings[0]['tasks'] as List).cast<Map<String, dynamic>>());
      }else{
        print('we ${date.weekday}');
      }
      // Timestamp timestamp = ['date'];
      // DateTime dateTime = timestamp.toDate();
    }




    return weeklyData;
  }

  Future<Map<String, dynamic>> getMonthlyData(DateTime date) async {
    String? userId = await getUID();
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    QuerySnapshot monthlyQuery = await FirebaseFirestore.instance
        .collection('Daily_Tracker')
        .doc(userId)
        .collection('completed_tasks')
        .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('date', isLessThanOrEqualTo: lastDayOfMonth)
        .get();

    List<Map<String, dynamic>> monthlyTasks = [];
    for (QueryDocumentSnapshot document in monthlyQuery.docs) {
      dynamic data = document.data();

      if (data['tasks'] is List) {
        monthlyTasks.addAll((data['tasks'] as List).cast<Map<String, dynamic>>());
      }
    }

    Map<String, dynamic> monthlyData = {'tasks': monthlyTasks};
    print('Monthly Data: $monthlyData');
    return monthlyData;
  }

  Future<Map<String, dynamic>> getDailyData(DateTime date) async {
    String? userId = await getUID();
    String todayKey = DateFormat('d MMM yyyy').format(date);

    DocumentSnapshot dailySnapshot = await FirebaseFirestore.instance
        .collection('Daily_Tracker')
        .doc(userId)
        .collection('completed_tasks')
        .doc(todayKey)
        .get();

    Map<String, dynamic>? dailyData = dailySnapshot.data() as Map<String, dynamic>?;

    // Ensure that 'tasks' is not null and is of the correct type
    List<Map<String, dynamic>> dailyTasks = dailyData?['tasks'] != null
        ? List<Map<String, dynamic>>.from(dailyData!['tasks'])
        : [];

    // Update dailyData with the correctly typed 'tasks' field
    dailyData?['tasks'] = dailyTasks;


    return dailyData ?? {};
  }


  Future<Column> generateCompletionPercentagePieChart(Map<String, dynamic> data,int threshold) async {
    List<Map<String, dynamic>> tasks = data['tasks'] ?? [];

    int checkedCount = tasks.where((task) => task['isChecked'] == true).length;
    int uncheckedCount = tasks.where((task) => task['isChecked'] == false).length;

    List<DoughnutSeries<Map<String, dynamic>, String>> series = [
     DoughnutSeries<Map<String, dynamic>, String>(
        dataSource: [
          {'label': 'Complete', 'value': checkedCount},
          {'label': 'Incomplete', 'value': uncheckedCount},
        ],
        xValueMapper: (Map<String, dynamic> task, _) => task['label'] ?? '',
        yValueMapper: (Map<String, dynamic> task, _) => task['value'] ?? 0,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        // Specify colors for each data point
        pointColorMapper: (Map<String, dynamic> task, _) {
          if (task['label'] == 'Complete') {
            return Color(0xff7ed957).withOpacity(0.5); // You can use any color here
          } else if (task['label'] == 'Incomplete') {
            return Color(0xffff914d).withOpacity(0.5); // You can use any color here
          }
          return Colors.grey; // Default color for other cases
        },
        // You can customize other properties such as dataLabel, etc.
     name: "Task Completion Percentage",

      ),
    ];

    return Column(
      children: [
        SfCircularChart(series: series,legend: Legend(isVisible: true),),

        checkedCount>=threshold?Text(
          'Great ! You have completed: ${checkedCount} tasks ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.green),
        ):Text(
          'You missed the target of ${threshold} tasks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.redAccent)
        ),
        SizedBox(height: 10,),
        Text(
          'Completion Percentage: ${((checkedCount / tasks.length) * 100).toStringAsFixed(2)}%',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

      ],
    );
  }


  DateTime currentDate = DateTime.now();
  String todayKey = DateFormat('d MMM yyyy').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size(width, 75),
          child: HeaderL(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Monthly Completion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: getMonthlyData(currentDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print('Error in getMonthlyData: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return FutureBuilder<Column>(
                        future: generateCompletionPercentagePieChart(snapshot.data!,30),
                        builder: (context, chartSnapshot) {
                          if (chartSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (chartSnapshot.hasError) {
                            print('Error in chartSnanpshot of montly data: ${chartSnapshot.error}');
                            return Text('Error: ${chartSnapshot.error}');

                          } else {
                            return chartSnapshot.data!;
                          }
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Weekly Completion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: getWeeklyData(currentDate.subtract(Duration(days: 7)), currentDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print('Error in getWeeklyData: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');

                    } else {
                      return FutureBuilder<Column>(
                        future: generateCompletionPercentagePieChart(snapshot.data!,7),
                        builder: (context, chartSnapshot) {
                          if (chartSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (chartSnapshot.hasError) {
                            print('Error: ${chartSnapshot.error}');
                            return Text('Error: ${chartSnapshot.error}');
                          } else {
                            return chartSnapshot.data!;
                          }
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daily Completion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: getDailyData(currentDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return FutureBuilder<Column>(
                        future: generateCompletionPercentagePieChart(snapshot.data!,1),
                        builder: (context, chartSnapshot) {
                          if (chartSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (chartSnapshot.hasError) {
                            print('Error: ${chartSnapshot.error}');
                            return Text('Error: ${chartSnapshot.error}');
                          } else {
                            return chartSnapshot.data!;
                          }
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
