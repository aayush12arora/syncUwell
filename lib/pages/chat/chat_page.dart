import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncuwell/const.dart';

import '../../Utils/headerfile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String example =
      " ";
  late OpenAI openAI;


  // Function to get  current day of the week
  String getCurrentDay() {
    DateTime now = DateTime.now();
    int dayIndex = now.weekday;

    switch (dayIndex) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }



  Future<String?> getTimetableFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timetableDataString = prefs.getString('timetable_data');

    print('timetableDataString $timetableDataString');

    example = 'My current timetable is as follows :\n';
    example += timetableDataString!;
    example += "You are a virtual assistant helping with my timetable. Today is ${getCurrentDay()}. "
        "Please use this information to answer my questions about today's schedule or any other day's schedule as asked. "
        "If there is no timetable for today, kindly inform me."
        "For permanent entries, I want to keep them fixed , I cannot do any other activity during that entry time so dont suggest this time for any other activity. \n"
    "For non-permanent entries, I can do other activities during that entry time."
        "Other than specified entry times, I am free all day, and I assume I sleep from 23:00 to 7:00."
        "If no timetable is provided, reply that I should go to the profile section and add the timetable there.";

    debugPrint('example $example');
    //print('example $example');
    if (timetableDataString != null && timetableDataString.isNotEmpty) {
      Map<String, dynamic> timetableData = json.decode(timetableDataString);
      return timetableDataString;
    } else {

      return ''; // or handle it according to your use case
    }
  }

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
      token: OPENAI_API,
      baseOption: HttpSetup(receiveTimeout: Duration(seconds: 5)),
      enableLog: true,
    );

    // Load the timetable data from SharedPreferences
    getTimetableFromLocalStorage();

  }

  List<ChatMessage> messages = <ChatMessage>[];
  final ChatUser chatUser = ChatUser(firstName: 'Bob', id: '1');

  final ChatUser syncUwell = ChatUser(firstName: 'syncUWell', id: '2');
  List<ChatUser> typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(217, 227, 241, 0.8),
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 75),
          child: HeaderL(),
        ),
        body: DashChat(

          currentUser: chatUser,
          onSend: (ChatMessage m) {
            getChatResponse(m, false);
          },
messageOptions: MessageOptions(
  containerColor: Colors.white,
  currentUserContainerColor:Color(0xffff914d).withOpacity(0.5)
),
          messages: messages,
          typingUsers: typingUsers,


        ),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m, bool initial) async {
    if (!initial) {
      setState(() {
        messages.insert(0, m);
        typingUsers.add(syncUwell);
      });
    }
    List<Messages> _messageHistory= <Messages>[];


   _messageHistory = messages.reversed.map((m) {
      if (m.user == chatUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
// String? initialtt= await getTimetableFromLocalStorage();
//     print('initialtt  $initialtt');
    _messageHistory.insert(0, Messages(role: Role.user, content: example));
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messageHistory,
      maxToken: 500,
    );
    final response = await openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        if (!initial) {
          setState(() {
            messages.insert(
              0,
              ChatMessage(
                text: element.message!.content,
                user: syncUwell,
                createdAt: DateTime.now(),
              ),
            );
          });
        }
      }
    }

    setState(() {
      typingUsers.remove(syncUwell);
    });
  }
}
