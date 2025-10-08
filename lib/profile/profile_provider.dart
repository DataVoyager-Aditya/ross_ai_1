import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic> profile = {};

  void setProfile(Map<String, dynamic> profile) {
    this.profile = profile;
    notifyListeners();
  }

  void getProfile() {
    this.profile = profile;
    notifyListeners();
  }
}
