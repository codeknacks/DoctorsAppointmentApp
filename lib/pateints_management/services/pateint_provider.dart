import 'package:flutter/material.dart';

class PateintProvider with ChangeNotifier {
  String? _userId;
  String? _deviceToken;

  String? get userId => _userId;
  String? get deviceToken => _deviceToken;

  void setUserDetails({required String userId, required String deviceToken}) {
    _userId = userId;
    _deviceToken = deviceToken;
    notifyListeners();
  }
}
