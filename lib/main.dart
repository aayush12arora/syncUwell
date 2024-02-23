
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:syncuwell/Services/notifications_service.dart';
import 'package:syncuwell/pages/TimeTable/time-tablecontroller.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/Navigator/bottom_navigation.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/models/timetable.dart';
import 'package:syncuwell/pages/Auth/login.dart';
import 'package:syncuwell/pages/Auth/sign_Up_Page.dart';
import 'package:syncuwell/pages/TimeTable/TimeTableScreen.dart';
import 'package:syncuwell/pages/chat/chat_page.dart';

import 'firebase_options.dart';
bool logstat= false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final TimetableController timetableController = Get.find();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Map<String, dynamic> tasks = {};
List<Map<String, dynamic>> todayTasks=[];
List<Map<String, dynamic>> upcomingWeekTasks = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(TimetableController());
  NotificationService().initNotification();
  tz.initializeTimeZones();

  // var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestCriticalPermission: true,
  //     requestSoundPermission: true
  // );
  //
  // var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosSettings);
  // bool? initialized = await flutterLocalNotificationsPlugin.initialize(
  //   initializationSettings,
  //
  //   onDidReceiveNotificationResponse: (response) {
  //    // print('here');
  //  //   print(response.payload.toString());
  //     onSelectNotification(response.payload);
  //
  //
  //   },




  //);
 // print('initialized  $initialized');
  //await _configureLocalTimeZone();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(await getLoggedInStatus()) {
    await convertData();
    await scheduleNotificationsForUpcomingTasks();
  }

  logstat = await getLoggedInStatus();


  runApp(const MyApp());
}


Future<void> onSelectNotification(String? payload) async {
  String? screenToOpen = payload;
  if (screenToOpen != null) {
    if (screenToOpen == 'faceApp') {
      print('down');

      // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => SecondFaceAuth("CSD311",2)));
    } else if (screenToOpen == 'otherScreen') {
      // Handle other screens if needed
    }
  }
}
Map<DateTime, List<Timetable>> timetableData = {};

Future<String?> getTimetableFromLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? timetableDataString = prefs.getString('timetable_data');
  return timetableDataString;
}

Future<void> convertData() async {
  List<String> days = ['sunday','monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
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
  String? jsonString = await getTimetableFromLocalStorage();

  tasks = json.decode(jsonString!);
  bool isNewWeek =  await isNewWeekStarted(tasks);
  if(isNewWeek) {
    await  submitTimetableToFirestore();
    jsonString =  await getTimetableFromLocalStorage();
    tasks = json.decode(jsonString!);
  }



  if (tasks[currentDay] != null) {
    todayTasks = List<Map<String, dynamic>>.from(tasks[currentDay]);
  }
  // Iterate through the upcoming week to populate tasks
  for (int i = currentDayIndex; i <= 7; i++) {
    String day = days[i - 1];
    if (tasks[day] != null) {
      upcomingWeekTasks.addAll(List<Map<String, dynamic>>.from(tasks[day]!));
    }

  }

}
DateTime convertStringToDateTime(String timeString) {
  // Get the current date
  DateTime now = DateTime.now();

  // Calculate the target date based on the current date and the provided day index
  //DateTime targetDate = now.add(Duration(days: dayIndex));

  // Split the time string into hour and minute parts
  List<String> timeParts = timeString.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
 DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute-10);
 if(scheduledTime.isBefore(now)) {
   scheduledTime = scheduledTime.add(Duration(days: 1));
 }
  // Create a new DateTime object with the target date and the specified time
  return scheduledTime;
}



Future<void> scheduleNotificationsForUpcomingTasks() async {
  DateTime now = DateTime.now();
  int currentDayIndex = now.weekday;
  print('current day index: $currentDayIndex');
  // Define a list of days in the week
  List<String> days = ['sunday','monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

  // Iterate through the upcoming days in the week
  //for (int i = currentDayIndex; i <= 7; i++) {
    String day = days[currentDayIndex];

    // Retrieve tasks for the current day
  List<Map<String, dynamic>> tasksForDay = [];
  if(tasks[day]!=null) {
    tasksForDay = List<Map<String, dynamic>>.from(
        tasks[day]);
  }
    // Iterate through tasks for the current day and schedule notifications
    tasksForDay.forEach((task) async {
      print('Scheduling notification for: ${task['title']} at ${task['startTime']} on $day');
      NotificationService().scheduleNotification(
          title: '${task['title']} is due soon!',
          body: task['title'],
          scheduledNotificationDateTime: convertStringToDateTime(task['startTime']));
    });
  //}
}




String formatTimeOfDay(TimeOfDay timeOfDay) {
  final String hour = timeOfDay.hour.toString().padLeft(2, '0');
  final String minute = timeOfDay.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

Future<void> saveTimeTabletoLocalStorage( Map<String, dynamic> documentData) async {
  // Save the timetable data map to SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('timetable_data', json.encode(documentData));

}

Future<void> submitTimetableToFirestore() async {
  try {


   // final String userName = name;

    Map<String, dynamic> documentData = {

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
    String? uid = await getUID();
    await saveTimeTabletoLocalStorage(documentData);
    final CollectionReference timetableCollection =
    FirebaseFirestore.instance.collection('timetable');
    await timetableCollection.doc(uid).set(documentData);

    print('Timetable data submitted to Firestore!');

  } catch (e) {
    print('Error submitting timetable data to Firestore: $e');

  }
}














Future<bool> getLoggedInStatus() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool status = prefs.getBool('LogedIn') ?? false;
  if(status){


    return true;


  }else{
    return false;
  }
}



int getWeekNumber(DateTime date) {
  // Calculate the week number based on ISO 8601 standard
  DateTime thursday = date.subtract(Duration(days: date.weekday - 4));
  int year = thursday.year;
  int weekOfYear = ((thursday.difference(DateTime(year, 1, 1)).inDays) / 7).ceil();
  return weekOfYear;
}






Future<bool> isNewWeekStarted(Map<String, dynamic> schedule) async {
  DateTime currentDate = DateTime.now();
  int currentWeekNumber = getWeekNumber(currentDate);
  bool weekEnded = false;

  for (var dayIndex = 0; dayIndex < schedule.length; dayIndex++) {
    var daySchedule = schedule.values.elementAt(dayIndex);
    print('Day Schedule: $daySchedule');
    for (var entryIndex = 0; entryIndex < daySchedule.length; entryIndex++) {
      var entry = daySchedule[entryIndex];

      // Check if the entry has a valid "date" key
      if (entry.containsKey("date")) {
        DateTime entryDate = DateTime.parse(entry["date"]);

        int entryWeekNumber = getWeekNumber(entryDate);
        if (!entry["isPermanent"] && entryWeekNumber != currentWeekNumber) {
          print('day index $dayIndex, entry index $entryIndex');

          // Remove the entry from the documentData map
          String day = schedule.keys.elementAt(dayIndex);
          List<dynamic> updatedDaySchedule = List.from(daySchedule);
          updatedDaySchedule.removeAt(entryIndex);
          schedule[day] = updatedDaySchedule;

          // Decrement entryIndex because removing an entry will shift the indices

          weekEnded = true;
        }
      } else {
        // Handle entries without a valid "date" keyc
        print("Entry at index $entryIndex in day $dayIndex does not have a valid 'date' key");
      }
    }
  }


  // Save the updated documentData to local storage
  await saveTimeTabletoLocalStorage(schedule);
  print('Updated Schedule: $schedule');
  //TODO: Save the updated documentData to  time table controller
 //  if(timetableController.timetable[dayIndex].length==0){
 //    timetableController.timetable[dayIndex].addAll(timetableEntries);
 //    timetableController.update();
 //  }
  timetableController.updateTimetableFromSchedule(schedule);
  return weekEnded;
}











class MyApp extends StatelessWidget {

  const MyApp({super.key});

  Future<void> requestPermissions() async {
    bool reqSuc = false;
    List<Permission> permissions = [

      Permission.notification
    ];

    for (Permission permission in permissions) {
      if (await permission.isGranted) {
        if (kDebugMode) {
     //     print("Permission: $permission already granted");
        }
        reqSuc = true;
        continue;
      } else if (await permission.isDenied) {
        PermissionStatus permissionsStatus = await permission.request();
        if (permissionsStatus.isGranted) {
          if (kDebugMode) {
         //   print("Permission: $permission already granted");
          }
          reqSuc = true;
        } else if (permissionsStatus.isPermanentlyDenied) {
          if (kDebugMode) {
            print("Permission: $permission is permanently denied");
          }
          reqSuc = false;
        }
      }
    }
    if (reqSuc == false) {
      openAppSettings();
    }
  }
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Color myHexColor = Color(0xffff914d);
    MaterialColor myMaterialColor = MaterialColor(
      myHexColor.value,
      <int, Color>{
        50: myHexColor.withOpacity(1),
        100: myHexColor.withOpacity(1),
        200: myHexColor.withOpacity(1),
        300: myHexColor.withOpacity(1),
        400: myHexColor.withOpacity(1),
        500: myHexColor.withOpacity(1),
        600: myHexColor.withOpacity(1),
        700: myHexColor.withOpacity(1),
        800: myHexColor.withOpacity(1),
        900: myHexColor.withOpacity(1),
      },
    );
    return FutureBuilder(
future: requestPermissions(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return GetMaterialApp(
          title: 'SyncUwell',
            navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
         theme: ThemeData(
              primarySwatch: myMaterialColor,
            ),
          home: logstat?BottomNavigation(1):LoginScreen()
        );
      }
    );
  }
}

