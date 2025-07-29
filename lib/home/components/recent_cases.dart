import 'package:flutter/material.dart';

class RecentCases extends StatelessWidget {
  final String caseName;
  final String caseDate;

  const RecentCases({
    required this.caseName,
    required this.caseDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 5, right: 70, bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                caseName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Date: $caseDate",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
          ],
        ),
      ),
    );
  }
}

class EmptyCase extends StatelessWidget {
  const EmptyCase({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      height: 100,
      width: double.infinity,
      child: Center(child: Text("No Recent Activity", style: TextStyle(fontSize: 15, color: Colors.grey),)),
    );
  }
}
