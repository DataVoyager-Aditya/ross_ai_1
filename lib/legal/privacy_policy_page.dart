import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  const SizedBox(width: 20),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFF3B82F6),
                        size: isDesktop ? 24 : 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48.0 : 24.0,
          vertical: isDesktop ? 48.0 : 32.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : double.infinity,
            ),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 48 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 60,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroduction(isDesktop),
                  const SizedBox(height: 32),
                  _buildSection("1. Information We Collect", [
                    "Personal Information: Name, email address, account details.",
                    "Uploaded Content: Documents, text, and images submitted for processing.",
                    "Usage Data: Searches, queries, interactions, and activity logs.",
                    "Cookies & Tracking Data: To enhance performance and user experience.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("2. How We Use Your Information", [
                    "To provide and improve ROSS AI services.",
                    "To personalize your experience.",
                    "To maintain security and prevent misuse.",
                    "To analyze usage trends for research and development.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("3. Data Storage and Security", [
                    "Uploaded files and personal data may be temporarily stored on secure servers.",
                    "We use reasonable measures to protect your data, but no system is 100% secure.",
                    "Users are responsible for keeping account credentials confidential.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("4. Data Sharing", [
                    "We do not sell or rent your personal data.",
                    "Data may be shared with service providers strictly for operational purposes (e.g., hosting, analytics).",
                    "We may disclose data if required by law or legal process.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("5. Cookies", [
                    "ROSS AI uses cookies to:",
                    "  • Remember user preferences",
                    "  • Improve functionality",
                    "  • Track performance and analytics",
                    "You may disable cookies in your browser, but some features may not work properly.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("6. User Rights", [
                    "You may request to access, update, or delete your personal data.",
                    "You may opt out of cookies or marketing communications.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("7. Third-Party Links", [
                    "ROSS AI may contain links to third-party sites. We are not responsible for their privacy practices.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildSection("8. Changes to Policy", [
                    "We may update this Privacy Policy from time to time.",
                    "Continued use of the platform implies acceptance of changes.",
                  ], isDesktop),
                  const SizedBox(height: 24),
                  _buildContactSection(isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Privacy Policy",
          style: TextStyle(
            fontSize: isDesktop ? 32 : 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "This Privacy Policy explains how ROSS AI collects, uses, and protects your information.",
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> points, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 22 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!point.startsWith("  "))
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 15,
                      color: const Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "9. Contact Us",
            style: TextStyle(
              fontSize: isDesktop ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "For questions about this Privacy Policy, contact us at:",
            style: TextStyle(
              fontSize: isDesktop ? 16 : 15,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 20,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Text(
                "rajthakuraditya63@gmail.com",
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 15,
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
