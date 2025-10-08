import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ross_ai_1/timeline_extractor/services/timeline_extractor_service.dart';
import 'provider/timeline_extractor_provider.dart';
import '../timeline_extractor/utils/get_icon.dart';

class TimelineExtractor extends StatefulWidget {
  const TimelineExtractor({super.key});

  @override
  State<TimelineExtractor> createState() => _TimelineExtractorState();
}

class _TimelineExtractorState extends State<TimelineExtractor> {
  dynamic _selectedFile;

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _extractText(BuildContext context) async {
    final provider = Provider.of<TimelineExtractorProvider>(
      context,
      listen: false,
    );
    if (_selectedFile != null) {
      await provider.extractTextFromPdf(_selectedFile);
    }
  }

  Future<void> _extractTimeline(BuildContext context) async {
    final provider = Provider.of<TimelineExtractorProvider>(
      context,
      listen: false,
    );
    if (provider.extractedText != null && provider.extractedText!.isNotEmpty) {
      await provider.extractTimelineFromText(provider.extractedText!);
    }
  }

  Widget _buildFileUploadSection() {
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1D4ED8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Upload',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Select a PDF document to extract its timeline and key events using advanced AI analysis.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            Consumer<TimelineExtractorProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      _selectedFile == null
                          ? Icons.add_circle_outline
                          : Icons.refresh_rounded,
                      size: 20,
                    ),
                    label: Text(
                      _selectedFile == null
                          ? 'Select PDF Document'
                          : 'Change Document',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    onPressed: provider.isLoading
                        ? null
                        : () => _pickFile(context),
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: _selectedFile == null
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                Set<MaterialState> states,
                              ) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.white.withOpacity(0.1);
                                }
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.white.withOpacity(0.2);
                                }
                                return null;
                              }),
                        ),
                  ),
                );
              },
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.1),
                      const Color(0xFF059669).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFF059669),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile is File
                                ? _selectedFile.path.split('/').last
                                : _selectedFile.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF Document • Ready to process',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Consumer<TimelineExtractorProvider>(
      builder: (context, provider, child) {
        if (_selectedFile == null) return const SizedBox.shrink();

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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFF7C3AED),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Processing',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Step 2 of 2',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Extract Text Step
                _buildProcessStep(
                  stepNumber: 1,
                  title: 'Extract Text',
                  description: 'Extract text content from your PDF document',
                  isCompleted:
                      provider.extractedText != null &&
                      provider.extractedText!.isNotEmpty,
                  isLoading: provider.isLoading,
                  onPressed: provider.isLoading
                      ? null
                      : () => _extractText(context),
                ),

                if (provider.extractedText != null &&
                    provider.extractedText!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildProcessStep(
                    stepNumber: 2,
                    title: 'Generate Timeline',
                    description: 'AI will analyze and extract timeline events',
                    isCompleted: provider.extractedEvents.isNotEmpty,
                    isLoading: provider.isExtracting,
                    onPressed: provider.isExtracting
                        ? null
                        : () => _extractTimeline(context),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF10B981).withOpacity(0.05)
            : isLoading
            ? const Color(0xFFF59E0B).withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withOpacity(0.2)
              : isLoading
              ? const Color(0xFFF59E0B).withOpacity(0.2)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                      ],
                    )
                  : isLoading
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFF59E0B),
                        const Color(0xFFD97706),
                      ],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
              boxShadow: [
                if (isCompleted || isLoading)
                  BoxShadow(
                    color:
                        (isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B))
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isCompleted
                        ? const Color(0xFF059669)
                        : const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (!isCompleted && !isLoading)
            ElevatedButton(
              onPressed: onPressed,
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.white.withOpacity(0.1);
                      }
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white.withOpacity(0.2);
                      }
                      return null;
                    }),
                  ),
              child: const Text(
                'Start',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtractedTextSection() {
    return Consumer<TimelineExtractorProvider>(
      builder: (context, provider, child) {
        if (provider.extractedText == null || provider.extractedText!.isEmpty) {
          return const SizedBox.shrink();
        }

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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF06B6D4),
                            const Color(0xFF0891B2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.text_snippet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Extracted Text',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      provider.extractedText!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF475569),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeline(List<TimelineEvent> events) {
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeline Events',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chronological analysis of key events',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.1),
                        const Color(0xFF1D4ED8).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${events.length} events',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final icon = getEventIcon(event.title);
                final isLast = index == events.length - 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF1D4ED8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 22),
                          ),
                          if (!isLast)
                            Container(
                              height: 48,
                              width: 3,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(0.3),
                                    Colors.grey.shade300,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                      const Color(0xFF1D4ED8).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  event.date.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                event.whatHappened,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: const Color(0xFF475569),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFDC2626).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Document Timeline Extraction',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade100],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40.0 : 20.0,
          vertical: isDesktop ? 32.0 : 24.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : double.infinity,
            ),
            child: Consumer<TimelineExtractorProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFileUploadSection(),
                    const SizedBox(height: 32),
                    _buildProcessingSection(),
                    const SizedBox(height: 32),
                    if (provider.errorMessage != null)
                      _buildErrorMessage(provider.errorMessage!),
                    if (provider.errorMessage != null)
                      const SizedBox(height: 32),
                    _buildExtractedTextSection(),
                    if (provider.extractedText != null &&
                        provider.extractedText!.isNotEmpty)
                      const SizedBox(height: 32),
                    if (provider.extractedEvents.isNotEmpty)
                      Column(
                        children: [
                          _buildTimeline(provider.extractedEvents),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save_rounded, size: 18),
                                label: const Text(
                                  'Save Timeline',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ).copyWith(
                                      overlayColor:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >((Set<MaterialState> states) {
                                            if (states.contains(
                                              MaterialState.hovered,
                                            )) {
                                              return Colors.white.withOpacity(
                                                0.1,
                                              );
                                            }
                                            if (states.contains(
                                              MaterialState.pressed,
                                            )) {
                                              return Colors.white.withOpacity(
                                                0.2,
                                              );
                                            }
                                            return null;
                                          }),
                                    ),
                                onPressed: () async {
                                  final titleController =
                                      TextEditingController();
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Save Timeline'),
                                      content: TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                          labelText: 'Case Title',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            titleController.text,
                                          ),
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result != null &&
                                      result.trim().isNotEmpty) {
                                    await provider.saveTimelineToFirestore(
                                      result.trim(),
                                    );
                                    await provider.fetchUserCases();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Timeline saved!'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
