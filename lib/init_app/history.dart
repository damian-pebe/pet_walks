import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/decorations.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:petwalks_app/widgets/toast.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  late Future<Set<Map<String, dynamic>>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = getHistory([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1)),
        home: Stack(
          children: [
            Scaffold(
                body: Column(
              children: [
                const titleW(title: 'Historial'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/logoApp.png',
                      width: 120,
                      height: 120,
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: customOutlinedButtonStyle(),
                      child: const Row(
                        children: [
                          Icon(Icons.chat_outlined, color: Colors.black),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Chats',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                FutureBuilder<Set<Map<String, dynamic>>>(
                    future: _futureHistory,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No history available'));
                      }

                      final historyList = snapshot.data!.toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final history = historyList[index];

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          history['type'] ?? 'type',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.more_time_rounded),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Fecha y hora'),
                                                Text(history['timeStart'] ??
                                                    'awaiting'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.payments_outlined),
                                            Text(history['billing'] ?? 'price'),
                                          ],
                                        ),
                                        ListView(
                                            //will have the pets list as walk details
                                            )
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => toastF('view info'),
                                      icon: const Icon(Icons.arrow_forward_ios),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ],
            )),
          ],
        ));
  }
}
