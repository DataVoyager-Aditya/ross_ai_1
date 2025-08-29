import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ross_ai_1/timeline_extractor/components/extracted_events_design.dart';
import '../variables/profile.dart';
import '../timeline_extractor/utils/get_icon.dart';
import '../utils/loading_animation.dart';
import 'provider/timeline_extractor_provider.dart';

class TimelineExtractor extends StatefulWidget {
  const TimelineExtractor({super.key});

  @override
  State<TimelineExtractor> createState() => _TimelineExtractorState();
}

class _TimelineExtractorState extends State<TimelineExtractor> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load recent cases when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimelineExtractorProvider>().loadRecentCases();
    });
  }

  Widget _buildTimeline(List<Map<String, dynamic>> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final icon = getEventIcon(event['title']);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(icon, color: Colors.blue),
                  ),
                  if (index < events.length - 1)
                    Container(
                      height: 50,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              ExtractedEvents(event: event),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Handle export logic
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Exported Successfully!')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.download),
          label: Text("Export"),
        ),
      ),
    );
  }

  IconData _getFileIcon(dynamic file) {
    String fileName;
    if (file is String) {
      fileName = file;
    } else if (file is File) {
      fileName = file.path;
    } else {
      fileName = file.name;
    }

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      showLegalLoader(context);
                      await Future.delayed(Duration(seconds: 4));
                      Navigator.pop(context); // dismiss loader
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Image.asset(
                      "assets/images/logo1.png",
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/home');
                        },
                        child: Text(
                          "Dashboard",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/precedents');
                        },
                        child: Text(
                          "Precedent Finder",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/jurisdiction');
                        },
                        child: Text(
                          "Jurisdiction Checker",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            userProfile["profilePhoto"].toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 35.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Document Timeline Extraction",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  Consumer<TimelineExtractorProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Drag and drop or paste your document here",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Supported formats: PDF, DOCX, TXT",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () => provider.pickFiles(),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text("Browse Files"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Show selected files
                          if (provider.selectedFiles.isNotEmpty) ...[
                            SizedBox(height: 20),
                            Text(
                              "Selected Files (${provider.selectedFiles.length})",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ...provider.selectedFiles.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final file = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getFileIcon(file),
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file is File
                                                ? file.path.split('/').last
                                                : file.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${provider.getFileExtension(file)} • ${provider.getFileSize(file)}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          provider.removeFile(index),
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ${provider.getTotalFilesSize()}',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      provider.clearSelectedFiles(),
                                  child: Text('Clear All'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Paste your document content here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Consumer<TimelineExtractorProvider>(
                    builder: (context, provider, child) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: provider.isExtracting
                              ? null
                              : () async {
                                  if (provider.selectedFiles.isNotEmpty) {
                                    await provider
                                        .processFilesAndExtractTimeline();
                                  } else if (_textController.text
                                      .trim()
                                      .isNotEmpty) {
                                    await provider.extractTimelineFromText(
                                      _textController.text,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please select files or enter text',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: provider.isExtracting
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text("Extracting..."),
                                  ],
                                )
                              : Text("Extract Timeline"),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  Consumer<TimelineExtractorProvider>(
                    builder: (context, provider, child) {
                      // Show error message if any
                      if (provider.errorMessage != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage!),
                              backgroundColor: Colors.red,
                            ),
                          );
                          provider.clearError();
                        });
                      }

                      if (provider.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (provider.extractedEvents.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Extracted Timeline",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildTimeline(provider.extractedEvents),
                            _buildExportButton(),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Text(
                              "Extracted Timeline",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("No timeline extracted yet."),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
