

import 'package:flutter/material.dart';
import 'package:syncuwell/const.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
   bool arenotifications = false;

   List<Map<String,dynamic>> notifications =[];
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('Notifications'),
        ),
        body: arenotifications? Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text('Tasks for Today',style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount:notifications.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> task =
              notifications[index];
                bool isPermanent = task['isPermanent'];
                bool isChecked = task['isChecked'] ?? false;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isPermanent
                          ? Colors.red[200]
                          : Colors.greenAccent,
                    ),
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle:
                      Text('${task['startTime']} - ${task['endTime']}'),


                    ),
                  ),
                );
              },
            ),
          ],
        ):
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No Notifications Yet',style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),),
              SizedBox(height: 8),
              Text('You will be notified when you have tasks',style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400),),
            ],
          ),
        ),
      )
    );

  }
}
