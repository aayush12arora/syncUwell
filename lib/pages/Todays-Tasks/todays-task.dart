import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/Utils/headerfile.dart';
import 'package:syncuwell/models/timetable.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';

class TaskListView extends StatefulWidget {
  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool loading = false;
  Map<String, dynamic> tasks = {};
  AudioPlayer audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> todayTasks=[];

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timetableDataString = prefs.getString('timetable_data');
    //String todayKey = DateTime.now().toString();

    String todayKey = DateFormat('dMMMyyyy').format(DateTime.now());
    String sa= 'todo_tasks';
    sa+= '_$todayKey';
    print('todayKey $sa');
    String? todayTasksString = prefs.getString(sa);

    // Check if there are any tasks for today in stored data
    tasks = json.decode(timetableDataString!);
    print('timeTableData $tasks');
    print('todaystaskstring $todayTasksString');
    tasks[currentDay]!=null?todayTasks = List<Map<String, dynamic>>.from(tasks[currentDay]):todayTasks=[];
   // todayTasks = List<Map<String, dynamic>>.from(tasks[currentDay]);

    // Initialize the isChecked property for each task
    todayTasks.forEach((task) {
      task['isChecked'] = false;
    });

    // Compare tasks from timetable data and update stored tasks if needed
    List<dynamic> storedTasks =
    todayTasksString != null ? json.decode(todayTasksString) : [];
    List<Map<String, dynamic>> storedTodayTasks =
    List<Map<String, dynamic>>.from(storedTasks);

    print('storedTodayTasks $storedTodayTasks');
    if (storedTodayTasks.isNotEmpty) {
      for (int i = 0; i < todayTasks.length; i++) {
        if (i < storedTodayTasks.length &&
            storedTodayTasks[i]['isPermanent'] == todayTasks[i]['isPermanent']&&
        storedTodayTasks[i]['startTime'] == todayTasks[i]['startTime'] &&
            storedTodayTasks[i]['endTime'] == todayTasks[i]['endTime'] &&
            storedTodayTasks[i]['title'] == todayTasks[i]['title']) {
          print('Task already exists: ${todayTasks[i]}');
        } else {
          if (i < storedTodayTasks.length &&
              storedTodayTasks[i]['title'] == todayTasks[i]['title']) {
            // Check if any other attribute is different
            if (storedTodayTasks[i]['isPermanent'] != todayTasks[i]['isPermanent'] ||
                storedTodayTasks[i]['startTime'] != todayTasks[i]['startTime'] ||
                storedTodayTasks[i]['endTime'] != todayTasks[i]['endTime']) {
              print('Updating task: ${todayTasks[i]}');
              storedTodayTasks[i] = todayTasks[i]; // Update the entry
            }
          } else {
            print('Task added: ${todayTasks[i]}');
            storedTodayTasks.add(todayTasks[i]);
          }

        }
      }
    } else {
      storedTodayTasks.addAll(todayTasks);
    }

    todayTasks.clear();
    todayTasks = List<Map<String, dynamic>>.from(storedTodayTasks);
    print('todaystaks $storedTodayTasks');

    prefs.setString(sa, json.encode(storedTodayTasks));

    setState(() {
      loading = false;
    });
  }


  Future<void> markTaskCompleted(Map<String, dynamic> task, bool isChecked) async {
    // Update the task status
    task['isChecked'] = isChecked;
    String todayKey = DateFormat('dMMMyyyy').format(DateTime.now());
    String sa= 'todo_tasks';
    sa+= '_$todayKey';
    // Store the updated tasks locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(sa);

    // Update the task in the list
    int index = todayTasks.indexWhere((t) =>
    t['title'] == task['title'] &&
        t['startTime'] == task['startTime'] &&
        t['endTime'] == task['endTime']);

    if (index != -1) {
      todayTasks[index]['isChecked'] = isChecked;
      prefs.setString(sa, json.encode(todayTasks));
    }
    await updateFirestore(todayTasks);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> playSound() async {
    await audioPlayer.play(AssetSource("completed.mp3"));

  }



  Future<void> updateFirestore(List<Map<String, dynamic>> tasks) async {
    CollectionReference tasksCollection =
    FirebaseFirestore.instance.collection('Daily_Tracker');

    // Assuming you have a unique identifier for each user, replace 'USER_ID' with the actual user ID
    String? userId = await getUID();
    String todayKey = DateFormat('d MMM yyyy').format(DateTime.now());

    // Push the entire updated list to Firestore
    await tasksCollection
        .doc(userId)
        .collection('completed_tasks')
        .doc(todayKey)
        .set({
      'tasks': tasks,
      'date': DateTime.now(),
    });
  }


  void addTaskToList(Map<String, dynamic> task) {
    setState(() {
      todayTasks.add(task);
    });
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

      // Check if the tasks contain data for the current day
      if (todayTasks.length > 0) {
        List<Map<String, dynamic>> completedTasks =
        todayTasks.where((task) => task['isChecked'] == true).toList();
        List<Map<String, dynamic>> incompleteTasks =
        todayTasks.where((task) => task['isChecked'] != true).toList();
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return AddTaskPopup(todayTasks,addTaskToList); // Replace AddTaskPopup with your custom widget for adding a task
                  },
                );
              },
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,


            appBar: PreferredSize(
              preferredSize: Size(screenSize.width, 75),
              child: HeaderL(),
            ),
            backgroundColor: Colors.white,
            body: WillPopScope(
              onWillPop: () async {
                // Navigate back to the home page
                Navigator.push(context, MaterialPageRoute(builder: (context) =>BottomNavigation( 1)));
                return false; // Do not allow the default back button behavior
              },
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.03),
                  Container(
                    height: screenSize.height*0.7,

                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display incomplete tasks
                          if (incompleteTasks.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: Text('Tasks for Today',style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(height: 8),
                                ListView.builder(
physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: incompleteTasks.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> task =
                                    incompleteTasks[index];
                                    bool isPermanent = task['isPermanent'];
                                    bool isChecked = task['isChecked'] ?? false;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: isPermanent
                                              ? Color(0xffff914d).withOpacity(0.5)
                                              : Colors.grey[300],
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(task['title']),
                                          subtitle:
                                          Text('${task['startTime']} - ${task['endTime']}'),
                                          value: isChecked,
                                          onChanged: (value) async {
                                          await  markTaskCompleted(task, value!);
                                            setState(() {
                                              task['isChecked'] = value;
                                              if (value!) {
                                                playSound();

                                                // await updateFirestore(currentDay,task, value!);
                                              }
                                            });
                                          },
                                          activeColor: isPermanent
                                              ? Color.fromRGBO(247, 181, 147, 0.8)

                                          : Color.fromRGBO(173, 237, 175, 1),
                                          controlAffinity:
                                          ListTileControlAffinity.leading,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                          // Display completed tasks
                          if (completedTasks.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: Text('Completed',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: completedTasks.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> task =
                                    completedTasks[index];
                                    bool isPermanent = task['isPermanent'];
                                    bool isChecked = task['isChecked'] ?? false;
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color:Color(0xff7ed957).withOpacity(0.5),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(task['title'],
                                              style: TextStyle(
                                                  decoration:
                                                  TextDecoration.lineThrough)),
                                          subtitle:
                                          Text('${task['startTime']} - ${task['endTime']}'),
                                          value: isChecked,
                                          onChanged: (value) async {
                                            await  markTaskCompleted(task, value!);
                                            if (value!) {
                                              playSound();
                                            } else {
                                              // await updateFirestore(currentDay,task, value!);
                                            }
                                            setState(() {
                                              task['isChecked'] = value;


                                            });
                                          },
                                          activeColor: isPermanent
                                              ? Colors.red[200]
                                              : Color(0xff7ed957),
                                          controlAffinity:
                                          ListTileControlAffinity.leading,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return AddTaskPopup(todayTasks,addTaskToList); // Replace AddTaskPopup with your custom widget for adding a task
                  },
                );
              },
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            appBar: PreferredSize(
              preferredSize: Size(screenSize.width, 75),
              child: HeaderL(),
            ),
            backgroundColor: Colors.white,
            body:  WillPopScope(
              onWillPop: () async {
                // Navigate back to the home page
                Navigator.push(context, MaterialPageRoute(builder: (context) =>BottomNavigation( 1)));
                return false; // Do not allow the default back button behavior
              },
              child: Center(
                child:Text('No tasks for today'),
              ),
            ),
          ),
        );
      }
    }
  }

}

























class AddTaskPopup extends StatefulWidget {
  final List<Map<String, dynamic>> todayTasks;
  final Function(Map<String, dynamic>) addTaskToListCallback;
  AddTaskPopup(this.todayTasks,this.addTaskToListCallback);

  @override
  _AddTaskPopupState createState() => _AddTaskPopupState();
}

class _AddTaskPopupState extends State<AddTaskPopup> {
  TextEditingController _titleController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (picked != null && picked != _startTime)
                  setState(() {
                    _startTime = picked;
                  });
              },
              child: Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 10),
                  Text('Start Time: ${_startTime.format(context)}'),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (picked != null && picked != _endTime)
                  setState(() {
                    _endTime = picked;
                  });
              },
              child: Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 10),
                  Text('End Time: ${_endTime.format(context)}'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic to handle adding the task here
                String title = _titleController.text;
                String startTime = _startTime.format(context);
                String endTime = _endTime.format(context);
                // Call a function to add the task with provided details

                  addTaskToList();


                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> addTaskToList() async {
    // Add the task to the list
    String title = _titleController.text;
    String startTime = _startTime.format(context);
    String endTime = _endTime.format(context);
    Map<String, dynamic> task = {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'isPermanent': false,
    };

    // Update the todayTasks list in the TaskListViewState
    widget.addTaskToListCallback(task);

    // Save the updated task list to local storage
    String todayKey = DateFormat('dMMMyyyy').format(DateTime.now());
    String sa = 'todo_tasks';
    sa += '_$todayKey';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? todayTasksString = prefs.getString(sa);
    List<Map<String, dynamic>> storedTodayTasks =
    todayTasksString != null ? List<Map<String, dynamic>>.from(json.decode(todayTasksString)) : [];

    // Add the new task to the stored task list
    storedTodayTasks.add(task);

    print('todaystaks $storedTodayTasks');
    // print('TodayTaskslistlen ${todayTasks.length}');
    // print('TodayTaskslist ${todayTasks.length}');
    // print('TodayTaskslist $todayTasks');
  await  prefs.setString(sa, json.encode(storedTodayTasks));

    // Save the updated task list back to local storage

    // await here

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>TaskListView()));// Close the popup
  }



}


