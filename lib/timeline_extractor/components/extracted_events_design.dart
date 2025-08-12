import 'package:flutter/material.dart';
//AIzaSyAW29Dmz7kNMBjhqOp2mP6iAIjgYPQ_sDo
class ExtractedEvents extends StatelessWidget {
  final Map<String, dynamic> event;
  const ExtractedEvents({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            event['date'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(event['description'], style: const TextStyle(fontSize: 14)),
          const Divider(height: 30),
        ],
      ),
    );
  }
}
