import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrecedentTile extends StatelessWidget {
  final String title;
  final String bench;
  final String date;
  final String summary;

  PrecedentTile({
    super.key,
    required this.title,
    required this.bench,
    required this.date,
    required this.summary,
  });

  final List<String> imageUrls = [
    "assets/images/logo.png",
    "assets/images/background.png",
    "assets/images/logo1.png",
    "assets/images/profile_photo.jpg",
  ];

  String getRandomImage() {
    final random = Random();
    return imageUrls[random.nextInt(imageUrls.length)];
  }

  @override
  Widget build(BuildContext context) {
    final image = getRandomImage();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image (SVG or fallback PNG)
            SizedBox(
              width: 60,
              height: 60,
              child: image.endsWith(".svg")
                  ? SvgPicture.network(
                      image,
                      placeholderBuilder: (context) => CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    )
                  : Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 20),

            // Precedent Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Judgment by: $bench"),
                  const SizedBox(height: 5),
                  Text("Date: $date"),
                  const SizedBox(height: 5),
                  Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
