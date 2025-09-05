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
You are an expert legal AI assistant designed to perform preliminary jurisdictional analysis in India. Your purpose is to help legal professionals by identifying potential jurisdictions for a given case, not to provide definitive legal advice.

Given a set of case facts, you will:
1.  Analyze the facts against general principles of personal jurisdiction, subject-matter jurisdiction, and venue.
2.  Identify all plausible jurisdictions (State Courts, Federal Courts).
3.  For each potential jurisdiction, you must provide a clear and concise reasoning explaining why it might be a valid option, citing the relevant legal principles (e.g., "Defendant's residence," "Location of the tort," "Federal Question Jurisdiction," "Diversity Jurisdiction").
4.  Strictly format your entire output as a single JSON object. The root object should contain a key named "jurisdictionalAnalysis" which holds an array of potential jurisdiction objects.
5.  Each object in the array must contain three specific string keys: "jurisdiction", "courtType", and "reasoning".
6.  Do not include any text, explanations, or conversational filler outside of the main JSON object. Your response must begin with { and end with }.
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
