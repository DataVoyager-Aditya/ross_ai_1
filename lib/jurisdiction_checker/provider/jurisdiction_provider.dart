import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class JurisdictionSuggestion {
  final String jurisdiction;
  final String courtType;
  final String reasoning;

  JurisdictionSuggestion({
    required this.jurisdiction,
    required this.courtType,
    required this.reasoning,
  });

  factory JurisdictionSuggestion.fromJson(Map<String, dynamic> json) {
    return JurisdictionSuggestion(
      jurisdiction: json['jurisdiction'] ?? 'N/A',
      courtType: json['courtType'] ?? 'N/A',
      reasoning: json['reasoning'] ?? 'No reasoning provided.',
    );
  }
}

class GeminiApiService {
  // IMPORTANT: Replace with your actual API key
  final String _apiKey = "AIzaSyCSeefPgP0KdmB_yepBy91aHSZ36FgIs9g";
  final String _systemInstruction = """
You are an expert legal AI assistant specializing in preliminary jurisdictional analysis under Indian law. Your task is to help legal professionals quickly identify potential jurisdictions and prevent misfiling or unethical forum shopping.

When given a set of case facts, you must:

Analyze the facts using general principles of personal jurisdiction, subject-matter jurisdiction, and venue under Indian law.

Identify all plausible jurisdictions (e.g., District Courts, High Courts, Supreme Court if applicable).

For each potential jurisdiction, provide a clear and concise reasoning explaining why it may be valid, citing principles like "Defendant’s residence", "Place where cause of action arose", "Location of property in dispute", or "Special statutes / constitutional provisions".

Detect and present possible conflicts between multiple jurisdictions (if more than one court could reasonably hear the case).

Output must be strictly formatted as a single JSON object. The root object must contain a key "jurisdictionalAnalysis" which holds an array of objects.

Each object in the array must contain exactly three string keys:

"jurisdiction" → The name of the plausible jurisdiction (e.g., "Delhi District Court", "Bombay High Court").

"courtType" → The type of court (e.g., "District Court", "High Court", "Supreme Court").

"reasoning" → A concise explanation of why this jurisdiction may apply.
""";

  late final GenerativeModel _model;

  GeminiApiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(responseMimeType: "application/json"),
    );
  }

  Future<String?> getJurisdictionalAnalysis(String caseDetails) async {
    try {
      final prompt = Content.text(caseDetails);
      final response = await _model.generateContent([prompt]);
      return response.text;
    } catch (e) {
      // In a real app, you might want to use a more robust logging service
      print("Error fetching analysis: $e");
      rethrow; // Re-throw the exception to be handled by the provider
    }
  }
}

class JurisdictionProvider with ChangeNotifier {
  final GeminiApiService _apiService = GeminiApiService();

  // Private state
  List<JurisdictionSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorText;
  String? _extractedText;
  dynamic _selectedFile;

  // Public getters to access state from the UI
  List<JurisdictionSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;
  String? get extractedText => _extractedText;
  dynamic get selectedFile => _selectedFile;

  void clearError() {
    _errorText = null;
    notifyListeners();
  }

  void clearExtractedText() {
    _extractedText = null;
    _selectedFile = null;
    notifyListeners();
  }

  Future<void> pickFile(dynamic file) async {
    _selectedFile = file;
    notifyListeners();
  }

  Future<void> extractTextFromPdf(dynamic file) async {
    try {
      _isLoading = true;
      _errorText = null;
      notifyListeners();
      Uint8List bytes;
      if (file is! Uint8List && file.bytes == null) {
        bytes = await file.readAsBytes();
      } else {
        bytes = file.bytes as Uint8List;
      }
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      _extractedText = PdfTextExtractor(document).extractText();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorText = 'Failed to extract text: $e';
      notifyListeners();
    }
  }

  // Business logic method
  Future<void> analyzeCase(String caseDetails) async {
    if (caseDetails.isEmpty) return;
    try {
      _isLoading = true;
      _errorText = null;
      notifyListeners();
      final response = await _apiService.getJurisdictionalAnalysis(caseDetails);
      if (response == null) {
        _errorText = "No response from API.";
        _isLoading = false;
        notifyListeners();
        return;
      }
      final Map<String, dynamic> json = jsonDecode(response);
      final List<dynamic> analysis = json['jurisdictionalAnalysis'] ?? [];
      _suggestions = analysis
          .map((item) => JurisdictionSuggestion.fromJson(item))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorText = 'Failed to analyze case: $e';
      notifyListeners();
    }
  }
}
