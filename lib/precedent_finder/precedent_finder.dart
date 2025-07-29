import 'package:flutter/material.dart';
import "package:ross_ai_1/precedent_finder/components/precedent_tile.dart";
import 'package:ross_ai_1/variables/profile.dart';
import "package:ross_ai_1/variables/precedents.dart"; 
import '../utils/loading_animation.dart';

class PrecedentFinder extends StatefulWidget {
  const PrecedentFinder({super.key});

  @override
  State<PrecedentFinder> createState() => _PrecedentFinderState();
}

class _PrecedentFinderState extends State<PrecedentFinder> {
  String? selectedJurisdiction;
  final List<String> jurisdictions = [
    'Supreme Court',
    'High Court',
    'District Court',
  ];
  final TextEditingController _textController = TextEditingController();

  bool _hasSearched = false;
  late Future<List<Map<String, String>>> _futurePrecedents;

  Future<List<Map<String, String>>> fetchPrecedents() async {
    await Future.delayed(const Duration(seconds: 1));
    return precedentsList;
  }

  void _onSearchPressed() {
    setState(() {
      _hasSearched = true;
      _futurePrecedents = fetchPrecedents();
    });
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
                        child: const Text("Dashboard", style: TextStyle(fontSize: 15))),
                      const SizedBox(width: 35),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/jurisdiction');
                        },
                        child: const Text(
                          "Jurisdiction Checker",
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 20,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.green[200],
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              "assets/images/background.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Let's dig into precedent case law 🔍",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _onSearchPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Search Precedents",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  DropdownButtonFormField<String>(
                    value: selectedJurisdiction,
                    items: jurisdictions.map((String court) {
                      return DropdownMenuItem<String>(
                        value: court,
                        child: Text(court),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedJurisdiction = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select Jurisdiction",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Add Optional Text...",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Upload Case Files",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Drag and drop or browse to upload your case files.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
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
                  const SizedBox(height: 40),
                  if (_hasSearched)
                    FutureBuilder<List<Map<String, String>>>(
                      future: _futurePrecedents,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching precedents.');
                        } else {
                          final precedents = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: precedents.length,
                            itemBuilder: (context, index) {
                              final precedent = precedents[index];
                              return PrecedentTile(
                                title: precedent['title'] ?? 'No Title',
                                summary:
                                    precedent['summary'] ?? 'No Summary',
                                bench: precedent['bench'] ?? 'Unknown Bench',
                                date: precedent['date'] ?? 'Unknown Date',
                              );
                            },
                          );
                        }
                      },
                    )
                  else
                    const Text("No precedents searched yet."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
