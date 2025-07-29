import 'package:flutter/material.dart';
import 'package:ross_ai_1/timeline_extractor/components/extracted_events_design.dart';
import '../variables/profile.dart';
import '../timeline_extractor/utils/get_icon.dart';
import '../variables/extracted_events.dart';
import '../utils/loading_animation.dart';


class TimelineExtractor extends StatefulWidget {
  const TimelineExtractor({super.key});

  @override
  State<TimelineExtractor> createState() => _TimelineExtractorState();
}

class _TimelineExtractorState extends State<TimelineExtractor> {
  final TextEditingController _textController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _extractedFuture;

  Future<List<Map<String, dynamic>>> _simulateExtraction() async {
    await Future.delayed(Duration(seconds: 2)); // simulate delay
    return extractedEvents;
  }

  @override
  void initState() {
    super.initState();
    _extractedFuture = Future.value([]); // initially empty
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
                        child: Text("Dashboard", style: TextStyle(fontSize: 15))),
                      SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/precedents');
                        },
                        child: Text("Precedent Finder", style: TextStyle(fontSize: 15))),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Supported formats: PDF, DOCX, TXT",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade400),
                              elevation: 0,
                            ),
                            child: Text("Browse Files"),
                          ),
                        ],
                      ),
                    ),
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _extractedFuture = _simulateExtraction();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text("Extract Timeline"),
                    ),
                  ),

                  SizedBox(height: 30),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _extractedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
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
                            _buildTimeline(snapshot.data!),
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
