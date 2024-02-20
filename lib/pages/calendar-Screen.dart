import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/models/timetable.dart';
import 'package:table_calendar/table_calendar.dart';

class TimetableCalendarScreen extends StatefulWidget {
  @override
  _TimetableCalendarScreenState createState() => _TimetableCalendarScreenState();
}

class _TimetableCalendarScreenState extends State<TimetableCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay ; // Set default selected day to today
  Map<DateTime, List<Timetable>> timetableData = {};

  Future<String?> getTimetableFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timetableDataString = prefs.getString('timetable_data');
    return timetableDataString;
  }

  Future<void> convertData() async {
    List<String> days = ['sunday','monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    String? jsonString = await getTimetableFromLocalStorage();
    Map<String, dynamic> jsonData = json.decode(jsonString!);

    for (String day in days) {
      if (jsonData.containsKey(day)) {
        List<Map<String, dynamic>> dayEntries = List<Map<String, dynamic>>.from(jsonData[day]);
       print('$day Entries: $dayEntries');

        List<Timetable> timetableEntries = dayEntries
            .map((entry) => Timetable.fromJson(entry))
            .toList();

      //  print('timetableEntries: $timetableEntries');
        // Create a DateTime for each hour of the selected day
        DateTime selectedDateTime = _selectedDay!.subtract(Duration(days: _selectedDay!.weekday - days.indexOf(day)));
        List<DateTime> hoursOfDay = List.generate(24, (hour) => selectedDateTime.add(Duration(hours: hour)));

        // Populate timetableData with entries for each hour
        for (DateTime hourOfDay in hoursOfDay) {
          timetableData[hourOfDay] = timetableEntries;
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                convertData();
              });
            },
            selectedDayPredicate: (day) {
              // This determines if a day is selected or not
              return isSameDay(day, _selectedDay);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.greenAccent, // Color for today's date
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue, // Color for the selected date
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: _buildTimetable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetable() {
    print('Building timetable...');
    if (_selectedDay == null) {
      return Center(
        child: Text('Please select a day from the calendar.'),
      );
    }

    List<Timetable> timetableEntries = timetableData[_selectedDay] ?? [];

    return ListView.builder(
      itemCount: timetableEntries.length,
      itemBuilder: (context, index) {
        Timetable entry = timetableEntries[index];

        return ListTile(
          title: Text(entry.title),
          subtitle: Text(
            '${entry.start_time?.format(context)} - ${entry.endTime?.format(context)}',
          ),
          trailing: entry.isPermanent
              ? Icon(Icons.not_interested_outlined, color: Colors.red)
              : Icon(Icons.event_available, color: Colors.green),
        );
      },
    );
  }
}
