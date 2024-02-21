import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncuwell/pages/Notifications/notifications-page.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';

class HeaderL extends StatefulWidget {
  const HeaderL({super.key});

  @override
  State<HeaderL> createState() => _HeaderLState();
}

class _HeaderLState extends State<HeaderL> {
  bool loading = false;
  String? name ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  Future<void> getData() async {

    var db = FirebaseFirestore.instance;
    String? uid = await getUID();
    DocumentSnapshot userData = await db.collection('Users').doc(uid).get();

    // Check if the document exists and has data before accessing 'name' field
    if (userData.exists) {
      Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name')) {


          name = data['name'];

      }
    }
setState(() {

});
    // Return null if the document doesn't exist or 'name' field is missing
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20,left: 18,right: 18),
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(

          color: Color(0xffff914d),
          borderRadius: BorderRadius.circular(25)),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
SizedBox(width: 40,),
              Text(
                 name!=null?name!:'loading',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 120,),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationsPage()));
                },
                icon: Icon(Icons.notifications_active_rounded,color: Colors.black,),
              ),
              IconButton(
                onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
                },
                icon: Icon(Icons.person),
              ),
            ],
          )
      );

  }
}
