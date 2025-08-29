import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:archive/archive.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // Extract text from different file formats
  static Future<String> extractTextFromFile(File file) async {
    try {
      final extension = path.extension(file.path).toLowerCase();

      switch (extension) {
        case '.txt':
          return await _extractTextFromTxt(file);
        case '.pdf':
          return await _extractTextFromPdfBytes(await file.readAsBytes());
        case '.docx':
          return await _extractTextFromDocxBytes(await file.readAsBytes());
        default:
          throw Exception('Unsupported file format: $extension');
      }
    } catch (e) {
      throw Exception('Failed to extract text from file: $e');
    }
  }

  // Extract text from TXT file
  static Future<String> _extractTextFromTxt(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read TXT file: $e');
    }
  }

  // Extract text from PDF bytes
  static Future<String> _extractTextFromPdfBytes(Uint8List bytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  // Extract text from DOCX bytes
  static Future<String> _extractTextFromDocxBytes(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the document.xml file in the DOCX
      final documentXml = archive.findFile('word/document.xml');
      if (documentXml == null) {
        throw Exception('Could not find document.xml in DOCX file');
      }

      final xmlContent = utf8.decode(documentXml.content as List<int>);

      // Simple XML parsing to extract text
      // Remove XML tags and extract text content
      final text = xmlContent
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      return text;
    } catch (e) {
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }

  // Extract text from raw bytes (web PlatformFile)
  static Future<String> extractTextFromBytes(
    Uint8List bytes,
    String fileName,
  ) async {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.txt':
        return utf8.decode(bytes);
      case '.pdf':
        return _extractTextFromPdfBytes(bytes);
      case '.docx':
        return _extractTextFromDocxBytes(bytes);
      default:
        throw Exception('Unsupported file format: $extension');
    }
  }

  // Pick multiple files (web-compatible)
  static Future<List<dynamic>> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: true,
        withData: true, // This ensures we get bytes for web
      );

      if (result != null) {
        return result.files;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }

  // Generate unique case ID
  static String generateCaseId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
    return 'case_${timestamp}_$random';
  }

  // Extract timeline from text using Gemini directly
  static Future<Map<String, dynamic>> extractTimelineFromText(
    String text,
    String userId, {
    String? caseId,
  }) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text content cannot be empty');
      }
      if (_geminiApiKey.isEmpty) {
        throw Exception(
          'Missing GEMINI_API_KEY (use --dart-define=GEMINI_API_KEY=...)',
        );
      }

      final finalCaseId = caseId ?? generateCaseId();

      final prompt =
          'Extract chronological legal events from the given case text. Return ONLY valid JSON array of objects with keys: title, date (YYYY-MM-DD), description. Case text (truncate if needed):\n${text.substring(0, text.length > 12000 ? 12000 : text.length)}';

      final resp = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception('Gemini error: ${resp.body}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final generatedText =
          (data['candidates']?[0]?['content']?['parts']?[0]?['text']
              as String?) ??
          '';

      final jsonMatch = RegExp(r"\[[\s\S]*\]").firstMatch(generatedText);
      if (jsonMatch == null) {
        throw Exception('No valid JSON found in model response');
      }
      final eventsParsed = jsonDecode(jsonMatch.group(0)!);
      if (eventsParsed is! List) {
        throw Exception('Extracted content is not an array');
      }

      final sanitizedEvents = eventsParsed.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return {
          'title': (map['title'] ?? 'Untitled').toString(),
          'date': (map['date'] ?? 'Unknown').toString(),
          'description': (map['description'] ?? '').toString(),
        };
      }).toList();

      // Save to Firestore
      await saveCaseToFirestore(
        userId,
        finalCaseId,
        sanitizedEvents,
        sanitizedEvents.isNotEmpty
            ? sanitizedEvents.first['title']
            : 'Untitled',
      );

      return {
        'success': true,
        'caseId': finalCaseId,
        'events': sanitizedEvents,
        'message': 'ok',
      };
    } catch (e) {
      throw Exception('Timeline extraction failed: $e');
    }
  }

  // Process multiple files and extract timeline (web-compatible)
  static Future<Map<String, dynamic>> processFilesAndExtractTimeline(
    List<dynamic> files,
    String userId,
  ) async {
    try {
      if (files.isEmpty) {
        throw Exception('No files selected');
      }

      final caseId = generateCaseId();
      String mergedText = '';

      // Upload files and extract text locally
      for (final file in files) {
        try {
          // upload
          await uploadSelectedFileToStorage(file, userId, caseId);

          // extract text
          String fileName;
          if (file is File) {
            fileName = path.basename(file.path);
            final fileText = await extractTextFromFile(file);
            mergedText += '\n\n--- File: $fileName ---\n\n$fileText';
          } else {
            fileName = file.name as String;
            final bytes = file.bytes as Uint8List?;
            if (bytes == null) continue;
            // save to temp for using existing extractors
            // On web we cannot use dart:io File; skip local extraction for web
            // Instead, do lightweight extraction for txt; PDFs/DOCX delegated to server normally.
            final ext = path.extension(fileName).toLowerCase();
            if (ext == '.txt') {
              mergedText +=
                  '\n\n--- File: $fileName ---\n\n${utf8.decode(bytes)}';
            } else {
              // Fallback: skip client-side parsing for complex formats on web
              // and rely on Gemini to handle raw text absence.
            }
          }
        } catch (_) {
          // continue with other files
        }
      }

      if (mergedText.trim().isEmpty) {
        throw Exception('No text could be extracted from files');
      }

      return await extractTimelineFromText(mergedText, userId, caseId: caseId);
    } catch (e) {
      throw Exception('Failed to process files: $e');
    }
  }

  // Get recent cases from Firestore
  static Future<List<Map<String, dynamic>>> getRecentCases(
    String userId,
  ) async {
    return getRecentCasesFromFirestore(userId);
  }

  // Get specific case from Firestore
  static Future<Map<String, dynamic>> getCase(
    String userId,
    String caseId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cases')
          .doc(caseId)
          .get();
      if (!doc.exists) return {};
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Failed to get case: $e');
    }
  }

  // Delete case from Firestore
  static Future<bool> deleteCase(String userId, String caseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cases')
          .doc(caseId)
          .delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recentCases')
          .doc(caseId)
          .delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  // Save case to local Firestore (backup method)
  static Future<void> saveCaseToFirestore(
    String userId,
    String caseId,
    List<Map<String, dynamic>> events,
    String title,
  ) async {
    try {
      final caseData = {
        'caseId': caseId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'title': title,
        'events': events,
        'userId': userId,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cases')
          .doc(caseId)
          .set(caseData);

      // Save to recent cases
      final recentCaseData = {
        'caseId': caseId,
        'title': title,
        'uploadedAt': FieldValue.serverTimestamp(),
        'eventCount': events.length,
        'firstEventDate': events.isNotEmpty ? events.first['date'] : 'Unknown',
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recentCases')
          .doc(caseId)
          .set(recentCaseData);
    } catch (e) {
      throw Exception('Failed to save case to Firestore: $e');
    }
  }

  // Get recent cases from local Firestore (backup method)
  static Future<List<Map<String, dynamic>>> getRecentCasesFromFirestore(
    String userId,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recentCases')
          .orderBy('uploadedAt', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent cases from Firestore: $e');
    }
  }
}
