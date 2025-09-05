import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String? date;
  final String? startDate;
  final String? endDate;
  final String datePrecision;
  final String title;
  final String whatHappened;

  TimelineEvent({
    required this.date,
    required this.startDate,
    required this.endDate,
    required this.datePrecision,
    required this.title,
    required this.whatHappened,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
    date: j['date'],
    startDate: j['start_date'],
    endDate: j['end_date'],
    datePrecision: j['date_precision'] ?? 'day',
    title: j['title'] ?? '',
    whatHappened: j['what_happened'] ?? '',
  );
}

class TimelineExtractorService {
  // Gemini API
  static const String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  // NOTE: You asked to set API key directly here. Replace with your key.
  static const String _geminiApiKey = 'AIzaSyCSeefPgP0KdmB_yepBy91aHSZ36FgIs9g';

  // File upload to Firebase Storage (supports File and PlatformFile with bytes)
  static Future<String> uploadSelectedFileToStorage(
    dynamic file,
    String userId,
    String caseId,
  ) async {
    try {
      late final String fileName;
      late final Reference storageRef;
      storageRef = FirebaseStorage.instance.ref().child(
        'timeline_uploads/$userId/$caseId',
      );

      if (file is File) {
        fileName = path.basename(file.path);
        final ref = storageRef.child(fileName);
        final snapshot = await ref.putFile(file);
        return await snapshot.ref.getDownloadURL();
      } else {
        // Assume PlatformFile-like shape with name and bytes
        fileName = file.name as String;
        final bytes = file.bytes as Uint8List?;
        if (bytes == null) throw Exception('No bytes found for $fileName');
        final ref = storageRef.child(fileName);
        final snapshot = await ref.putData(bytes);
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Extract text from PDF using Syncfusion
  static Future<String> extractTextFromPdf(dynamic file) async {
    try {
      Uint8List bytes;
      if (file is File) {
        bytes = await file.readAsBytes();
      } else {
        bytes = file.bytes as Uint8List;
      }
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      return PdfTextExtractor(document).extractText();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  // Send extracted text to Gemini API for timeline extraction
  static Future<List<TimelineEvent>> extractTimelineFromText(
    String text,
  ) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text content cannot be empty');
      }
      if (_geminiApiKey.isEmpty) {
        throw Exception('Missing GEMINI_API_KEY');
      }

      Map<String, dynamic> timelineSchema = {
        'type': 'object',
        'properties': {
          'events': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'date': {'type': 'string', 'nullable': true},
                'start_date': {'type': 'string', 'nullable': true},
                'end_date': {'type': 'string', 'nullable': true},
                'date_precision': {
                  'type': 'string',
                  'enum': ['day', 'month', 'year', 'range'],
                },
                'title': {'type': 'string'},
                'what_happened': {'type': 'string'},
              },
              'required': ['title', 'what_happened', 'date_precision'],
            },
          },
        },
        'required': ['events'],
      };

      const String kSystemInstruction = r'''
You are a case-file timeline extractor.

TASK
- From the provided case text, extract only entries that mention a concrete date (or a date range).
- For each date, return what happened on that date (short title and one-line detail).
- Output strictly valid JSON matching the required schema. No extra text.

RULES
1) Use ONLY dates explicitly present in the text (or clear relative dates resolvable with provided reference_date/timezone). No guesses.
2) Normalize dates to ISO 8601:
   - Single day → "date": "YYYY-MM-DD"
   - Month-only → "date": "YYYY-MM-01", "date_precision": "month"
   - Year-only → "date": "YYYY-01-01", "date_precision": "year"
   - Ranges → use "start_date" and "end_date" (both ISO), set "date_precision": "range"
3) Keep "title" ≤ 80 chars; "what_happened" ≤ 240 chars; be factual and concise.
4) If multiple events share the same date, include separate items.
5) If nothing is extractable, return {"events": []}.

OUTPUT JSON SCHEMA (exact keys)
{
  "events": [
    {
      "date": "YYYY-MM-DD|null",
      "start_date": "YYYY-MM-DD|null",
      "end_date": "YYYY-MM-DD|null",
      "date_precision": "day|month|year|range",
      "title": "string",
      "what_happened": "string"
    }
  ]
}
''';
      final prompt = '''
          Extract chronological legal events from the given case text. 
          Case text (truncate if needed):\n${text.substring(0, text.length > 12000 ? 12000 : text.length)}''';

      final payload = {
        // system instruction
        'systemInstruction': {
          'parts': [
            {'text': kSystemInstruction},
          ],
        },
        // user message
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        // force JSON + schema
        'generationConfig': {
          'response_mime_type': 'application/json',
          'response_schema': timelineSchema,
        },
      };
      final resp = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (resp.statusCode != 200) {
        throw Exception('Gemini error: ${resp.statusCode} ${resp.body}');
      }

      final Map<String, dynamic> data = jsonDecode(resp.body);

      // Most responses put the JSON string in candidates[0].content.parts[0].text
      String jsonText = '';
      try {
        jsonText =
            (data['candidates'][0]['content']['parts'][0]['text'] as String?) ??
            '';
      } catch (_) {
        // fallback: try promptFeedback/errors
        jsonText = '';
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(jsonText) as Map<String, dynamic>;
      } catch (_) {
        // final fallback: try to extract first JSON block
        final match = RegExp(r'(\{[\s\S]*\}|\[[\s\S]*\])').firstMatch(jsonText);
        if (match != null) {
          parsed = jsonDecode(match.group(0)!);
        } else {
          parsed = {'events': []};
        }
      }

      final events = (parsed['events'] as List<dynamic>? ?? [])
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList();

      return events;
    } catch (e) {
      throw Exception('Timeline extraction failed: $e');
    }
  }

  static Future<void> saveCaseToFirestore(
    String userId,
    String caseId,
    Map<String, dynamic> caseData,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cases')
        .doc(caseId)
        .set(caseData);
  }

  static Future<List<Map<String, dynamic>>> getUserCases(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cases')
        .orderBy('uploadedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<TimelineEvent>> getTimelineForCase(
    String userId,
    String caseId,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cases')
        .doc(caseId)
        .get();
    if (!doc.exists) return [];
    final data = doc.data();
    final events = (data?['events'] as List<dynamic>? ?? [])
        .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return events;
  }
}
