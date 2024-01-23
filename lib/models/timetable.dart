// timetable.dart
import 'package:flutter/material.dart';

class Timetable {
  String title;
  TimeOfDay?  start_time;
  TimeOfDay? endTime;
  bool isPermanent;




  Timetable({required this.title, required this.start_time,required this.endTime, required this.isPermanent});

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      title: json['title'],
      endTime: _parseTime(json['endTime']),
      isPermanent: json['isPermanent'], start_time: _parseTime(json['startTime']),
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    List<String> parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

}



class TimetableData {
  final Map<String, List<Timetable>> timetable;

  TimetableData({required this.timetable});

  factory TimetableData.fromJson(Map<String, dynamic> json) {
    Map<String, List<Timetable>> timetable = {};

    json.forEach((day, entries) {
      timetable[day] = List<Timetable>.from(
        entries.map((entry) => Timetable.fromJson(entry)),
      );
    });

    return TimetableData(timetable: timetable);
  }
}