import 'package:flutter/material.dart';

class RecentCasesWidget extends StatelessWidget {
  const RecentCasesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Recent cases are not available.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please upload a PDF to extract a timeline.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
