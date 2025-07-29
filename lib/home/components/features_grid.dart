import 'package:flutter/material.dart';

class FeaturesGrid extends StatelessWidget {
  final String widgetName;
  final String widgetDescription;
  final String widgetImage;

  const FeaturesGrid({
    super.key,
    required this.widgetName,
    required this.widgetDescription,
    required this.widgetImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10) ,
          child: Image.network(widgetImage, height: 250, width: 250,))
          ,
        SizedBox(height: 5),
        Text(widgetName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
        Text(widgetDescription, style: TextStyle(fontSize: 12, color: Colors.grey),)

        ]
      ),
    );
  }
}

