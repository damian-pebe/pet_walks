import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/init_app/servicios/travel_to.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/call_comments.dart';

class BusinessDetails extends StatefulWidget {
  final String name;
  final String address;
  final String phone;
  final String description;
  final double rating;
  final List<String> imageUrls;
  final List<dynamic> comments;
  final LatLng geoPoint;

  const BusinessDetails({
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.rating,
    required this.imageUrls,
    required this.comments,
    required this.geoPoint,
    super.key,
  });

  @override
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  @override
  void initState() {
    matchId();
    super.initState();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  String? id;
  matchId() async {
    id = await findMatchingBusinessId(widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(245, 255, 255, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: lang == null
          ? const Center(
              child: SpinKitSpinningLines(
                  color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: PhotoCarousel(
                        imageUrls:
                            widget.imageUrls.isNotEmpty ? widget.imageUrls : [],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(lang!
                      ? "Domicilio: ${widget.address}"
                      : "Address: ${widget.address}"),
                  Text(lang!
                      ? "Telefono: ${widget.phone}"
                      : "Phone: ${widget.phone}"),
                  const Divider(),
                  Row(
                    children: [
                      Icon(widget.rating > 0 ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      Icon(widget.rating > 1 ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      Icon(widget.rating > 2 ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      Icon(widget.rating > 3 ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      Icon(widget.rating > 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      const SizedBox(width: 8.0),
                      Text("${widget.rating}/5"),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          showCommentsDialog(context, widget.comments,
                              'business', id ?? 'null', true);
                        },
                        child: Text(
                          lang! ? "Comentarios" : "Comments",
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 50),
                      IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TravelTo(
                                  address: widget.address,
                                  geoPoint: widget.geoPoint),
                            )),
                        icon: const Icon(
                          Icons.flight_takeoff,
                          size: 35,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.report_outlined,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
