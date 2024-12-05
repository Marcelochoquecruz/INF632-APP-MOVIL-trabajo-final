import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserType { patient, doctor, admin }

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  UserType? _userType;

  User? get user => _user;
  UserType? get userType => _userType;

  Future<bool> signIn(String email, String password, UserType type) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _userType = type;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userType = null;
    notifyListeners();
  }
}
