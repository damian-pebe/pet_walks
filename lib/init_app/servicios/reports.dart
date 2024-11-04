import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/servicios/chat.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class Reports extends StatefulWidget {
  final bool lang;
  final List<String> options;
  final String sender;
  final String reported;
  final String priority;
  const Reports(
      {required this.lang,
      required this.options,
      required this.reported,
      required this.sender,
      required this.priority,
      super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  TextEditingController reasonController = TextEditingController(text: "");

  String? categoryController;
  final TextEditingController _categoryController =
      TextEditingController(text: "");

  List<String> category = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.options) {
      category.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      ),
      home: Scaffold(
        body: Column(
          children: [
            titleW(title: widget.lang ? 'Reportar' : 'Report'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lang ? 'Tipo de reporte' : 'Report type',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButton<String>(
                      value: categoryController,
                      isDense: true,
                      dropdownColor: Colors.grey[200],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black),
                      onChanged: (newValue) {
                        setState(() {
                          categoryController = newValue;
                          _categoryController.text = newValue ?? '';
                        });
                      },
                      items: category.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    Text(
                      widget.lang ? 'Razon de reportet' : 'Report reason',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Job Description
                    TextField(
                      decoration: InputDecoration(
                        labelText: widget.lang ? 'Razon' : 'Reason...',
                        border: const OutlineInputBorder(),
                      ),
                      controller: reasonController,
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                bool msg = widget.priority == 'low';
                String idChat = await newChatReport(widget.reported, msg);

                newReport(
                    widget.sender,
                    widget.reported,
                    '${_categoryController.text}: ${reasonController.text}',
                    widget.priority);

                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(chatId: idChat),
                  ),
                );
                toastF(widget.lang
                    ? 'Reporte creado con exito, Gracias!!'
                    : 'Report successfully created, Thank you!!');
              },
              style: customOutlinedButtonStyle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.dangerous_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    widget.lang ? 'Reportar' : 'Report',
                    style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
