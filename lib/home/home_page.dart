import 'package:flutter/material.dart';
import '../variables/profile.dart';
import '../variables/cases.dart';
import 'utils/encryption.dart';
import "utils/hover_tool_tip.dart";
import 'components/features_grid.dart';
import 'components/recent_cases.dart';
import 'components/faq.dart';
import '../utils/loading_animation.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});
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
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: GestureDetector(
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
            constraints: BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 35.0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // 👈 aligns heading with cards
                children: [
                  Text(
                    "Welcome, Aditya 👋 Let’s simplify your legal research",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
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
                          await Future.delayed(Duration(seconds: 4));
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
                      GestureDetector(
                        onTap: () async {
                          showLegalLoader(context);
                          await Future.delayed(Duration(seconds: 4));
                          Navigator.pop(context); // dismiss loader
                          Navigator.pushNamed(context, '/precedents');
                        },
                        child: FeaturesGrid(
                          widgetName: "Precedent Finder",
                          widgetDescription: "Find relevant case laws instantly",
                          widgetImage:
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuCnK9rkEsVXDXTbzaE9qMnUCEXqd3y4vRFen0WFYL2wzh2nqOFoIwVIPfwMfACPcvGv799_h6mtsxhgQOnh386ur-YFwwP4h6rqjki9N-EQ-7wP-JdePjTKH-pcNNeX57ptvvTgQ0S1cxTgqLDlRgaE9JkTgySO_mgZ0L2gjs4-N3KvLGRMfWeye9LCwL7PCXBXr48HT1uiIlos0uH_wEj-Z8-XFtHY22R3EWRkJ2b5veN9NSkm4C2TWIMSF-X5hLXFw5pg1d6iqbA",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  Text(
                    "Your Recent Cases",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  caseData.isNotEmpty
                      ? SizedBox(
                          height: 80,

                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: caseData.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Row(
                                  children: [
                                    HoverToolTip(
                                      message:
                                          "🔒 Your case is encrypted.\nOnly you can view its name.",
                                      child: RecentCases(
                                        caseName: EncryptionHelper.decryptText(
                                          caseData[index]["name"].toString(),
                                        ),
                                        caseDate: caseData[index]["date"]
                                            .toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : EmptyCase(),
                  SizedBox(height: 60),
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  FAQSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
