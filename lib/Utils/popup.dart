import 'package:flutter/material.dart';

class PopupMessage extends StatefulWidget {
  final String message;
  final Function onClose;

  const PopupMessage({
    required this.message,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  _PopupMessageState createState() => _PopupMessageState();
}

class _PopupMessageState extends State<PopupMessage> {
  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
      //  margin: EdgeInsets.all(20),
        height: screensize.height*0.3, // Set the desired height for the popup container
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xffff914d).withOpacity(0.8),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 70,
              left: 20,
              right: 20,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.message,
                  style: TextStyle(fontSize: 18, color: Colors.white,height: 1.5,fontWeight: FontWeight.bold,),

                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  widget.onClose();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}