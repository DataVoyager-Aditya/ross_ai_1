import 'package:flutter/material.dart';
import "package:ross_ai_1/variables/icon_map.dart";

IconData getEventIcon(String eventTitle) {
  for (var keyword in eventIconMap.keys) {
    if (eventTitle.toLowerCase().contains(keyword)) {
      return eventIconMap[keyword]!;
    }
  }
  return eventIconMap['default']!;
}
