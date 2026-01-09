import 'package:flutter/material.dart';
import '../models/user.dart'; // import your User model

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  String get username => _currentUser?.username ?? 'NoNAME';
  String get role => _currentUser?.role ?? 'NoROLE';

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
