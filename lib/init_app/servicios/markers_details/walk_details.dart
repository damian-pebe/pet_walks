import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/box.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/comments_dialog.dart';
import 'package:petwalks_app/widgets/decorations.dart';

class WalkDetails extends StatefulWidget {
  final String payMethod;
  final int price;
  final String walkWFriends;
  final String timeWalking;
  final String place;
  final String description;
  final List<String> selectedPets;
  final String travelTo;
  final GeoPoint travelToPosition;
  final String ownerEmail;
  final String id;

  const WalkDetails({
    required this.payMethod,
    required this.price,
    required this.walkWFriends,
    required this.timeWalking,
    required this.place,
    required this.description,
    required this.selectedPets,
    required this.travelTo,
    required this.travelToPosition,
    required this.ownerEmail,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  State<WalkDetails> createState() => _WalkDetailsState();
}

class _WalkDetailsState extends State<WalkDetails> {
  bool _isLoading = false;
  Map<String, dynamic> showData = {};
  Map<String, dynamic> showDatas = {};

  late List<String> idPets;

  late String email;
  void _email() async {
    email = await fetchUserEmail();
    _fetchBuilderInfo();
  }

  @override
  void initState() {
    super.initState();
    idPets = List<String>.from(widget.selectedPets);
    _email();
  }

  void _fetchBuilderInfo() async {
    showData = await fetchBuilderInfo(idPets);
    showDatas = await fetchBuilderInfos(idPets);
    print('idpets: ${idPets}');
    if (idPets.isNotEmpty) {
      getInfoFirstCarrousel();
    }
    setState(() {});
  }

  Future<List<String>> _array() async {
    return idPets;
  }

  void updateInfoCarrousel(List<dynamic> _imageUrls,
      List<dynamic> _commentsPets, double _rating, String _name) {
    setState(() {
      imageUrls = List<String>.from(_imageUrls);
      commentsPets = List<String>.from(_commentsPets);
      rating = _rating;
      name = _name;
    });
  }

  void getInfoFirstCarrousel() {
    var id = idPets[0];
    var temp = showDatas[id];
    List<dynamic> _imageUrls = temp['imageUrls'];
    List<dynamic> _commentsPets = temp['comments'];
    double _rating = temp['rating'];
    String _name = temp['name'];

    updateInfoCarrousel(_imageUrls, _commentsPets, _rating, _name);
  }

  void showCommentsDialog(BuildContext context, List<dynamic> comments) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return CommentsDialog(comments: comments);
      },
    );
  }

  List<String> imageUrls = [];
  List<String> commentsPets = [];
  double rating = 0.0;
  String name = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Pasear mascotas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: SizedBox(
                height: 200,
                child: PhotoCarousel(imageUrls: imageUrls),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(rating > 0 ? Icons.star : Icons.star_border,
                        color: Colors.amber),
                    Icon(rating > 1 ? Icons.star : Icons.star_border,
                        color: Colors.amber),
                    Icon(rating > 2 ? Icons.star : Icons.star_border,
                        color: Colors.amber),
                    Icon(rating > 3 ? Icons.star : Icons.star_border,
                        color: Colors.amber),
                    Icon(rating > 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber),
                    const SizedBox(width: 8.0),
                    Text("$rating/5"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        showCommentsDialog(context, commentsPets);
                      },
                      child: const Text(
                        "Comentarios",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 90,
              child: FutureBuilder<List<String>>(
                future: _array(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No pets fetching info'));
                  } else {
                    List<String> ids = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ids.length,
                      itemBuilder: (context, index) {
                        var id = ids[index];
                        var petInfo = showData[id] ?? {};
                        var petInfos = showDatas[id] ?? {};

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: petInfo['imageUrl'] != null
                                        ? NetworkImage(petInfo['imageUrl'])
                                        : null,
                                  ),
                                  onTap: () {
                                    updateInfoCarrousel(
                                      petInfos['imageUrls'] ?? {},
                                      petInfos['comments'] ?? {},
                                      petInfos['rating'] ?? 0.0,
                                      petInfos['name'] ?? 'Unknown',
                                    );
                                  },
                                ),
                                const EmptyBox(h: 5),
                                Text(petInfos['name'] ?? 'No name'),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const Divider(),
            Column(
              children: [
                Center(child: Text("Domicilio: ${widget.place}")),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pago"),
                        Row(
                          children: [
                            Icon(
                              widget.payMethod == 'Efectivo'
                                  ? Icons.attach_money_outlined
                                  : Icons.credit_card_sharp,
                              size: 20,
                            ),
                            Text(widget.price.toString()),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pasear con mas mascotas"),
                        Icon(
                          widget.walkWFriends == 'Si'
                              ? Icons.check
                              : Icons.cancel_outlined,
                          size: 20,
                        )
                      ],
                    ),
                  ],
                ),
                Divider(),
                Center(
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            child: widget.travelTo.isEmpty
                                ? Text("Tiempo de paseo: ${widget.timeWalking}")
                                : OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 131, 195, 248),
                                      side: BorderSide(
                                          color:
                                              Color.fromRGBO(250, 244, 229, 1),
                                          width: 2),
                                    ),
                                    child: Text(
                                      '   Ubicacion de destino   ',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 13,
                                          color: Colors.black),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        // String idWalk = await findMatchingWalkId(widget.id);
                        String? idBusiness =
                            await findMatchingBusinessId(widget.travelTo);
                        // String idOwner =
                        //     await findMatchingUserId();
                        // String idWalker = await findMatchingUserId();
                        await newPreHistory(
                            widget.id, widget.ownerEmail, email, idBusiness);

                        setState(() {
                          _isLoading = false;
                        });
                      },
                      style: customOutlinedButtonStyle(),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(
                                  Icons.flight,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Solicitar viaje",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDescriptionDialog(context, widget.description);
                      },
                      child: Text(
                        'Descripcion',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showDescriptionDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Descripcion:',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
