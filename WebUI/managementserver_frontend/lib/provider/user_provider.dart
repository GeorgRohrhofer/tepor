import 'package:flutter/material.dart';
import '../models/user.dart'; // import your User model

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  String get username => _currentUser?.username ?? 'Guest';
  String get role => _currentUser?.role ?? 'User';

  void setUser(User user) {
    _currentUser = user;
    notifyListeners(); // notifies all listening widgets
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
