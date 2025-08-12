import 'dart:convert';
import 'package:http/http.dart' as http;

// Test the timeline extraction API
Future<void> testTimelineExtraction() async {
  const String baseUrl = 'https://us-central1-ross-ai-b6809.cloudfunctions.net';

  // Test case text
  const String testText = '''
  The case began on January 3, 2024, when a formal complaint was filed against the accused.
  The police conducted an investigation and arrested the accused on January 10, 2024.
  The first court hearing was held on January 20, 2024, in the district court.
  The court granted bail to the accused on January 25, 2024.
  The trial commenced on February 15, 2024.
  ''';

  try {
    print('Testing timeline extraction...');

    final response = await http.post(
      Uri.parse('$baseUrl/extractTimeline'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': testText, 'userId': 'test_user_123'}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n✅ Timeline extraction successful!');
      print('Case ID: ${data['caseId']}');
      print('Events extracted: ${data['events'].length}');

      for (int i = 0; i < data['events'].length; i++) {
        final event = data['events'][i];
        print('${i + 1}. ${event['title']} (${event['date']})');
        print('   ${event['description']}');
      }
    } else {
      print('\n❌ Timeline extraction failed');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Error testing timeline extraction: $e');
  }
}

// Test getting recent cases
Future<void> testGetRecentCases() async {
  const String baseUrl = 'https://us-central1-ross-ai-b6809.cloudfunctions.net';

  try {
    print('\nTesting get recent cases...');

    final response = await http.get(
      Uri.parse('$baseUrl/getRecentCases?userId=test_user_123'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n✅ Get recent cases successful!');
      print('Cases found: ${data['cases'].length}');

      for (int i = 0; i < data['cases'].length; i++) {
        final caseData = data['cases'][i];
        print(
          '${i + 1}. ${caseData['title']} (${caseData['eventCount']} events)',
        );
      }
    } else {
      print('\n❌ Get recent cases failed');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('\n❌ Error testing get recent cases: $e');
  }
}

// Main function to run tests
void main() async {
  print('🧪 Testing Timeline Extraction Backend\n');

  await testTimelineExtraction();
  await testGetRecentCases();

  print('\n🏁 Tests completed!');
}
