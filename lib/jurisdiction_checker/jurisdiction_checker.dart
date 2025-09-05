import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/loading_animation.dart';
import '../variables/extracted_jurisdiction.dart';
import '../variables/profile.dart';
import 'provider/jurisdiction_provider.dart';

class JurisdictionChecker extends StatefulWidget {
  const JurisdictionChecker({super.key});

  @override
  State<JurisdictionChecker> createState() => _JurisdictionCheckerState();
}

class _JurisdictionCheckerState extends State<JurisdictionChecker> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedCaseType;
  final List<String> _caseTypes = ['Civil', 'Criminal', 'Corporate', 'Family'];

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final provider = Provider.of<JurisdictionProvider>(
        context,
        listen: false,
      );
      await provider.pickFile(result.files.first);
    }
  }

  Future<void> _extractText(BuildContext context) async {
    final provider = Provider.of<JurisdictionProvider>(context, listen: false);
    if (provider.selectedFile != null) {
      await provider.extractTextFromPdf(provider.selectedFile);
    }
  }

  Future<void> _analyzeCase(BuildContext context) async {
    final provider = Provider.of<JurisdictionProvider>(context, listen: false);
    if (provider.extractedText != null && provider.extractedText!.isNotEmpty) {
      await provider.analyzeCase(provider.extractedText!);
    }
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
                        child: const Text(
                          "Dashboard",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
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
      body: Consumer<JurisdictionProvider>(
        builder: (context, provider, child) {
          if (provider == null) return SizedBox.shrink();
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Determine the appropriate court for your case",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
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
                                "Drag and drop or pick your PDF document",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Supported format: PDF",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : () => _pickFile(context),
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
                      if (provider.selectedFile != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(child: Text(provider.selectedFile.name)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _extractText(context),
                          child: const Text('Extract Text from PDF'),
                        ),
                      ],
                      if (provider.extractedText != null &&
                          provider.extractedText!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Extracted Text:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.extractedText!,
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _analyzeCase(context),
                          child: provider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Analyze Jurisdiction'),
                        ),
                      ],
                      const SizedBox(height: 30),
                      if (provider.errorText != null)
                        Text(
                          provider.errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (provider.isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (provider.suggestions.isNotEmpty) ...[
                        const Text(
                          'Jurisdiction Suggestions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...provider.suggestions.map(
                          (s) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(s.jurisdiction),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Court Type: ${s.courtType}'),
                                  const SizedBox(height: 4),
                                  Text('Reasoning: ${s.reasoning}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
