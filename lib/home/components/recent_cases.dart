import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentCases extends StatelessWidget {
  final String caseName;
  final Timestamp caseDate;

  const RecentCases({
    required this.caseName,
    required this.caseDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.2),
                        const Color(0xFF059669).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: const Color(0xFF059669),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Complete',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              caseName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(caseDate.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      height: 120,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 24,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "No Recent Activity",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your completed cases will appear here",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
