import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Utils/headerfile.dart';

class TaskListView extends StatefulWidget {
  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool loading = false;
  Map<String, dynamic> tasks = {};

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timetableDataString = prefs.getString('timetable_data');
    tasks = json.decode(timetableDataString!);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (loading) {
      // Display a circular loading indicator while waiting for data
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // Get the current day as an integer (1 for Monday, 2 for Tuesday, ..., 7 for Sunday)
      int currentDayIndex = DateTime.now().weekday;

      // Map the current day index to its corresponding name
      String currentDay;
      switch (currentDayIndex) {
        case 1:
          currentDay = 'monday';
          break;
        case 2:
          currentDay = 'tuesday';
          break;
        case 3:
          currentDay = 'wednesday';
          break;
        case 4:
          currentDay = 'thursday';
          break;
        case 5:
          currentDay = 'friday';
          break;
        case 6:
          currentDay = 'saturday';
          break;
        case 7:
          currentDay = 'sunday';
          break;
        default:
          currentDay = 'unknown';
      }

      // Check if the tasks contain data for the current day
      if (tasks.containsKey(currentDay)) {
        // Filter tasks for today
        List<Map<String, dynamic>> todayTasks = List<Map<String, dynamic>>.from(tasks[currentDay]);

        return SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(screenSize.width, 75),
              child: HeaderL(),
            ),
            backgroundColor: Colors.white,
            body: Column(
              children: [
                SizedBox(height: screenSize.height*0.03,),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.sizeOf(context).height*0.7,
                    child: ListView.builder(
                      itemCount: todayTasks.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> task = todayTasks[index];
                        bool isPermanent = task['isPermanent'];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isPermanent ?Colors.greenAccent: Colors.redAccent,
                            ),
                            child: ListTile(
                              tileColor:  isPermanent ?Colors.greenAccent: Colors.redAccent,

                              title: Text(task['title']),
                              subtitle: Text('${task['startTime']} - ${task['endTime']}'),
                              trailing: Icon(
                                isPermanent ? Icons.event_available : Icons.not_interested,
                                color: isPermanent ? Colors.green : Colors.red[200],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0), // Set your desired border radius
                                side: BorderSide(
                                  // Set your desired border color
                                  width: 1.0, // Set your desired border width
                                ),
                              ),

                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Return a message when no tasks are available for today
        return Center(
          child: Text('No tasks available for today.'),
        );
      }
    }
  }
}
