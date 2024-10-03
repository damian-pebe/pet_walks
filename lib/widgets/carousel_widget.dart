import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PhotoCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const PhotoCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: SpinKitSpinningLines(
                            color: Color.fromRGBO(169, 200, 149, 1),
                            size: 50.0));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image not available'));
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
