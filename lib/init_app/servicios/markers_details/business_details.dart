import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petwalks_app/init_app/servicios/travel_to.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';
import 'package:petwalks_app/widgets/comments_dialog.dart';

class BusinessDetails extends StatelessWidget {
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
    Key? key,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
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
                    imageUrls: imageUrls.isNotEmpty ? imageUrls : [],
                  )),
            ),
            SizedBox(height: 8.0),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text("Domicilio: $address"),
            Text("Telefono: $phone"),
            Divider(),
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
                SizedBox(width: 8.0),
                Text("$rating/5"),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    showCommentsDialog(context, comments);
                  },
                  child: Text(
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
                        builder: (context) =>
                            TravelTo(address: address, geoPoint: geoPoint),
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
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
