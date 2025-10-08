import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ross_ai_1/auth/provider/auth_provider.dart';
import 'package:ross_ai_1/utils/loading_animation.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();

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
                      Consumer<FirebaseAuthProvider>(
                        builder: (context, provider, child) {
                          final isDesktop =
                              MediaQuery.of(context).size.width > 768;
                          return GestureDetector(
                            onTap: () async {
                              showLegalLoader(context);
                              await Future.delayed(Duration(seconds: 4));
                              Navigator.pop(context); // dismiss loader
                              Navigator.pushNamed(context, '/profile');
                            },
                            child: CircleAvatar(
                              radius: isDesktop ? 48 : 43,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                provider.userProfile?["name"]
                                        .toString()
                                        .substring(0, 1) ??
                                    "",
                                style: TextStyle(
                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 2,
            onDestinationSelected: (int index) {
              if (index == 0) Navigator.pushNamed(context, '/profile');
              if (index == 1) Navigator.pushNamed(context, '/preferences');
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Preferences'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback),
                label: Text('Feedback'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Feedback",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: feedbackController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: "Share your feedback...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Feedback submitted")),
                      );
                    },
                    child: const Text("Submit Feedback"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
