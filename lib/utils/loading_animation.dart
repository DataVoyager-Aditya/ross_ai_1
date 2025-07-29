import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showLegalLoader(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Lottie.asset("assets/animations/law_loader.json"),
      ),
    ),
  );
}