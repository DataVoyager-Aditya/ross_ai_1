import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/timeline_extractor_service.dart';

class TimelineExtractorProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isExtracting = false;
  String? _errorMessage;
  List<TimelineEvent> _extractedEvents = [];
  String? _downloadUrl;
  String? _extractedText;

  bool get isLoading => _isLoading;
  bool get isExtracting => _isExtracting;
  String? get errorMessage => _errorMessage;
  List<TimelineEvent> get extractedEvents => _extractedEvents;
  String? get downloadUrl => _downloadUrl;
  String? get extractedText => _extractedText;

  // Upload PDF, extract text, and send to Gemini
  Future<void> processPdfAndExtractTimeline(dynamic file) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final caseId = DateTime.now().millisecondsSinceEpoch.toString();
      // Upload file to Firebase Storage
      final url = await TimelineExtractorService.uploadSelectedFileToStorage(
        file,
        user.uid,
        caseId,
      );
      _downloadUrl = url;
      // Extract text from PDF
      final text = await TimelineExtractorService.extractTextFromPdf(file);
      _extractedText = text;
      // Send to Gemini API
      final events = await TimelineExtractorService.extractTimelineFromText(
        text,
      );
      _extractedEvents = events;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to process PDF: $e';
      notifyListeners();
    }
  }

  Future<void> extractTextFromPdf(dynamic file) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _extractedText = await TimelineExtractorService.extractTextFromPdf(file);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to extract text: $e';
      notifyListeners();
    }
  }

  Future<void> extractTimelineFromText(String text) async {
    try {
      _isExtracting = true;
      _errorMessage = null;
      notifyListeners();
      final events = await TimelineExtractorService.extractTimelineFromText(
        text,
      );
      _extractedEvents = events;
      _isExtracting = false;
      notifyListeners();
    } catch (e) {
      _isExtracting = false;
      _errorMessage = 'Failed to extract timeline: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearExtractedEvents() {
    _extractedEvents.clear();
    _downloadUrl = null;
    _extractedText = null;
    notifyListeners();
  }
}
