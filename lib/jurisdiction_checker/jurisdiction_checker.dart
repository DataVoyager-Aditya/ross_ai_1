import 'package:flutter/material.dart';
import '../variables/profile.dart';
import '../variables/extracted_jurisdiction.dart';
import '../utils/loading_animation.dart';

class JurisdictionChecker extends StatefulWidget {
  const JurisdictionChecker({super.key});

  @override
  State<JurisdictionChecker> createState() => _JurisdictionCheckerState();
}

class _JurisdictionCheckerState extends State<JurisdictionChecker> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedCaseType;
  final List<String> _caseTypes = ['Civil', 'Criminal', 'Corporate', 'Family'];
  late Future<List<String>> _extractedFuture;

  Future<List<String>> _simulateExtraction() async {
    await Future.delayed(Duration(seconds: 2)); // simulate delay
    return extractedJurisdiction;
  }

  @override
  void initState() {
    super.initState();
    _extractedFuture = Future.value([]); // initially empty
  }

  Widget _checkJurisdiction(List<String> jurisdictions) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: jurisdictions.map((jurisdiction) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          jurisdiction,
          style: TextStyle(fontSize: 16),
        ),
      );
    }).toList(),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
                    onTap: () {
                  Navigator.pushNamed(context, '/home');

                    },
                    child: Container(
                      child: Image.asset(
                        "assets/images/logo1.png",
                        height: 80,
                        fit: BoxFit.contain,
                      ),
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
                        child: const Text("Dashboard", style: TextStyle(fontSize: 15))),
                      const SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/precedents');
                        },
                        child: const Text(
                          "Precedent Finder",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/timeline');
                        },
                        child: const Text(
                          "Timeline Extractor",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 35),
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
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 35.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jurisdiction Check",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Determine the appropriate court for your case",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Browse Files Container
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
                          const Text(
                            "Drag and drop or paste your document here",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Supported formats: PDF, DOCX, TXT",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              // Implement file picker here
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade400),
                              elevation: 0,
                            ),
                            child: const Text("Browse Files"),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TextField
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Paste case summary here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dropdown for Case Type
                  DropdownButtonFormField<String>(
                    value: _selectedCaseType,
                    items: _caseTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: "Select Case Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedCaseType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // Check Jurisdiction Button
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
                      child: Text("Check Jurisdiction"),
                    ),
                  ),
                  

                  SizedBox(height: 30),

                  FutureBuilder<List<String>>(
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
                              "Reasoning",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            _checkJurisdiction(snapshot.data!),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reasoning",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("No cases extracted yet."),
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
