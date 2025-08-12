import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/timeline_extractor_service.dart';

class TimelineExtractorProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isExtracting = false;
  List<Map<String, dynamic>> _extractedEvents = [];
  List<Map<String, dynamic>> _recentCases = [];
  String? _currentCaseId;
  String? _errorMessage;
  List<File> _selectedFiles = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isExtracting => _isExtracting;
  List<Map<String, dynamic>> get extractedEvents => _extractedEvents;
  List<Map<String, dynamic>> get recentCases => _recentCases;
  String? get currentCaseId => _currentCaseId;
  String? get errorMessage => _errorMessage;
  List<File> get selectedFiles => _selectedFiles;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Pick files
  Future<void> pickFiles() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final files = await TimelineExtractorService.pickMultipleFiles();
      _selectedFiles = files;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to pick files: $e';
      notifyListeners();
    }
  }

  // Remove file from selection
  void removeFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      _selectedFiles.removeAt(index);
      notifyListeners();
    }
  }

  // Clear selected files
  void clearSelectedFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  // Extract timeline from text
  Future<void> extractTimelineFromText(String text) async {
    try {
      _isExtracting = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final result = await TimelineExtractorService.extractTimelineFromText(
        text,
        user.uid,
      );

      if (result['success']) {
        _extractedEvents = List<Map<String, dynamic>>.from(result['events']);
        _currentCaseId = result['caseId'];

        // Refresh recent cases
        await loadRecentCases();
      } else {
        throw Exception(result['message'] ?? 'Extraction failed');
      }

      _isExtracting = false;
      notifyListeners();
    } catch (e) {
      _isExtracting = false;
      _errorMessage = 'Failed to extract timeline: $e';
      notifyListeners();
    }
  }

  // Process files and extract timeline
  Future<void> processFilesAndExtractTimeline() async {
    try {
      if (_selectedFiles.isEmpty) {
        throw Exception('No files selected');
      }

      _isExtracting = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final result =
          await TimelineExtractorService.processFilesAndExtractTimeline(
            _selectedFiles,
            user.uid,
          );

      if (result['success']) {
        _extractedEvents = List<Map<String, dynamic>>.from(result['events']);
        _currentCaseId = result['caseId'];

        // Clear selected files after successful processing
        _selectedFiles.clear();

        // Refresh recent cases
        await loadRecentCases();
      } else {
        throw Exception(result['message'] ?? 'Extraction failed');
      }

      _isExtracting = false;
      notifyListeners();
    } catch (e) {
      _isExtracting = false;
      _errorMessage = 'Failed to process files: $e';
      notifyListeners();
    }
  }

  // Load recent cases
  Future<void> loadRecentCases() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final cases = await TimelineExtractorService.getRecentCases(user.uid);
      _recentCases = cases;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load recent cases: $e';
      notifyListeners();
    }
  }

  // Load specific case
  Future<void> loadCase(String caseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final caseData = await TimelineExtractorService.getCase(user.uid, caseId);

      if (caseData.isNotEmpty) {
        _extractedEvents = List<Map<String, dynamic>>.from(
          caseData['events'] ?? [],
        );
        _currentCaseId = caseId;
      } else {
        throw Exception('Case not found');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load case: $e';
      notifyListeners();
    }
  }

  // Delete case
  Future<void> deleteCase(String caseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final success = await TimelineExtractorService.deleteCase(
        user.uid,
        caseId,
      );

      if (success) {
        // Remove from recent cases
        _recentCases.removeWhere((caseData) => caseData['caseId'] == caseId);

        // If this was the current case, clear it
        if (_currentCaseId == caseId) {
          _extractedEvents.clear();
          _currentCaseId = null;
        }
      } else {
        throw Exception('Failed to delete case');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete case: $e';
      notifyListeners();
    }
  }

  // Clear extracted events
  void clearExtractedEvents() {
    _extractedEvents.clear();
    _currentCaseId = null;
    notifyListeners();
  }

  // Save case to Firestore (backup method)
  Future<void> saveCaseToFirestore(String title) async {
    try {
      if (_extractedEvents.isEmpty) {
        throw Exception('No events to save');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final caseId =
          _currentCaseId ?? TimelineExtractorService.generateCaseId();

      await TimelineExtractorService.saveCaseToFirestore(
        user.uid,
        caseId,
        _extractedEvents,
        title,
      );

      _currentCaseId = caseId;

      // Refresh recent cases
      await loadRecentCases();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save case: $e';
      notifyListeners();
    }
  }

  // Get file size in readable format
  String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      }
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  // Get file extension
  String getFileExtension(File file) {
    final fileName = file.path.split('/').last;
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'Unknown';
  }

  // Validate file format
  bool isValidFileFormat(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['pdf', 'docx', 'txt'].contains(extension);
  }

  // Get total files size
  String getTotalFilesSize() {
    if (_selectedFiles.isEmpty) return '0 B';

    int totalBytes = 0;
    for (final file in _selectedFiles) {
      totalBytes += file.lengthSync();
    }

    if (totalBytes < 1024) {
      return '$totalBytes B';
    }
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
