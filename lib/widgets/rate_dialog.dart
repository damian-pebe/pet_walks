import 'package:flutter/material.dart';

void showRatingPopup(BuildContext context, double currentRating,
    Function(double) onRatingSelected) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double tempRating = currentRating;

      return AlertDialog(
        title: const Text('Rate the User'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  '${tempRating.toString()}/5',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Calificar'),
            onPressed: () {
              onRatingSelected(tempRating);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
