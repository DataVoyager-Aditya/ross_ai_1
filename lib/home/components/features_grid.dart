import 'package:flutter/material.dart';

class FeaturesGrid extends StatelessWidget {
  final String widgetName;
  final String widgetDescription;
  final String widgetImage;

  const FeaturesGrid({
    super.key,
    required this.widgetName,
    required this.widgetDescription,
    required this.widgetImage,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final cardWidth = isDesktop ? 350.0 : 280.0;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: isDesktop ? 200 : 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF1D4ED8).withOpacity(0.05),
                  ],
                ),
              ),
              child: Image.network(
                widgetImage,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widgetName,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widgetDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.1),
                        const Color(0xFF1D4ED8).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: const Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI Powered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
