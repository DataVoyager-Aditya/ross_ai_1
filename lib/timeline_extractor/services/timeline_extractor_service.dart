import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:archive/archive.dart';

class TimelineExtractorService {
  // Vercel backend URL - replace with your deployed URL
  static const String _baseUrl = 'https://your-vercel-app.vercel.app/api';

  // File upload to Firebase Storage
  static Future<String> uploadFileToStorage(
    File file,
    String userId,
    String caseId,
  ) async {
    try {
      final fileName = path.basename(file.path);
      final storageRef = FirebaseStorage.instance.ref().child(
        'timeline_uploads/$userId/$caseId/$fileName',
      );

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
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
          return await _extractTextFromPdf(file);
        case '.docx':
          return await _extractTextFromDocx(file);
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

  // Extract text from PDF file
  static Future<String> _extractTextFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  // Extract text from DOCX file
  static Future<String> _extractTextFromDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();
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

  // Pick multiple files
  static Future<List<File>> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: true,
      );

      if (result != null) {
        return result.paths.map((path) => File(path!)).toList();
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

  // Extract timeline from text using backend API
  static Future<Map<String, dynamic>> extractTimelineFromText(
    String text,
    String userId, {
    String? caseId,
  }) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text content cannot be empty');
      }

      final finalCaseId = caseId ?? generateCaseId();

      final response = await http.post(
        Uri.parse('$_baseUrl/extract-timeline'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'userId': userId,
          'caseId': finalCaseId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'caseId': data['caseId'],
          'events': data['events'],
          'message': data['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to extract timeline');
      }
    } catch (e) {
      throw Exception('Timeline extraction failed: $e');
    }
  }

  // Process multiple files and extract timeline
  static Future<Map<String, dynamic>> processFilesAndExtractTimeline(
    List<File> files,
    String userId,
  ) async {
    try {
      if (files.isEmpty) {
        throw Exception('No files selected');
      }

      final caseId = generateCaseId();
      String mergedText = '';

      // Upload files and extract text
      for (final file in files) {
        // Upload file to storage
        await uploadFileToStorage(file, userId, caseId);

        // Extract text from file
        final fileText = await extractTextFromFile(file);
        mergedText += '\n\n--- File: ${path.basename(file.path)} ---\n\n';
        mergedText += fileText;
      }

      // Extract timeline from merged text
      return await extractTimelineFromText(mergedText, userId, caseId: caseId);
    } catch (e) {
      throw Exception('Failed to process files: $e');
    }
  }

  // Get recent cases from backend
  static Future<List<Map<String, dynamic>>> getRecentCases(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get-recent-cases?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['cases'] ?? []);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get recent cases');
      }
    } catch (e) {
      throw Exception('Failed to get recent cases: $e');
    }
  }

  // Get specific case from backend
  static Future<Map<String, dynamic>> getCase(
    String userId,
    String caseId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get-case?userId=$userId&caseId=$caseId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['case'] ?? {};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to get case');
      }
    } catch (e) {
      throw Exception('Failed to get case: $e');
    }
  }

  // Delete case from backend
  static Future<bool> deleteCase(String userId, String caseId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete-case'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'caseId': caseId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete case');
      }
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
