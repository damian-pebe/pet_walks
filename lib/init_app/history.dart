import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:petwalks_app/init_app/servicios/chat.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_end_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_requests.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_start_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/view_history.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  List<String> selectedPets = [];
  Future<Set<Map<String, dynamic>>>? _futureHistory;
  Future<Map<String, dynamic>>? futureWalk;
  List<String> idsHistory = [];
  String? email;
  int _expandedIndex = -1; //!check this for refresh dataa and requests
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
                        return const SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 15.0);
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: TextStyle(color: Colors.black),
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
                        return const SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 15.0);
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: TextStyle(color: Colors.black),
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
                        return const SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 15.0);
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('0');
                      }
                      return Text(
                        '(${snapshot.data!.length.toString()})',
                        style: const TextStyle(color: Colors.black),
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

  Widget _buildMenuItem(String title, int index) {
    bool isSelected =
        _selectedIndex == index; // Check if the menu item is selected
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update selected index
        });
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(169, 200, 149, 1)
              : Colors.grey, // Green background for selected
          borderRadius:
              BorderRadius.circular(20), // Rounded corners for menu items
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black, // White text for selected
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 18, // Font size for menu items
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      body: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMenuItem('History', 0),
                      _buildMenuItem('Requests', 1),
                      _buildMenuItem('Chats', 2),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: [
                      //!PAGES HERE
                      Column(children: [
                        Expanded(
                          child: FutureBuilder<Set<Map<String, dynamic>>>(
                            future: _futureHistory,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: SpinKitSpinningLines(
                                        color: Color.fromRGBO(169, 200, 149, 1),
                                        size: 50.0));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No history available'));
                              }

                              final historyList = snapshot.data!.toList();

                              // Sorting the historyList
                              historyList.sort((a, b) {
                                // Define your order
                                int statusOrder(String status) {
                                  switch (status) {
                                    case 'walking':
                                      return 1; // Walking comes first
                                    case 'awaiting':
                                      return 2; // Awaiting comes second
                                    case 'done':
                                      return 3; // Done comes last
                                    default:
                                      return 4; // Any other status comes last
                                  }
                                }

                                return statusOrder(a['status'])
                                    .compareTo(statusOrder(b['status']));
                              });

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
                                            child: SpinKitSpinningLines(
                                                color: Color.fromRGBO(
                                                    169, 200, 149, 1),
                                                size: 50.0));
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
                                      String imageUrl;

                                      // Assign an image based on status
                                      switch (history['status']) {
                                        case 'walking':
                                          imageUrl =
                                              'https://img.freepik.com/foto-gratis/primer-plano-accesorios-perros_23-2150959988.jpg?t=st=1727903534~exp=1727907134~hmac=76153b034d84289ac8f5cea3d7237c278be597dc73a4d3bbff20dbd0aaa9175e&w=1060'; // Change to your walking image URL
                                          break;
                                        case 'awaiting':
                                          imageUrl =
                                              'https://img.freepik.com/foto-gratis/vista-superior-accesorios-mascotas_23-2150930448.jpg?t=st=1727903514~exp=1727907114~hmac=396a3e7ca5afc65bf96569a04f0a2cc2bd46887b001f0e0debe951c77536c40a&w=1060'; // Change to your awaiting image URL
                                          break;
                                        case 'done':
                                          imageUrl =
                                              'https://img.freepik.com/foto-gratis/endecha-plana-juguetes-plato-comida-cepillo-pelo-perros_23-2148949620.jpg?t=st=1727903453~exp=1727907053~hmac=9bf5cd044c90a0480bfddaf7e41eb814f6cb82de63dee36db7ddcb240149afa1&w=1380'; // Change to your done image URL
                                          break;
                                        default:
                                          imageUrl =
                                              'https://img.freepik.com/foto-gratis/accesorios-mascotas-plato-comida-golosinas_23-2148949588.jpg?t=st=1727896386~exp=1727899986~hmac=ecd7a75c047d3f274a71779ee4edc8cec524a20efcd843a633d5702b38e9d68a&w=826'; // Default image URL
                                      }

                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                    255, 52, 91, 146)
                                                .withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                            image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                                opacity: .4),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      walkData['type'] == 'walk'
                                                          ? (lang!
                                                              ? 'Paseo'
                                                              : 'Walk')
                                                          : (lang!
                                                              ? 'Viaje'
                                                              : 'Travel'),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .more_time_rounded,
                                                            color: Colors.black,
                                                            size: 30),
                                                        const SizedBox(
                                                            width: 5),
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
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black)),
                                                            Text(
                                                              history['status'] ==
                                                                      'awaiting'
                                                                  ? (lang!
                                                                      ? ''
                                                                      : '')
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
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      (history['timeStart'] ==
                                                                  null ||
                                                              history['timeStart']
                                                                  .toString()
                                                                  .isEmpty)
                                                          ? (lang!
                                                              ? 'Esperando'
                                                              : 'Awaiting')
                                                          : (history['timeStart']
                                                                  is Timestamp)
                                                              ? DateFormat(
                                                                      'd/M/y h:mm a')
                                                                  .format((history['timeStart']
                                                                          as Timestamp)
                                                                      .toDate())
                                                              : DateTime.tryParse(history['timeStart']
                                                                          .toString()) !=
                                                                      null
                                                                  ? DateFormat(
                                                                          'd/M/y h:mm a')
                                                                      .format(DateTime.parse(history['timeStart']
                                                                          .toString()))
                                                                  : history['timeStart']
                                                                      .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons
                                                            .payments_outlined),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(walkData['price']
                                                            .toString()),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    FutureBuilder<
                                                        Set<
                                                            Map<String,
                                                                dynamic>>>(
                                                      future: fetchImageNamePet(List<
                                                          String>.from(walkData[
                                                              'selectedPets'] ??
                                                          [])),
                                                      builder: (context,
                                                          petsSnapshot) {
                                                        if (petsSnapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child: SpinKitSpinningLines(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          169,
                                                                          200,
                                                                          149,
                                                                          1),
                                                                  size: 50.0));
                                                        } else if (petsSnapshot
                                                            .hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  'Error: ${petsSnapshot.error}'));
                                                        } else if (!petsSnapshot
                                                                .hasData ||
                                                            petsSnapshot.data!
                                                                .isEmpty) {
                                                          return const Center(
                                                              child: Text(
                                                                  'No pets selected'));
                                                        }

                                                        final pets =
                                                            petsSnapshot.data!;
                                                        return Row(
                                                          children:
                                                              pets.map((pet) {
                                                            return Column(
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          200],
                                                                  child:
                                                                      ClipOval(
                                                                    child: pet['imageUrl'] !=
                                                                            null
                                                                        ? Image
                                                                            .network(
                                                                            pet['imageUrl'],
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                          )
                                                                        : const Icon(
                                                                            Icons
                                                                                .pets,
                                                                            size:
                                                                                40),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  pet['name'] ??
                                                                      'unknown',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        );
                                                      },
                                                    ),
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
                                                              'timeStart'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 30,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ]),

                      Column(
                        children: [
                          email == null
                              ? const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0))
                              : _buildPendingRequest(
                                  title: lang!
                                      ? 'Solicitudes pendientes'
                                      : 'Pending requests',
                                  futurePendingRequests: pendingRequests,
                                  index: 0,
                                ),
                          email == null
                              ? const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0))
                              : _buildStartRequest(
                                  title: lang!
                                      ? 'Solicitudes de inicio'
                                      : 'Start requests',
                                  futureStartRequests: futureStartRequests,
                                  index: 1,
                                ),
                          email == null
                              ? const Center(
                                  child: SpinKitSpinningLines(
                                      color: Color.fromRGBO(169, 200, 149, 1),
                                      size: 50.0))
                              : _buildEndRequest(
                                  title: lang!
                                      ? 'Solicitudes de termino'
                                      : 'End requests',
                                  futureEndRequests: futureEndRequests,
                                  index: 2,
                                ),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<Set<Map<String, dynamic>>>(
                              future: getChats(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: SpinKitSpinningLines(
                                          color:
                                              Color.fromRGBO(169, 200, 149, 1),
                                          size: 50.0));
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
                                        ? chat['user2']
                                        : chat['user1'];

                                    return Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 300),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                                  255, 52, 91, 146)
                                              .withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          image: const DecorationImage(
                                            image: NetworkImage(
                                                'https://img.freepik.com/foto-gratis/accesorios-mascotas-concepto-naturaleza-muerta-pequenas-golosinas_23-2148949577.jpg?t=st=1727896230~exp=1727899830~hmac=1dfe3caa016b1f57fc2193f835ba0ba0ebe6c45b1d5efb30126d2b43c928de4e&w=1060'),
                                            fit: BoxFit.cover,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FutureBuilder<String?>(
                                              future:
                                                  getProfilePhoto(otherUser),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircleAvatar(
                                                    radius: 5,
                                                    child: SpinKitSpinningLines(
                                                        color: Color.fromRGBO(
                                                            169, 200, 149, 1),
                                                        size: 50.0),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return CircleAvatar(
                                                    radius: 30,
                                                    child: const Icon(
                                                        Icons.error,
                                                        size: 50,
                                                        color: Colors.red),
                                                  );
                                                } else if (snapshot.hasData &&
                                                    snapshot.data != null) {
                                                  return CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        NetworkImage(
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
                                                  future:
                                                      getUserName(otherUser),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              SpinKitSpinningLines(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          169,
                                                                          200,
                                                                          149,
                                                                          1),
                                                                  size: 50.0));
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Center(
                                                          child: Text(
                                                              'Error: ${snapshot.error}'));
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        snapshot
                                                            .data!.isEmpty) {
                                                      return Center(
                                                          child: Text(lang!
                                                              ? 'desconocido'
                                                              : 'unknown'));
                                                    }
                                                    return Text(
                                                      snapshot.data!,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    );
                                                  },
                                                ),
                                                if (chat['messages'].isNotEmpty)
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      chat['messages']
                                                              .last['m'] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    chat['messages'] != null &&
                                                            chat['messages']
                                                                .isNotEmpty &&
                                                            chat['messages']
                                                                        .last[
                                                                    't'] !=
                                                                null
                                                        ? DateFormat(
                                                                'yyyy-MM-dd HH:mm')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    chat['messages']
                                                                            .last[
                                                                        't']))
                                                        : 'No Date Available',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
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
                                                    color: Colors.white))
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
