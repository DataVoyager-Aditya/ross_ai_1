import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/timeline_extractor_provider.dart';
import 'services/timeline_extractor_service.dart';
import 'utils/get_icon.dart';

class TimelineDetailPage extends StatelessWidget {
  final String caseId;
  final String caseTitle;
  const TimelineDetailPage({
    required this.caseId,
    required this.caseTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(caseTitle)),
      body: FutureBuilder(
        future: Provider.of<TimelineExtractorProvider>(
          context,
          listen: false,
        ).fetchTimelineForCase(caseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            final events = snapshot.data as List;
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final icon = getEventIcon(event.title);
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Icon(icon, color: Colors.blue),
                    title: Text(event.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${event.date ?? "-"}'),
                        Text(event.whatHappened),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No timeline events found.'));
          }
        },
      ),
    );
  }
}
