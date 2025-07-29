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
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      faqData[index]['question']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    trailing: AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                    ),
                    onTap: () {
                      setState(() {
                        _openIndex = isOpen ? null : index;
                      });
                    },
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faqData[index]['answer']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
