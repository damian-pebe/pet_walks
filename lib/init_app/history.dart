import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:petwalks_app/init_app/servicios/chat.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_end_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_requests.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_start_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/view_request.dart';
import 'package:petwalks_app/init_app/servicios/view_chats.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  List<String> selectedPets = [];
  Future<Set<Map<String, dynamic>>>? _futureHistory;
  Future<Map<String, dynamic>>? futureWalk;
  List<String> idsHistory = [];
  String? email;
  int _expandedIndex = -1;
  Future<List<DocumentSnapshot>>? pendingRequests;
  Future<List<DocumentSnapshot>>? futureStartRequests;
  Future<List<DocumentSnapshot>>? futureEndRequests;
  @override
  void initState() {
    super.initState();
    _initializeFutures();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  Future<void> _initializeFutures() async {
    email = await fetchUserEmail();
    List<String> ids = await fetchHistoryIds(email!);
    pendingRequests = fetchPendingRequests(email!);
    futureStartRequests = fetchPendingRequestStart(email!);
    futureEndRequests = fetchPendingRequestEnd(email!);
    _futureHistory = getHistory(ids);
    if (mounted) setState(() {});
  }

  void _refreshData() async {
    List<String> ids = await fetchHistoryIds(email!);

    pendingRequests = fetchPendingRequests(email!);
    futureStartRequests = fetchPendingRequestStart(email!);
    futureEndRequests = fetchPendingRequestEnd(email!);
    _futureHistory = getHistory(ids);
    setState(() {});
  }

  void _onSwipeLeft() {
    if (_currentPage < 1) {
      setState(() {
        _currentPage++;
      });
      setState(() {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _onSwipeRight() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      setState(() {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Widget _buildPendingRequest({
    required String title,
    required Future<List<DocumentSnapshot>>? futurePendingRequests,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? -1 : index;
                _refreshData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        _expandedIndex == index
                            ? Icons.arrow_back_ios
                            : Icons.arrow_drop_down_sharp,
                        size: 24,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _expandedIndex == index ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      )
                    ],
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: futurePendingRequests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: TextStyle(color: Colors.brown[600]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _expandedIndex == index
              ? const SizedBox(
                  height: 560, child: PendingRequestsNotifications())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildStartRequest({
    required String title,
    required Future<List<DocumentSnapshot>>? futureStartRequests,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? -1 : index;
                _refreshData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        _expandedIndex == index
                            ? Icons.arrow_back_ios
                            : Icons.arrow_drop_down_sharp,
                        size: 24,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _expandedIndex == index ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      )
                    ],
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: futureStartRequests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: TextStyle(color: Colors.brown[600]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _expandedIndex == index
              ? const SizedBox(height: 560, child: StartWalkManagement())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildEndRequest({
    required String title,
    required Future<List<DocumentSnapshot>>? futureEndRequests,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? -1 : index;
                _refreshData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        _expandedIndex == index
                            ? Icons.arrow_back_ios
                            : Icons.arrow_drop_down_sharp,
                        size: 24,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _expandedIndex == index ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      )
                    ],
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: futureEndRequests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: TextStyle(color: Colors.brown[600]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _expandedIndex == index
              ? const SizedBox(height: 560, child: EndWalkManagement())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      body: lang == null
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx < -10) {
                  _onSwipeLeft();
                  _refreshData();
                } else if (details.delta.dx > 10) {
                  _onSwipeRight();
                  _refreshData();
                }
              },
              child: PageView(
                controller: _pageController,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          titleW(title: 'Chats'),
                          Positioned(
                              left: 330,
                              top: 70,
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.swipe_right,
                                        size: 30, color: Colors.black),
                                    onPressed: () => setState(() {
                                      _onSwipeLeft();
                                      _refreshData();
                                    }),
                                  ),
                                  Text(
                                    lang! ? 'Historial' : 'History',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              )),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder<Set<Map<String, dynamic>>>(
                          future: getChats(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text(lang!
                                  ? 'Primero inicia un chat'
                                  : 'First, start a chat');
                            }

                            List<Map<String, dynamic>> chats =
                                snapshot.data!.toList();

                            return ListView.builder(
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                var chat = chats[index];
                                String otherUser = email == chat['user1']
                                    ? chat['user1']
                                    : chat['user1'];

                                return Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(149, 175, 200, 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FutureBuilder<String?>(
                                          future: getProfilePhoto(otherUser),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircleAvatar(
                                                radius: 5,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return CircleAvatar(
                                                radius: 30,
                                                child: const Icon(Icons.error,
                                                    size: 50,
                                                    color: Colors.red),
                                              );
                                            } else if (snapshot.hasData &&
                                                snapshot.data != null) {
                                              return CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    snapshot.data!),
                                                child: null,
                                              );
                                            } else {
                                              return const CircleAvatar(
                                                radius: 30,
                                                child: Icon(Icons.person,
                                                    size: 50,
                                                    color: Colors.grey),
                                              );
                                            }
                                          },
                                        ),
                                        Column(
                                          children: [
                                            FutureBuilder<String?>(
                                              future: getUserName(otherUser),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'));
                                                } else if (!snapshot.hasData ||
                                                    snapshot.data!.isEmpty) {
                                                  return Center(
                                                      child: Text(lang!
                                                          ? 'desconocido'
                                                          : 'unknown'));
                                                }
                                                return Text(
                                                  snapshot.data!,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                );
                                              },
                                            ),
                                            if (chat['messages'].isNotEmpty)
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  chat['messages'].last['m'],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  DateFormat('MM/dd/yy hh:mm a')
                                                      .format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                      chat['messages']
                                                          .last['t'],
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatView(
                                                              chatId: chat[
                                                                  'chatId'])));
                                            },
                                            icon: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 30,
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          titleW(title: lang! ? 'Historial' : 'History'),
                          Positioned(
                              left: 30,
                              top: 70,
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _onSwipeRight();
                                      _refreshData();
                                    }),
                                    icon: const Icon(Icons.swipe_left,
                                        size: 30, color: Colors.black),
                                  ),
                                  Text(
                                    'Chats',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              )),
                          Positioned(
                              left: 330,
                              top: 70,
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.swipe_right,
                                        size: 30, color: Colors.black),
                                    onPressed: () => setState(() {
                                      _onSwipeLeft();
                                      _refreshData();
                                    }),
                                  ),
                                  Text(
                                    lang! ? 'Solicitudes' : 'Request',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              )),
                        ],
                      ),
                      Expanded(
                          child: FutureBuilder<Set<Map<String, dynamic>>>(
                        future: _futureHistory,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No history available'));
                          }

                          final historyList = snapshot.data!.toList();

                          return ListView.builder(
                            itemCount: historyList.length,
                            itemBuilder: (context, index) {
                              final history = historyList[index];

                              return FutureBuilder<Map<String, dynamic>>(
                                future: getInfoWalk(history['idWalk']),
                                builder: (context, walkSnapshot) {
                                  if (walkSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (walkSnapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Error: ${walkSnapshot.error}'));
                                  } else if (!walkSnapshot.hasData ||
                                      walkSnapshot.data!.isEmpty) {
                                    return Center(
                                        child: Text(lang!
                                            ? 'No hay informacion de paseos disponibles'
                                            : 'No walk information available'));
                                  }

                                  final walkData = walkSnapshot.data!;

                                  return Card(
                                    color:
                                        const Color.fromARGB(255, 163, 114, 96),
                                    margin: const EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                walkData['type'] == 'walk'
                                                    ? lang!
                                                        ? 'Paseo'
                                                        : 'Walk'
                                                    : lang!
                                                        ? 'Viaje'
                                                        : 'Travel',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.more_time_rounded,
                                                    size: 30,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        lang!
                                                            ? 'Estatus'
                                                            : 'Status',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        history['status'] ==
                                                                'awaiting'
                                                            ? (lang!
                                                                ? 'Esperando'
                                                                : 'Awaiting')
                                                            : history['status'] ==
                                                                    'walking'
                                                                ? (lang!
                                                                    ? 'Paseando'
                                                                    : 'Walking')
                                                                : (lang!
                                                                    ? 'Finalizado'
                                                                    : 'Done'),
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                (history['timeStart'] == null ||
                                                        history['timeStart']
                                                            .toString()
                                                            .isEmpty)
                                                    ? (lang!
                                                        ? 'Esperando'
                                                        : 'Awaiting')
                                                    : (history['timeStart']
                                                            is Timestamp)
                                                        ? () {
                                                            return DateFormat(
                                                                    'd/M/y h:mm a')
                                                                .format((history[
                                                                            'timeStart']
                                                                        as Timestamp)
                                                                    .toDate());
                                                          }()
                                                        : DateTime.tryParse(history[
                                                                        'timeStart']
                                                                    .toString()) !=
                                                                null
                                                            ? () {
                                                                return DateFormat(
                                                                        'd/M/y h:mm a')
                                                                    .format(DateTime.parse(
                                                                        history['timeStart']
                                                                            .toString()));
                                                              }()
                                                            : () {
                                                                return history[
                                                                        'timeStart']
                                                                    .toString();
                                                              }(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.payments_outlined),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(walkData['price']
                                                      .toString()),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              FutureBuilder<
                                                  Set<Map<String, dynamic>>>(
                                                future: fetchImageNamePet(
                                                    List<String>.from(walkData[
                                                            'selectedPets'] ??
                                                        [])),
                                                builder:
                                                    (context, petsSnapshot) {
                                                  if (petsSnapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  } else if (petsSnapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error: ${petsSnapshot.error}'));
                                                  } else if (!petsSnapshot
                                                          .hasData ||
                                                      petsSnapshot
                                                          .data!.isEmpty) {
                                                    return const Center(
                                                        child: Text(
                                                            'No pets selected'));
                                                  }

                                                  final pets =
                                                      petsSnapshot.data!;
                                                  print(
                                                      'info[selectedPets]: $pets');

                                                  return Row(
                                                    children: pets.map((pet) {
                                                      return Column(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[200],
                                                            child: ClipOval(
                                                              child: pet['imageUrl'] !=
                                                                      null
                                                                  ? Image
                                                                      .network(
                                                                      pet['imageUrl'],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .pets,
                                                                      size: 40),
                                                            ),
                                                          ),
                                                          Text(
                                                            pet['name'] ??
                                                                'unknown',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewRequest(
                                                          emailOwner: history[
                                                              'emailOwner'],
                                                          emailWalker: history[
                                                              'emailWalker'],
                                                          idWalk:
                                                              history['idWalk'],
                                                          idBusiness: history[
                                                                  'idBusiness'] ??
                                                              '',
                                                          idHistory:
                                                              history['id'],
                                                          status:
                                                              history['status'],
                                                          timeStart: history[
                                                              'timeStart']),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 30,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      )),
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          titleW(title: lang! ? 'Solicitudes' : 'Requests'),
                          Positioned(
                              left: 30,
                              top: 70,
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _onSwipeRight();
                                      _refreshData();
                                    }),
                                    icon: const Icon(Icons.swipe_left,
                                        size: 30, color: Colors.black),
                                  ),
                                  Text(
                                    lang! ? 'Historial' : 'History',
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              )),
                        ],
                      ),
                      email == null
                          ? const Center(child: CircularProgressIndicator())
                          : _buildPendingRequest(
                              title: lang!
                                  ? 'Solicitudes pendientes'
                                  : 'Pending requests',
                              futurePendingRequests: pendingRequests,
                              index: 0,
                            ),
                      email == null
                          ? const Center(child: CircularProgressIndicator())
                          : _buildStartRequest(
                              title: lang!
                                  ? 'Solicitudes de inicio'
                                  : 'Start requests',
                              futureStartRequests: futureStartRequests,
                              index: 1,
                            ),
                      email == null
                          ? const Center(child: CircularProgressIndicator())
                          : _buildEndRequest(
                              title: lang!
                                  ? 'Solicitudes de termino'
                                  : 'End requests',
                              futureEndRequests: futureEndRequests,
                              index: 2,
                            ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
