// ignore_for_file: prefer_final_fields, deprecated_member_use

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:intl/intl.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  const ChatView({required this.chatId, super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
//VIDEOS
  Future<String?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.first.size < 40 * 1024 * 1024) {
      final videoFile = result.files.first;
      final storageRef =
          FirebaseStorage.instance.ref().child('videos/${videoFile.name}');
      final uploadTask = await storageRef.putFile(File(videoFile.path!));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    }

    return null;
  }

  //IMAGES
  List<File> _imageFiles = [];
  List<String> _downloadUrls = [];

  Future<List<String>?> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 80);

    setState(() {
      _imageFiles =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
    return await _uploadImages();
  }

  Future<List<String>?> _uploadImages() async {
    if (_imageFiles.isEmpty) return null;

    for (var imageFile in _imageFiles) {
      final fileName = path.basename(imageFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/chats/${widget.chatId}/$fileName');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      setState(() {
        _downloadUrls.add(url);
      });
    }
    return _downloadUrls;
  }

  //!FILES
  String? downloadUrl;

  Future<String?> uploadFileAndSaveUrl() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        downloadUrl = fileName;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('uploads/documents')
            .child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() => null);

        String downloadURL = await ref.getDownloadURL();

        return downloadURL;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //! launch the file
  Future<void> _launchFileUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Check if the file is a PDF
  bool isPdf(String url) {
    return url.contains(".pdf");
  }

// Check if the file is a Word document
  bool isWordDoc(String url) {
    return url.contains(".doc") || url.endsWith(".docx");
  }

  bool isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }

  Widget buildFilePreview(String fileUrl) {
    if (!isPdf(fileUrl)) {
      return GestureDetector(
        onTap: () => _launchFileUrl(fileUrl),
        child: const Column(
          children: [
            Icon(Icons.play_circle_outline, size: 50, color: Colors.blue),
            Text('Reproducir Video'),
          ],
        ),
      );
    } else if (isPdf(fileUrl)) {
      return GestureDetector(
        onTap: () => _launchFileUrl(fileUrl),
        child: const Column(
          children: [
            Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
            Text('Abrir PDF'),
          ],
        ),
      );
    } else if (isWordDoc(fileUrl)) {
      return GestureDetector(
        onTap: () => _launchFileUrl(fileUrl),
        child: const Column(
          children: [
            Icon(Icons.description, size: 50, color: Colors.blue),
            Text('Abrir Documento Word'),
          ],
        ),
      );
    } else {
      return const Text('Tipo de archivo no soportado');
    }
  }

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
                    return const Center(
                        child: SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 50.0));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No messages"));
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
                              if (message['m'] != null)
                                Text(
                                  message['m'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              if (message['f'] != null)
                                if (message['f'] != null)
                                  buildFilePreview(message['f'].toString()),
                              if (message['i'] != null)
                                PhotoCarousel(
                                  imageUrls: (message['i'] as List<dynamic>)
                                      .map((item) => item.toString())
                                      .toList(),
                                ),
                              if (message['v'] != null)
                                buildFilePreview(message['v'].toString()),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min, // Set min size
                                children: [
                                  if (message['s'] == 'admin')
                                    const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black87),
                                    ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    formattedDate, // Timestamp
                                    style: const TextStyle(
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
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.black),
                    onPressed: () async {
                      //?file picker
                      String? fileUrl = await uploadFileAndSaveUrl();
                      if (fileUrl != null) {
                        //?file picker is not empty
                        updateChatWithNewMessage(widget.chatId, {
                          "f": fileUrl,
                          "t": DateTime.now().millisecondsSinceEpoch,
                          "s": fetchedEmail,
                        });
                        messageController.clear();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_search, color: Colors.black),
                    onPressed: () async {
                      List<String>? imagesUrl = await _pickImages();
                      if (imagesUrl != null) {
                        updateChatWithNewMessage(widget.chatId, {
                          "i": imagesUrl,
                          "t": DateTime.now().millisecondsSinceEpoch,
                          "s": fetchedEmail,
                        });
                        messageController.clear();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_collection_sharp,
                        color: Colors.black),
                    onPressed: () async {
                      String? videoUrl = await pickVideo();
                      if (videoUrl != null) {
                        updateChatWithNewMessage(widget.chatId, {
                          "v": videoUrl,
                          "t": DateTime.now().millisecondsSinceEpoch,
                          "s": fetchedEmail,
                        });
                        messageController.clear();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: '...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
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
