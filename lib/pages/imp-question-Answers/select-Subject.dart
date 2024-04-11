import 'package:flutter/material.dart';
import 'package:syncuwell/models/question_answer.dart';
import 'package:syncuwell/pages/imp-question-Answers/question-answer.dart';

class SelectSubject extends StatefulWidget {
  const SelectSubject({super.key});

  @override
  State<SelectSubject> createState() => _SelectSubjectState();
}

class _SelectSubjectState extends State<SelectSubject> {
   var loading = false;
  List<dynamic> subjects=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubjects();
  }

  Future<void> getSubjects() async {
    setState(() {
      loading= true;
    });
    subjects = await FlashcardService().getCourseList();
    setState(() {
      loading= false;
    });
  }


   Future<void> addTaskToList(String courseId) async {
     setState(() {
       //todayTasks.add(task);
loading=true;
     });
     await FlashcardService().addSubject(courseId);
     await getSubjects();
     setState(() {
       //todayTasks.add(task);
loading=false;
     });
   }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return AddSubjectPopup(addTaskToList); // Replace AddTaskPopup with your custom widget for adding a task
            },
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Text('Select Subject'),
      ),
      body: loading?Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(color: Colors.black),
        ),
      ):Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.8,
              child: ListView.builder(
                itemCount: subjects.length, // Replace with the actual number of courses
                itemBuilder: (context, index) {
                  final courseId = subjects[index];

                        return SubjectSelectionItem(CourseId: courseId);
                      }



              ),
            ),
          ],
        ),
      ),
    );
  }


}



class SubjectSelectionItem extends StatelessWidget {
  final String CourseId;

  const SubjectSelectionItem({required this.CourseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child:Column(
        children: [
          // Container(
          //   height:2,
          // ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color:Color(0xff7ed957).withOpacity(0.5),
            ),
            child: ListTile(

              title: Text(CourseId,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardScreen(courseId: CourseId)));
          },
            ),
          ),
        ],
      ),
    );
  }
}



class AddSubjectPopup extends StatefulWidget {

  final Function(String) addToSubjectListback;
  AddSubjectPopup(this.addToSubjectListback);

  @override
  _AddSubjectPopupState createState() => _AddSubjectPopupState();
}

class _AddSubjectPopupState extends State<AddSubjectPopup> {
  TextEditingController SubjectIdController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: SubjectIdController,
              decoration: InputDecoration(
                labelText: 'Subject/Topic',
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic to handle adding the task here
                String subject =   SubjectIdController.text;

                // Call a function to add the task with provided details

                addSubjectToList(subject);


                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> addSubjectToList(String subject) async {
    // Add the task to the list



    // Update the todayTasks list in the TaskListViewState
    widget.addToSubjectListback(subject);







    // Save the updated task list back to local storage

    // await here

   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>TaskListView()));// Close the popup
  }



}