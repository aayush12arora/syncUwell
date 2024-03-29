import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncuwell/pages/profile/profile_page.dart';


// flash card service
class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String tag;

  Flashcard({required this.id, required this.question, required this.answer, required this.tag});

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'tag': tag,
    };
  }

  factory Flashcard.fromMap(String id, Map<String, dynamic> map) {
    return Flashcard(
      id: id,
      question: map['question'],
      answer: map['answer'],
      tag: map['tag'],
    );
  }
}




// flash card service
class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFlashcard(String courseId, Flashcard flashcard) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('flashcards')
          .add(flashcard.toMap());
    } catch (e) {
      print('Error adding flashcard: $e');
      throw e;
    }
  }

  Future<List<Flashcard>> getFlashcards(String courseId, String? tag) async {
    try {
      Query query = _firestore.collection('courses').doc(courseId).collection('flashcards');

      if (tag != null) {
        query = query.where('tag', isEqualTo: tag);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => Flashcard.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting flashcards: $e');
      throw e;
    }
  }

  Future<void> updateFlashcard(String courseId, Flashcard flashcard) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('flashcards')
          .doc(flashcard.id)
          .update(flashcard.toMap());
    } catch (e) {
      print('Error updating flashcard: $e');
      throw e;
    }
  }

  Future<int> getFlashcardsLength(String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('flashcards')
          .get();

      var list = querySnapshot.docs.map((doc) => Flashcard.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      return list.length;
    } catch (e) {
      print('Error getting flashcards: $e');
      throw e;
    }
  }


  Future<List<dynamic>> getCourseList() async {
    List<Map<String,dynamic>>subjectData=[];
    try {
      final firestore = FirebaseFirestore.instance;
      String? uid = await getUID();
      DocumentReference subjref = firestore.collection('Attend').doc(uid);

      // Check if the document exists
      DocumentSnapshot subjectsSnapshot = await subjref.get();
      if (!subjectsSnapshot.exists) {
        // If the document doesn't exist, clear subjectData and return
        subjectData.clear();

        return[];
      }

      // Extract data from the document
      Map<String, dynamic> data = subjectsSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subjectsList = (data['subjects'] as List<dynamic>);
      return subjectsList;
    } catch (e) {
      print('Error getting flashcards: $e');
      throw e;
    }
  }
}
















// Edit flash card dialog box


class EditFlashcardDialog extends StatefulWidget {
  final String flashcardId;
  final String courseId;
  final String question;
  final String answer;
  final String tag;
  final Function()? onCardUpdated;

  const EditFlashcardDialog({
    Key? key,
    required this.flashcardId,
    required this.courseId,
    required this.question,
    required this.answer, required this.tag, this.onCardUpdated,
  }) : super(key: key);

  @override
  _EditFlashcardDialogState createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<EditFlashcardDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  String _selectedTag = '';
  bool edit = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question);
    _answerController = TextEditingController(text: widget.answer);
    _selectedTag = widget.tag;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: Container(
          margin:  EdgeInsets.only(top:35),

          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          if(edit){
                            setState(() {
                              _selectedTag = 'Easy';

                            });
                          }

                        },
                        child: Container(

                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.27,
                          decoration: BoxDecoration(
                              color: (_selectedTag == 'Easy' || _selectedTag == null)
                                  ? Colors.greenAccent
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                                'Easy',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              )),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if(edit){
                            setState(() {
                              _selectedTag = 'Medium';

                            });
                          }

                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.27,
                          decoration: BoxDecoration(
                              color: (_selectedTag == 'Medium' || _selectedTag == null)
                                  ? Colors.orange
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                                'Medium',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              )),
                        ),
                      ),
                      InkWell(
                        onTap: () {

                          if(edit){
                            setState(() {
                              _selectedTag = 'Hard';

                            });
                          }

                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.27,
                          decoration: BoxDecoration(
                              color: (_selectedTag == 'Hard' || _selectedTag == null)
                                  ? Colors.redAccent
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                                'Hard',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  height: MediaQuery.of(context).size.height * 0.68,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(22)
                  ),

                  child: Column(
                    children:edit? [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                      Container(
                        margin:  EdgeInsets.all(25),
                        padding: EdgeInsets.all(25),
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        width: MediaQuery.sizeOf(context).width * 0.83,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.sizeOf(context).width * 0.04,
                            right: MediaQuery.sizeOf(context).width * 0.08,
                          ), // Add desired padding
                          child: TextField(
                            controller: _questionController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            maxLines: null,
                            decoration: const InputDecoration(
                              enabledBorder:
                              InputBorder.none, // Remove underline
                              focusedBorder: InputBorder
                                  .none, // Remove underline when focused
                              errorBorder: InputBorder
                                  .none, // Remove underline on error
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets
                                  .zero, // Set contentPadding to zero
                              hintText: "Type in your question here",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                      Container(
                        margin:  EdgeInsets.all(25),
                        padding: EdgeInsets.all(25),
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        width: MediaQuery.sizeOf(context).width * 0.83,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.sizeOf(context).width * 0.04,
                            right: MediaQuery.sizeOf(context).width * 0.08,
                          ), // Add desired padding
                          child: TextField(
                            controller: _answerController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            maxLines: null,
                            decoration: const InputDecoration(
                              enabledBorder:
                              InputBorder.none, // Remove underline
                              focusedBorder: InputBorder
                                  .none, // Remove underline when focused
                              errorBorder: InputBorder
                                  .none, // Remove underline on error
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets
                                  .zero, // Set contentPadding to zero
                              hintText: "Whats the solutin to your question",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              // Add your code here
                              setState(() {
                                edit = false;
                              });
                            },
                            child: Container(
                             // margin:EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.27, right: MediaQuery.sizeOf(context).width * 0.27),
                              height: MediaQuery.sizeOf(context).height * 0.05,
                              width: MediaQuery.sizeOf(context).width * 0.33,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(25)
                              ),
                              child: Center(
                                child: Text('Cancel',style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Add your code here
                              final question = _questionController.text.trim();
                              final answer = _answerController.text.trim();
                              if (question.isNotEmpty && answer.isNotEmpty) {
                                final flashcard = Flashcard(id: widget.flashcardId, question: question, answer: answer, tag: _selectedTag!);
                                FlashcardService().updateFlashcard(widget.courseId, flashcard);
                                widget.onCardUpdated!();
                                Navigator.of(context).pop();

                              }
                            },
                            child: Container(
                         //     margin:EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.27, right: MediaQuery.sizeOf(context).width * 0.27),
                              height: MediaQuery.sizeOf(context).height * 0.05,
                              width: MediaQuery.sizeOf(context).width * 0.33,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(25)
                              ),
                              child: Center(
                                child: Text('Upload',style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ]:

                    [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                      Container(
                        margin:  EdgeInsets.all(25),
                        padding: EdgeInsets.all(25),
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        width: MediaQuery.sizeOf(context).width * 0.83,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            //color: Colors.white
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.sizeOf(context).width * 0.04,
                            right: MediaQuery.sizeOf(context).width * 0.08,
                          ), // Add desired padding
                          child: Text(
                            widget.question,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                      SingleChildScrollView(
                        child: Container(
                          margin:  EdgeInsets.all(25),
                          padding: EdgeInsets.all(25),
                          height: MediaQuery.sizeOf(context).height * 0.2,
                          width: MediaQuery.sizeOf(context).width * 0.83,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.sizeOf(context).width * 0.04,
                              right: MediaQuery.sizeOf(context).width * 0.08,
                            ), // Add desired padding
                            child: Text(
                              widget.answer,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                      InkWell(
                        onTap: () {
                          // Add your code here

                          setState(() {
                            edit = true;
                          });

                        },
                        child: Container(
                          margin:EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.27, right: MediaQuery.sizeOf(context).width * 0.27),
                          height: MediaQuery.sizeOf(context).height * 0.05,
                          width: MediaQuery.sizeOf(context).width * 0.83,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(25)
                          ),
                          child: Center(
                            child: Text('Edit',style: TextStyle(
                                color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                      ),

                    ]

                  ),


                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }
}





















// Flash Card dialog

class AddFlashcardDialog extends StatefulWidget {
  final String courseId;
  final Function()? onCardAdded;
  const AddFlashcardDialog({Key? key, required this.courseId,this.onCardAdded}) : super(key: key);

  @override
  _AddFlashcardDialogState createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String? _selectedTag; // Default selected tag

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: Container(
          margin:  EdgeInsets.only(top:35),

      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
children: [
  Container(
        height: MediaQuery.of(context).size.height * 0.12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedTag = 'Easy';

            });
          },
          child: Container(

            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.27,
            decoration: BoxDecoration(
                color: (_selectedTag == 'Easy' || _selectedTag == null)
                    ? Colors.greenAccent
                    : Colors.grey,
                borderRadius: BorderRadius.circular(25)),
            child: Center(
                child: Text(
                  'Easy',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20),
                )),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _selectedTag = 'Medium';

            });
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.27,
            decoration: BoxDecoration(
                color: (_selectedTag == 'Medium' || _selectedTag == null)
                    ? Colors.orange
                    : Colors.grey,
                borderRadius: BorderRadius.circular(25)),
            child: Center(
                child: Text(
                  'Medium',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20),
                )),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _selectedTag = 'Hard';

            });
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.27,
            decoration: BoxDecoration(
                color: (_selectedTag == 'Hard' || _selectedTag == null)
                    ? Colors.redAccent
                    : Colors.grey,
                borderRadius: BorderRadius.circular(25)),
            child: Center(
                child: Text(
                  'Hard',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20),
                )),
          ),
        )
          ],
        ),
  ),
  Container(
   margin: EdgeInsets.all(25),
        height: MediaQuery.of(context).size.height * 0.68,
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)
        ),

        child: Column(
          children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        Container(
          margin:  EdgeInsets.all(25),
          padding: EdgeInsets.all(25),
          height: MediaQuery.sizeOf(context).height * 0.2,
          width: MediaQuery.sizeOf(context).width * 0.83,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            color: Colors.white
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.sizeOf(context).width * 0.04,
              right: MediaQuery.sizeOf(context).width * 0.08,
            ), // Add desired padding
            child: TextField(
              controller: _questionController,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              maxLines: null,
              decoration: const InputDecoration(
                enabledBorder:
                InputBorder.none, // Remove underline
                focusedBorder: InputBorder
                    .none, // Remove underline when focused
                errorBorder: InputBorder
                    .none, // Remove underline on error
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets
                    .zero, // Set contentPadding to zero
                hintText: "Type in your question here",
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
        Container(
          margin:  EdgeInsets.all(25),
          padding: EdgeInsets.all(25),
          height: MediaQuery.sizeOf(context).height * 0.2,
          width: MediaQuery.sizeOf(context).width * 0.83,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
              color: Colors.white
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.sizeOf(context).width * 0.04,
              right: MediaQuery.sizeOf(context).width * 0.08,
            ), // Add desired padding
            child: TextField(
              controller: _answerController,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              maxLines: null,
              decoration: const InputDecoration(
                enabledBorder:
                InputBorder.none, // Remove underline
                focusedBorder: InputBorder
                    .none, // Remove underline when focused
                errorBorder: InputBorder
                    .none, // Remove underline on error
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets
                    .zero, // Set contentPadding to zero
                hintText: "Whats the solutin to your question",
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        InkWell(
          onTap: () {
            // Add your code here
            final question = _questionController.text.trim();
            final answer = _answerController.text.trim();
            if (question.isNotEmpty && answer.isNotEmpty) {
              final flashcard = Flashcard(id: '', question: question, answer: answer, tag: _selectedTag!);
              FlashcardService().addFlashcard(widget.courseId, flashcard);
              widget.onCardAdded!();
              Navigator.of(context).pop();

            }
          },
          child: Container(
           margin:EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.27, right: MediaQuery.sizeOf(context).width * 0.27),
            height: MediaQuery.sizeOf(context).height * 0.05,
            width: MediaQuery.sizeOf(context).width * 0.83,
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(25)
            ),
            child: Center(
              child: Text('Upload',style: TextStyle(
                  color: Colors.black, fontSize: 20),
              ),
            ),
          ),
        ),

          ],
        ),


  )
],
        ),
      ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }
}




// Flash card screen
class FlashcardScreen extends StatefulWidget {

  final String courseId;
  FlashcardScreen({required this.courseId});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}
// Inside _FlashcardScreenState class

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> cards = [];
  var loading = false;

  String? tag;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getData();
  }

  Future<void> getData() async {
    cards = await FlashcardService().getFlashcards(widget.courseId, tag);
    if (tag != null) {
      cards = cards.where((card) => card.tag == tag).toList();
    }
    setState(() {
      loading = false;
    });
  }

  void updateCards() {
    setState(() {
      loading = true; // Set loading to true to show loading indicator
    });
    getData(); // Fetch updated data
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
              return AddFlashcardDialog(
                courseId: widget.courseId,
                onCardAdded: updateCards, // Pass the callback function
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Text('Flashcards'),
      ),
      body: loading
          ? Center(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1),
          child: const CircularProgressIndicator(color: Colors.black),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // tag box
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          tag = 'Easy';
                          getData();
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.27,
                        decoration: BoxDecoration(
                            color: (tag == 'Easy' || tag == null)
                                ? Colors.greenAccent
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text(
                              'Easy',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          tag = 'Medium';
                          getData();
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.27,
                        decoration: BoxDecoration(
                            color: (tag == 'Medium' || tag == null)
                                ? Colors.orange
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text(
                              'Medium',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          tag = 'Hard';
                          getData();
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.27,
                        decoration: BoxDecoration(
                            color: (tag == 'Hard' || tag == null)
                                ? Colors.redAccent
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text(
                              'Hard',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20),
                            )),
                      ),
                    )
                  ],
                ),
              ),

              Text(tag == null ? 'Highlights' : tag!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10,),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  itemCount: cards.length, // Replace with the actual number of courses
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditFlashcardDialog(
                            flashcardId: cards[index].id,
                            courseId: widget.courseId,
                            question: cards[index].question,
                            answer: cards[index].answer,
                            tag: cards[index].tag,
                            onCardUpdated: updateCards,
                          )));
                        },
                        child: CardItem(question: cards[index].question, tag: cards[index].tag,));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}



// Actual questions
class CardItem extends StatelessWidget {
  final String question;
final String tag;
  const CardItem({required this.question,required this.tag});

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
              color:tag=='Easy'?Color(0xff7ed957).withOpacity(0.5)
                  :tag=='Medium'?Color(0xffd9d957).withOpacity(0.5)
                  :Color(0xffd95757).withOpacity(0.5),
            ),
            child: ListTile(

              title: Text(question,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // onTap: (){
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardScreen(courseId: CourseId)));
              // },
            ),
          ),
        ],
      ),
    );
  }
}


