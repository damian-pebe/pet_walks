import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:intl/intl.dart';
import 'package:petwalks_app/widgets/titleW.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  const ChatView({required this.chatId, super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  TextEditingController messageController = TextEditingController();

  String? fetchedEmail;
  void initVars() async {
    fetchedEmail = await fetchUserEmail();
  }

  @override
  void initState() {
    initVars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
      home: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                const titleW(title: 'Chat'),
                Positioned(
                    left: 30,
                    top: 70,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 30, color: Colors.black),
                    )),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: getChatStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No messages"));
                  }

                  List<dynamic> messages = snapshot.data!;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      DateTime messageDate =
                          DateTime.fromMillisecondsSinceEpoch(message['t']);
                      String formattedDate =
                          DateFormat('MM/dd/yy hh:mm a').format(messageDate);
                      bool form = fetchedEmail == message['s'];

                      return Align(
                        alignment: message['s'] == 'admin'
                            ? Alignment.centerLeft
                            : form
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message['s'] == 'admin'
                                ? const Color.fromRGBO(155, 178, 215, 1)
                                : (form
                                    ? const Color.fromRGBO(169, 200, 149, 1)
                                    : const Color.fromRGBO(203, 203, 203, 1)),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['m'], // Message content
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min, // Set min size
                                children: [
                                  if (message['s'] == 'admin')
                                    Text(
                                      'ADMIN',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black87),
                                    ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    formattedDate, // Timestamp
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Add a new suggestion...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        updateChatWithNewMessage(widget.chatId, {
                          "m": messageController.text,
                          "t": DateTime.now().millisecondsSinceEpoch,
                          "s": fetchedEmail,
                        });
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
