
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/pages/Home/homepage.dart';
import 'package:syncuwell/pages/Todays-Tasks/todays-task.dart';
import 'package:syncuwell/pages/calendar-Screen.dart';

import '../pages/chat/chat_page.dart';


class BottomNavigation extends StatefulWidget {
  final int? passedindex;
  const BottomNavigation(this.passedindex);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int _selectedIndex = 0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    // Set the initial selected index based on the passedindex or use 0 if not provided
    // setState(() {
    //   loading = true;
    // });

    loadscreens();
    _selectedIndex = widget.passedindex ?? 0;
  }

  void _onItemTapped(int index) {
    setState(() {
     // loading = true;
      _selectedIndex = index;

      loadscreens();
    });
  }

  Future<void> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
  }

  List? screens = [];

  void loadscreens() {

      screens = [
         TaskListView(),
        const HomePage(),
        const ChatPage(),
      TimetableCalendarScreen(),
      ];

    // setState(() {
    //   loading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: loading
          ? Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      )
          : Container(
        height: MediaQuery.of(context).size.height,
        child: screens?[_selectedIndex],
      ),
      bottomNavigationBar: Container(
          height: MediaQuery.sizeOf(context).height * 0.08,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0xffebe7e7),
             borderRadius: BorderRadius.circular(15),
            //  border: Border.all(color: Colors.white54, width: 0.9)
          ),
          child: BottomNavigationBar(
            elevation: 1,

            iconSize: 28,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.grey[500],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items:  [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.list_outlined,
                  ),
                  label: 'Tasks',
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_filled,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_rounded,
                  ),
                  label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: 'Calender'),
            ],
          )),
    );
  }
}
