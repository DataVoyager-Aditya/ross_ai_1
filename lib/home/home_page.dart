import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ross_ai_1/auth/provider/auth_provider.dart';
import 'components/features_grid.dart';
import 'components/recent_cases.dart';
import 'components/faq.dart';
import '../utils/loading_animation.dart';
import '../timeline_extractor/provider/timeline_extractor_provider.dart';
import '../timeline_extractor/timeline_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Future.microtask(() {
      Provider.of<FirebaseAuthProvider>(
        context,
        listen: false,
      ).getCurrentUserProfile();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 90 : 80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 20.0,
                vertical: isDesktop ? 24.0 : 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      showLegalLoader(context);
                      await Future.delayed(Duration(seconds: 2));
                      Navigator.pop(context); // dismiss loader
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        "assets/images/logo1.png",
                        height: isDesktop ? 50 : 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Consumer<FirebaseAuthProvider>(
                    builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: isDesktop ? 28 : 24,
                            backgroundColor: Colors.white,
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
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🧠 Main Body
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40.0 : 24.0,
                vertical: isDesktop ? 48.0 : 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.1),
                          const Color(0xFF1D4ED8).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${FirebaseAuth.instance.currentUser?.displayName} 👋",
                          style: TextStyle(
                            fontSize: isDesktop ? 36 : 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Let's simplify your legal research with AI-powered tools",
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 48 : 32),

                  // Features Section Header
                  Text(
                    "AI-Powered Legal Tools",
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Streamline your legal workflow with intelligent automation",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/timeline');
                        },
                        child: FeaturesGrid(
                          widgetName: "Legal Timeline Extractor",
                          widgetDescription:
                              "Extract legal events & visualize your case flow",
                          widgetImage:
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuCe-Yhn4iitGYrXsxxkv3V0BfXurdRyWvBWiPZU6ce5VNzR0L2gWcfZfyOKFSWbUWDtCsJd2K31p99RhNKlmi2IoNPcHzIPjHp82Y5ukMCHl4iL7EQ6NK3tPr7VUxjSftDejfmBALdEPc6WI1ZpevZ7ygmP6jgjMpAZgd-KvIpVLWDewDhrymsnu-vah7LuqTSiUSY_EN2qLgQpBkcwZ2MbRnzLMn70iTYMTi6UkP43djLNSDNFszpCqTl4N3H3tPvPIahIReywn08",
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/jurisdiction');
                        },

                        child: FeaturesGrid(
                          widgetName: "Jurisdiction Conflict Checker",
                          widgetDescription:
                              "Detect court mismatch with smart AI",
                          widgetImage:
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuDDfEVleAV0lVXxWED74ZBEuT5TtLROnEfNl4LrPSrCC5JGMU2PWWz_7J8H-vIndkJ5yPq_gUuUQURq64mfxsCs-ZGMbRCOCMPWzMSmEiPJzQc4peUuKkDkpGmFEHkwZNaAZxb_bgogKPoQTYUD1YeIOPbBz9nh1K3O7oA2X5r3n3th_rLEx4UYwG5JoU8SZMPByMleo65Il7N31c4ZPKMsWJk5ORxhi2fn8aGCcwknHDUNjarnBYI2k31j_Cf8NWQ-1h0D-drsK0o",
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () async {
                      //     showLegalLoader(context);
                      //     await Future.delayed(Duration(seconds: 2));
                      //     Navigator.pop(context); // dismiss loader
                      //     Navigator.pushNamed(context, '/precedents');
                      //   },
                      //   child: FeaturesGrid(
                      //     widgetName: "Precedent Finder",
                      //     widgetDescription:
                      //         "Find relevant case laws instantly",
                      //     widgetImage:
                      //         "https://lh3.googleusercontent.com/aida-public/AB6AXuCnK9rkEsVXDXTbzaE9qMnUCEXqd3y4vRFen0WFYL2wzh2nqOFoIwVIPfwMfACPcvGv799_h6mtsxhgQOnh386ur-YFwwP4h6rqjki9N-EQ-7wP-JdePjTKH-pcNNeX57ptvvTgQ0S1cxTgqLDlRgaE9JkTgySO_mgZ0L2gjs4-N3KvLGRMfWeye9LCwL7PCXBXr48HT1uiIlos0uH_wEj-Z8-XFtHY22R3EWRkJ2b5veN9NSkm4C2TWIMSF-X5hLXFw5pg1d6iqbA",
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 64 : 48),

                  // Recent Cases Section Header
                  Text(
                    "Your Recent Cases",
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Continue working on your legal timeline extractions",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 24),

                  // Recent Cases from Firestore
                  Consumer<TimelineExtractorProvider>(
                    builder: (context, provider, child) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: provider.fetchUserCases(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: \\${snapshot.error}');
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final cases = snapshot.data!;
                            return Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: cases
                                  .map(
                                    (caseItem) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TimelineDetailPage(
                                              caseId: caseItem['caseId'],
                                              caseTitle:
                                                  caseItem['title'] ??
                                                  'Untitled',
                                            ),
                                          ),
                                        );
                                      },
                                      child: RecentCases(
                                        caseName:
                                            caseItem['title'] ?? 'Untitled',
                                        caseDate: caseItem['uploadedAt'],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          } else {
                            return const EmptyCase();
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: isDesktop ? 64 : 48),

                  // FAQ Section Header
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Get answers to common questions about our AI legal tools",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 24),
                  FAQSection(),
                  SizedBox(height: isDesktop ? 48 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
