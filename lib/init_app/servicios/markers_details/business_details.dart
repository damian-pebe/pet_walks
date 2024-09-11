import 'package:flutter/material.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                  height: 200,
                  child: PhotoCarousel(
                    imageUrls:
                        widget.imageUrls.isNotEmpty ? widget.imageUrls : [],
                  )),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text("Domicilio: ${widget.address}"),
            Text("Telefono: ${widget.phone}"),
            Divider(),
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
                SizedBox(width: 8.0),
                Text("${widget.rating}/5"),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    showCommentsDialog(
                        context, widget.comments, 'business', id ?? 'null');
                  },
                  child: const Text(
                    "Comentarios",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelTo(
                            address: widget.address, geoPoint: widget.geoPoint),
                      )),
                  icon: Icon(
                    Icons.flight_takeoff,
                    size: 35,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.report_outlined,
                    size: 35,
                  ),
                ),
              ],
            ),
            Divider(),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
