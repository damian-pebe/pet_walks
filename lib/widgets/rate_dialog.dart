import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';

void showRatingPopup(BuildContext context, double currentRating,
    Function(double) onRatingSelected, String collection, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double tempRating = currentRating;

      return AlertDialog(
        backgroundColor: Color.fromARGB(159, 229, 248, 210),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Calificar / Rate',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          tempRating = index + 1.0;
                        });
                      },
                      child: Icon(
                        tempRating > index ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 50,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  '${tempRating.toString()}/5',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            );
          },
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Cancel button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(Icons.clear),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Confirm button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(Icons.check),
                onPressed: () {
                  addRateToUser(tempRating, collection, id);
                  onRatingSelected(tempRating);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
