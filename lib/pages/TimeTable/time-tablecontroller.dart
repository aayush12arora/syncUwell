import 'package:get/get.dart';
import 'package:syncuwell/models/timetable.dart';

class TimetableController extends GetxController {
  RxList<List<Timetable>> timetable =
      List.generate(7, (_) => <Timetable>[]).obs;

  void addTimetable(int day, Timetable entry) {
    timetable[day].add(entry);
    update();
  }

  void editTimetable(int day, int index, Timetable entry) {
    timetable[day][index] = entry;
    update();
  }

  void removeTimetable(int day, int index) {
    timetable[day].removeAt(index);
    update();
  }
}