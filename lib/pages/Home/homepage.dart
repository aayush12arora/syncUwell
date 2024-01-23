import 'package:flutter/material.dart';
import 'dart:math';

import '../../Utils/headerfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _randomLabels = [
    'Label 1',
    'Label 2',
    'Label 3',
    'Label 4',
    'Label 5',
    'Label 6',
    'Label 7',
    'Label 8',
    'Label 9',
  ];

  final List<IconData> _randomIcons = [
    Icons.star,
    Icons.favorite,
    Icons.music_note,
    Icons.camera,
    Icons.games,
    Icons.lightbulb,
    Icons.directions_run,
    Icons.shopping_cart,
    Icons.movie,
  ];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 75),
          child: HeaderL(),
        ),
        body: Container(
          margin:  EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          height: screenSize.height * 0.7,
          width: screenSize.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.tealAccent[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Good Evening Aayush,",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
              Container(
               margin:  EdgeInsets.only(top: 9),
                padding: EdgeInsets.all(10),
                height: screenSize.height * 0.45,
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.tealAccent[100],
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 19.0,
                    mainAxisSpacing: 39.0,
                  ),
                  itemCount: 9, // 3 rows x 3 columns
                  itemBuilder: (context, index) {
                    return GridItem(
                      icon: _randomIcons[index % _randomIcons.length],
                      label: _randomLabels[index % _randomLabels.length],
                    );
                  },
                ),
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(top: 20,left: 2,right: 15),
                height: 55,
                width: screenSize.width*0.55,
                decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(25)),

                child: Center(
                  child: Text(
                    "Ask me Anything",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                )
            ),

            Container(
                margin: EdgeInsets.only(top: 20,left: 2,right: 5),
                height: 65,
                width: screenSize.width*0.15,
                decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(15)),

                child: Center(
                  child: Icon(Icons.headset_mic_rounded,color: Colors.white,),
                )
            ),
          ],


        )
            ],
          ),
        ),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const GridItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.yellowAccent[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
