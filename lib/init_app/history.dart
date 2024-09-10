import 'package:flutter/material.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_end_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_requests.dart';
import 'package:petwalks_app/init_app/servicios/requests/manage_start_walk.dart';
import 'package:petwalks_app/init_app/servicios/requests/view_request.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petwalks_app/widgets/toast.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

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
  }

  Future<void> _initializeFutures() async {
    email = await fetchUserEmail();
    List<String> ids = await fetchHistoryIds(email!);
    setState(() {
      pendingRequests = fetchPendingRequests(email!);
      futureStartRequests = fetchPendingRequestStart(email!);
      futureEndRequests = fetchPendingRequestEnd(email!);
      _futureHistory = getHistory(ids);
    });
  }

  void _refreshData() {
    setState(() {
      pendingRequests = fetchPendingRequests(email!);
      futureStartRequests = fetchPendingRequestStart(email!);
      futureEndRequests = fetchPendingRequestEnd(email!);
    });
  }

  void _onSwipeLeft() {
    if (_currentPage < 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSwipeRight() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx < -10) {
            _onSwipeLeft();
          } else if (details.delta.dx > 10) {
            _onSwipeRight();
          }
        },
        child: PageView(
          controller: _pageController,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    const titleW(title: 'Historial'),
                    if (_currentPage == 0)
                      Positioned(
                          left: 330,
                          top: 70,
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    size: 30, color: Colors.black),
                                onPressed: () => setState(() {
                                  _onSwipeLeft();
                                }),
                              ),
                              const Text(
                                'Solicitudes',
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No history available'));
                    }

                    final historyList = snapshot.data!.toList();

                    return Expanded(
                      child: ListView.builder(
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
                                    child:
                                        Text('Error: ${walkSnapshot.error}'));
                              } else if (!walkSnapshot.hasData ||
                                  walkSnapshot.data!.isEmpty) {
                                return const Center(
                                    child:
                                        Text('No walk information available'));
                              }

                              final walkData = walkSnapshot.data!;

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
                                            walkData['type'] ?? 'type',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.more_time_rounded),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Fecha y hora'),
                                                  Text(walkData['timeStart'] ??
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
                                              const Icon(
                                                  Icons.payments_outlined),
                                              Text(
                                                  walkData['price'].toString()),
                                            ],
                                          ),
                                          FutureBuilder<Map<String, dynamic>>(
                                            future: fetchBuilderInfo(
                                                List<String>.from(
                                                    walkData['selectedPets'] ??
                                                        [])),
                                            builder: (context, petsSnapshot) {
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
                                                  petsSnapshot.data!.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        'No pets selected'));
                                              }

                                              final petsList =
                                                  petsSnapshot.data!;

                                              return Column(
                                                children: [
                                                  CircleAvatar(
                                                      child: petsList[
                                                                  'imageUrl'] !=
                                                              null
                                                          ? Image.network(
                                                              petsList[
                                                                  'imageUrl'])
                                                          : null),
                                                  Text(petsList['name'] ??
                                                      'no name'),
                                                ],
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          toastF('view info');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewRequest(
                                                emailOwner:
                                                    history['emailOwner'],
                                                emailWalker:
                                                    history['emailWalker'],
                                                idWalk: history['idWalk'],
                                                idBusiness:
                                                    history['idBusiness'] ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                        icon:
                                            const Icon(Icons.arrow_forward_ios),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                )),
              ],
            ),
            Column(
              children: [
                Stack(
                  children: [
                    const titleW(title: 'Solicitudes'),
                    Positioned(
                        left: 30,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => setState(() {
                                _onSwipeRight();
                              }),
                              icon: const Icon(Icons.arrow_back_ios,
                                  size: 30, color: Colors.black),
                            ),
                            const Text(
                              'Regresar',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )),
                  ],
                ),
                email == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPendingRequest(
                        title: 'Pending Requests',
                        futurePendingRequests: pendingRequests,
                        index: 0,
                      ),
                email == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildStartRequest(
                        title: 'Start requests',
                        futureStartRequests: futureStartRequests,
                        index: 1,
                      ),
                email == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEndRequest(
                        title: 'End requests',
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
