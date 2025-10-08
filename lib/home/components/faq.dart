import 'package:flutter/material.dart';
import 'package:ross_ai_1/variables/faq_data.dart'; // replace with your actual package name

class FAQSection extends StatefulWidget {
  const FAQSection({super.key});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> {
  int? _openIndex; // store currently expanded index

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqData.length,
      itemBuilder: (context, index) {
        final isOpen = _openIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: Text(
                    faqData[index]['question']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? const Color(0xFF3B82F6).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isOpen ? Icons.remove_rounded : Icons.add_rounded,
                      size: 20,
                      color: isOpen
                          ? const Color(0xFF3B82F6)
                          : Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _openIndex = isOpen ? null : index;
                    });
                  },
                ),
                if (isOpen)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      faqData[index]['answer']!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
