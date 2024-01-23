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
    example += 'You are a virtual assistant helping with my timetable. Today is ${getCurrentDay()}'
    ' by this understand what would be the further days and I am giving you my  time table use this to answer my questions. For entries which are '
    ' not permanent those can be replaced by any other activities i would like to perform but for'
    ' permanent entries i want to keep them fixed. other than specified entry times I am free whole day and assume I sleep from 23:00 to 7:00  If no timetable is provided then i want you to'
    'reply me back that go to profile section and add your timetable there .';

    debugPrint('example $example');
    //print('example $example');
    if (timetableDataString != null && timetableDataString.isNotEmpty) {
      Map<String, dynamic> timetableData = json.decode(timetableDataString);
      return timetableDataString;
    } else {
      // If the data is not available in SharedPreferences
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
    // Create a ChatMessage for the example message
    // ChatMessage exampleMessage = ChatMessage(
    //   text: example,
    //   user: chatUser, // Use the current user for the example message
    //   createdAt: DateTime.now(),
    // );

    // Send the example message without displaying it
   // getChatResponse(exampleMessage, true);
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
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 75),
          child: HeaderL(),
        ),
        body: DashChat(
          currentUser: chatUser,
          onSend: (ChatMessage m) {
            getChatResponse(m, false);
          },
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
