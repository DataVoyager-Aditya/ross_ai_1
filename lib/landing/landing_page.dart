// Helper for responsive layout
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Responsive(
          mobile: _buildMobileAppBar(),
          tablet: _buildMobileAppBar(),
          desktop: _buildDesktopAppBar(),
        ),
      ),
      drawer: Responsive.isMobile(context) || Responsive.isTablet(context)
          ? _buildMobileDrawer()
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildSectionWithKey(_featuresKey, _buildFeaturesSection()),
            _buildSectionWithKey(_howItWorksKey, _buildHowItWorksSection()),
            _buildSectionWithKey(_testimonialsKey, _buildTestimonialsSection()),
            _buildSectionWithKey(_faqKey, _buildFaqSection()),
            _buildCtaSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithKey(GlobalKey key, Widget child) {
    return Container(key: key, child: child);
  }

  AppBar _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Row(
        children: [
          Image.asset(
            "assets/images/logo1.png",
            height: 32,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: _buildLogo(textColor: Colors.white),
          ),
          _buildDrawerItem('Features', () => _scrollToSection(_featuresKey)),
          _buildDrawerItem(
            'How It Works',
            () => _scrollToSection(_howItWorksKey),
          ),
          _buildDrawerItem(
            'Testimonials',
            () => _scrollToSection(_testimonialsKey),
          ),
          _buildDrawerItem('FAQ', () => _scrollToSection(_faqKey)),
          const Divider(),
          ListTile(
            title: const Text('Log In'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  AppBar _buildDesktopAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      toolbarHeight: 64,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Row(
          children: [
            Image.asset(
              "assets/images/logo1.png",
              height: 32,
              fit: BoxFit.contain,
            ),

            const Spacer(),
            _buildNavLinks(),
            const SizedBox(width: 32),
            _buildAuthButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo({Color textColor = Colors.black87}) {
    return Row(
      children: [
        Image.asset("assets/images/logo1.png", height: 36, fit: BoxFit.contain),
      ],
    );
  }

  Widget _buildNavLinks() {
    return Row(
      children: [
        _navButton('Features', () => _scrollToSection(_featuresKey)),
        _navButton('How It Works', () => _scrollToSection(_howItWorksKey)),
        _navButton('Testimonials', () => _scrollToSection(_testimonialsKey)),
        _navButton('FAQ', () => _scrollToSection(_faqKey)),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text('Log In', style: TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  Widget _navButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://plus.unsplash.com/premium_photo-1661769577787-9811af17f98d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bGF3fGVufDB8fDB8fHww',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'AI-Powered Timelines from Your Case Files',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 40 : 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ross AI intelligently analyzes your legal documents to automatically extract key events and build interactive case timelines. Save hundreds of hours and gain critical insights instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 18 : 20,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Get Started for Free'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final isMobile = Responsive.isMobile(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Revolutionize Your Case Preparation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'From document analysis to jurisdiction checks, our AI tools are designed to give you a competitive edge.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 64),
          Column(
            children: const [
              FeatureCard(
                icon: FontAwesomeIcons.fileInvoice,
                title: 'Automated Timeline Extraction',
                description:
                    'Upload your case files, and our AI will instantly identify and organize all crucial dates and events into a clear, interactive timeline.',
              ),
              SizedBox(height: 24),
              FeatureCard(
                icon: FontAwesomeIcons.mapMarkedAlt,
                title: 'Jurisdiction Conflict Checker',
                description:
                    'Our AI will analyze your case to identify potential jurisdiction conflicts, saving you from costly and time-consuming errors.',
                isComingSoon: false,
              ),
              SizedBox(height: 24),
              FeatureCard(
                icon: FontAwesomeIcons.gavel,
                title: 'AI Precedent Finder',
                description:
                    'Leverage AI to search thousands of legal documents and find relevant precedents that strengthen your case arguments.',
                isComingSoon: true,
              ),
              SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          const Text(
            'Get Started in 3 Simple Steps',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our intuitive platform makes it easy to get up and running in minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 64),
          Responsive(
            mobile: Column(
              children: const [
                HowItWorksStep(
                  number: '1',
                  title: 'Upload Your Case File',
                  description:
                      'Securely drag and drop or upload your documents in various formats (PDF, DOCX, etc.).',
                ),
                SizedBox(height: 40),
                HowItWorksStep(
                  number: '2',
                  title: 'AI Analyzes & Extracts',
                  description:
                      'Our powerful AI processes the text, identifies key events, and constructs a detailed timeline.',
                ),
                SizedBox(height: 40),
                HowItWorksStep(
                  number: '3',
                  title: 'Review & Export',
                  description:
                      'Collaborate, edit, and export your timeline in your preferred format to integrate into your workflow.',
                ),
              ],
            ),
            tablet: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: HowItWorksStep(
                    number: '1',
                    title: 'Upload Your Case File',
                    description:
                        'Securely drag and drop or upload your documents in various formats (PDF, DOCX, etc.).',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: HowItWorksStep(
                    number: '2',
                    title: 'AI Analyzes & Extracts',
                    description:
                        'Our powerful AI processes the text, identifies key events, and constructs a detailed timeline.',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: HowItWorksStep(
                    number: '3',
                    title: 'Review & Export',
                    description:
                        'Collaborate, edit, and export your timeline in your preferred format to integrate into your workflow.',
                  ),
                ),
              ],
            ),
            desktop: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: HowItWorksStep(
                    number: '1',
                    title: 'Upload Your Case File',
                    description:
                        'Securely drag and drop or upload your documents in various formats (PDF, DOCX, etc.).',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: HowItWorksStep(
                    number: '2',
                    title: 'AI Analyzes & Extracts',
                    description:
                        'Our powerful AI processes the text, identifies key events, and constructs a detailed timeline.',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: HowItWorksStep(
                    number: '3',
                    title: 'Review & Export',
                    description:
                        'Collaborate, edit, and export your timeline in your preferred format to integrate into your workflow.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Trusted by Legal Professionals',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 64),
          Responsive(
            mobile: Column(
              children: const [
                TestimonialCard(
                  quote:
                      '"LexiChron has become an indispensable tool in my practice. The timeline extraction is incredibly accurate and saves me countless hours. It\'s a game-changer for case management."',
                  name: 'Jane Smith',
                  title: 'Partner, Smith & Associates',
                  initials: 'JS',
                ),
                SizedBox(height: 24),
                TestimonialCard(
                  quote:
                      '"The accuracy of the AI is astounding. I uploaded a 500-page case file and had a working timeline in minutes. I can\'t imagine going back to the manual process."',
                  name: 'Michael Davis',
                  title: 'Solo Practitioner',
                  initials: 'MD',
                ),
                SizedBox(height: 24),
                TestimonialCard(
                  quote:
                      '"A must-have for any modern law firm. Not only does it save time, but it helps uncover connections and details in a case that might have been missed. Highly recommended."',
                  name: 'Emily White',
                  title: 'Senior Counsel, Tech Law Group',
                  initials: 'EW',
                ),
              ],
            ),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"LexiChron has become an indispensable tool in my practice. The timeline extraction is incredibly accurate and saves me countless hours. It\'s a game-changer for case management."',
                    name: 'Jane Smith',
                    title: 'Partner, Smith & Associates',
                    initials: 'JS',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"The accuracy of the AI is astounding. I uploaded a 500-page case file and had a working timeline in minutes. I can\'t imagine going back to the manual process."',
                    name: 'Michael Davis',
                    title: 'Solo Practitioner',
                    initials: 'MD',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"A must-have for any modern law firm. Not only does it save time, but it helps uncover connections and details in a case that might have been missed. Highly recommended."',
                    name: 'Emily White',
                    title: 'Senior Counsel, Tech Law Group',
                    initials: 'EW',
                  ),
                ),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"LexiChron has become an indispensable tool in my practice. The timeline extraction is incredibly accurate and saves me countless hours. It\'s a game-changer for case management."',
                    name: 'Jane Smith',
                    title: 'Partner, Smith & Associates',
                    initials: 'JS',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"The accuracy of the AI is astounding. I uploaded a 500-page case file and had a working timeline in minutes. I can\'t imagine going back to the manual process."',
                    name: 'Michael Davis',
                    title: 'Solo Practitioner',
                    initials: 'MD',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: TestimonialCard(
                    quote:
                        '"A must-have for any modern law firm. Not only does it save time, but it helps uncover connections and details in a case that might have been missed. Highly recommended."',
                    name: 'Emily White',
                    title: 'Senior Counsel, Tech Law Group',
                    initials: 'EW',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: const [
              Text(
                'Frequently Asked Questions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 64),
              FaqItem(
                question: 'Is my data secure?',
                answer:
                    'Absolutely. We use end-to-end encryption and adhere to the highest standards of data security and confidentiality. Your case files are for your eyes only.',
              ),
              SizedBox(height: 16),
              FaqItem(
                question: 'What file formats do you support?',
                answer:
                    'We support a wide range of formats including PDF, DOCX, TXT, and more. Our AI is designed to handle both scanned documents and digital text with high accuracy.',
              ),
              SizedBox(height: 16),
              FaqItem(
                question: 'Can I edit the generated timeline?',
                answer:
                    'Yes. The generated timeline is fully interactive and editable. You can add, remove, or modify events as needed to ensure it perfectly reflects your case narrative.',
              ),
              SizedBox(height: 16),
              FaqItem(
                question: 'Do you offer a free trial?',
                answer:
                    'Yes, we offer a free trial that allows you to test the core features of LexiChron. Sign up to get started and see the power of our AI for yourself.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      color: Colors.indigo,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Ready to Transform Your Legal Workflow?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join the growing number of legal professionals who are leveraging AI to work smarter, not harder. Sign up today and get started in minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.indigo[100]),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign Up Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Responsive(
            mobile: Column(
              children: [
                _buildFooterLogo(),
                const SizedBox(height: 32),
                _buildFooterLinks(),
                const SizedBox(height: 32),
                _buildFooterLegal(),
                const SizedBox(height: 32),
                _buildFooterSocial(),
              ],
            ),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: _buildFooterLogo()),
                Expanded(flex: 1, child: _buildFooterLinks()),
                Expanded(flex: 1, child: _buildFooterLegal()),
                Expanded(flex: 1, child: _buildFooterSocial()),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: _buildFooterLogo()),
                Expanded(flex: 1, child: _buildFooterLinks()),
                Expanded(flex: 1, child: _buildFooterLegal()),
                Expanded(flex: 1, child: _buildFooterSocial()),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            '© 2024 LexiChron. All Rights Reserved.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.scaleBalanced, color: Colors.indigo[300]),
            const SizedBox(width: 8),
            const Text(
              'LexiChron',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'AI-powered legal tools for the modern professional.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Features', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('How It Works', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('Pricing', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('FAQ', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFooterLegal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Terms of Service', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('Privacy Policy', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFooterSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect With Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(FontAwesomeIcons.twitter, color: Colors.grey),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.linkedinIn, color: Colors.grey),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.facebookF, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}

// ---- WIDGETS ----

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isComingSoon;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.indigo),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isComingSoon)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const HowItWorksStep({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.indigo,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String title;
  final String initials;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.name,
    required this.title,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
