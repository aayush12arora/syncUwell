// timetable_day_form.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncuwell/const.dart';
import 'package:syncuwell/models/timetable.dart';
import 'package:syncuwell/pages/TimeTable/time-tablecontroller.dart';

class UpdateTimetableDayFormWidget extends StatefulWidget {
  final int dayIndex;

  UpdateTimetableDayFormWidget({required this.dayIndex});

  @override
  State<UpdateTimetableDayFormWidget> createState() => _UpdateTimetableDayFormWidgetState();
}

class _UpdateTimetableDayFormWidgetState extends State<UpdateTimetableDayFormWidget> {
  final TimetableController timetableController = Get.find();
  TextEditingController titleController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  bool isPermanent = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Set<int> selectedIndices = Set();
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday','Sunday'];


  List<String> mdays =['M','T','W','T','F','S','S'];




  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return GetBuilder<TimetableController>(
      builder: (timetableController) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(days[widget.dayIndex],style: TextStyle(fontSize: 25),),
              SizedBox(height: 16,),
              TimetableListWidget( context: context, dayIndex: widget.dayIndex, timetableController:  timetableController,),

              SizedBox(height: 16,),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title',border: OutlineInputBorder()),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (selectedTime != null) {
                    // Update the timeController with the selected time
                    startTime = selectedTime;
                    startTimeController.text =
                    '${selectedTime.hour}:${selectedTime.minute}';
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: startTimeController,
                    decoration: InputDecoration(labelText: ' Start Time',
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () async {
                  if (startTime != null) {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      // Update the timeController with the selected time
                      endTime = selectedTime;
                      endTimeController.text =
                      '${selectedTime.hour}:${selectedTime.minute}';
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a start time first.'),
                      ),
                    );
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: endTimeController,
                    decoration: InputDecoration(labelText: ' End Time',
                      border: OutlineInputBorder(),),
                  ),
                ),
              ),

              SizedBox(height: 15,),
              Container(
                // margin:  EdgeInsets.only(top: 9),
                // padding: EdgeInsets.all(10),
                height: screenSize.height * 0.06,
                width: screenSize.width * 0.9,

                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 19.0,
                    mainAxisSpacing: 39.0,
                  ),
                  itemCount: 7, // 3 rows x 3 columns
                  itemBuilder: (context, index) {
                    return InkWell(

                      onTap: (){
                        setState(() {
                          if (selectedIndices.contains(index)) {
                            print('already');
                            selectedIndices.remove(index);
                          } else {
                            print('selected');
                            selectedIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: selectedIndices.contains(index) ?  AppColors.secondaryColor: Colors.black,
                          ),
                          child: Center(
                            child: Text(
                              mdays[index % mdays.length],
                              style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          )
                      ),
                    );


                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                onPressed: () {
                  if (startTime != null &&
                      endTime != null &&
                      titleController.text.isNotEmpty) {
                    final entry = Timetable(
                      title: titleController.text,
                      start_time: startTime,
                      endTime: endTime!,
                      isPermanent: true,
                    );
                    timetableController.addTimetable(widget.dayIndex, entry);

                    for (int index in selectedIndices) {
                      timetableController.addTimetable(index, entry);
                      print("Selected index: $index");
                    }
                    // Clear text fields
                    isPermanent = false;
                    titleController.clear();
                    startTime = null;
                    endTime = null;
                    startTimeController.clear();
                    endTimeController.clear();
                    selectedIndices.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please add all the fields'),
                      ),
                    );
                  }
                },
                child: Text('Add Entry'),
              ),
            ],
          ),
        );
      },
    );
  }







}




class TimetableListWidget extends StatefulWidget {
  final BuildContext context;
  final int dayIndex;
  final TimetableController timetableController;

  TimetableListWidget({
    required this.context,
    required this.dayIndex,
    required this.timetableController,
  });

  @override
  _TimetableListWidgetState createState() => _TimetableListWidgetState();
}

class _TimetableListWidgetState extends State<TimetableListWidget> {
  @override
  Widget build(BuildContext context) {
    final entries = widget.timetableController.timetable[widget.dayIndex];
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        if (entries != null && entries.isNotEmpty) ...[
          for (var i = 0; i < entries.length; i++)
            entries[i].isPermanent?
            EntryWidget(
              entry: entries[i],
              dayIndex: widget.dayIndex,
              entryIndex: i,
              context: widget.context,
              timetableController: widget.timetableController,
            ):SizedBox.shrink()
        ],
      ],
    );
  }
}

class EntryWidget extends StatefulWidget {
  final Timetable entry;
  final int dayIndex;
  final int entryIndex;
  final BuildContext context;
  final TimetableController timetableController;

  EntryWidget({
    required this.entry,
    required this.dayIndex,
    required this.entryIndex,
    required this.context,
    required this.timetableController,
  });

  @override
  _EntryWidgetState createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  late TextEditingController titleController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;
  late bool pakka;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entry.title);
    startTimeController =
        TextEditingController(text: widget.entry.start_time?.format(widget.context));
    endTimeController =
        TextEditingController(text: widget.entry.endTime?.format(widget.context));
    startTime = widget.entry.start_time;
    endTime = widget.entry.endTime;
    pakka = widget.entry.isPermanent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${widget.entry.title}',
                  style: TextStyle(color: Colors.black),
                ),

              ],
            ),
            Text(
              '${startTime?.format(widget.context)} to ${endTime?.format(widget.context)}',
              style: TextStyle(
                  color: widget.entry.isPermanent ? Color(0xffff914d) : Colors.green),
            ),
            Text("Is this entry permanent ",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16,),),
            Text(
              '${widget.entry.isPermanent}',
              style: TextStyle(
                  color: widget.entry.isPermanent ? Color(0xffff914d) : Colors.green),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Edit Entry'),
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(labelText: 'Title'),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  TimeOfDay? selectedStartTime = await showTimePicker(
                                    context: context,
                                    initialTime: startTime ?? TimeOfDay.now(),
                                  );

                                  if (selectedStartTime != null) {
                                    setState(() {
                                      startTimeController.text =
                                      '${selectedStartTime.hour}:${selectedStartTime.minute}';
                                      startTime = selectedStartTime;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: startTimeController,
                                    decoration: InputDecoration(labelText: 'Start Time'),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (startTime != null) {
                                    TimeOfDay? selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (selectedTime != null) {
                                      setState(() {
                                        endTime = selectedTime;
                                        endTimeController.text =
                                        '${selectedTime.hour}:${selectedTime.minute}';
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please select a start time first.'),
                                      ),
                                    );
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: endTimeController,
                                    decoration: InputDecoration(labelText: ' End Time'),
                                  ),
                                ),
                              ),
                              Switch(
                                value: pakka,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    pakka = newValue;
                                  });
                                },
                              ),
                            ],
                          );
                        }
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final editedEntry = Timetable(
                            title: titleController.text,
                            start_time: startTime!,
                            endTime: endTime!,
                            isPermanent: pakka,
                          );
                          widget.timetableController.editTimetable(
                              widget.dayIndex, widget.entryIndex, editedEntry);
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                widget.timetableController.removeTimetable(widget.dayIndex, widget.entryIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}




// timetable_controller.dart


