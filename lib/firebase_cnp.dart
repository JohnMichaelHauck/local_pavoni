import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

enum AuthenticationStateEnum {
  needEmail,
  needLoginPassword,
  needRegistrationPassword,
  needEmailVerification,
  signedIn,
}

class FirebaseChangeNotifier extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  String _userId = "";

  String _email = "";
  String get email => _email;

  String? _message;
  String? get message => _message;

  AuthenticationStateEnum _authenticationState =
      AuthenticationStateEnum.needEmail;
  AuthenticationStateEnum get authenticationState => _authenticationState;

  bool get isSignedIn =>
      _authenticationState == AuthenticationStateEnum.signedIn;

  StreamSubscription? _usersListener;

  FirebaseChangeNotifier() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;
      _userId = user?.uid ?? "";

      if (user == null) {
        _authenticationState = AuthenticationStateEnum.needEmail;
        if (_usersListener != null) {
          _usersListener?.cancel();
          _usersListener = null;
        }
      } else if (user.emailVerified == false) {
        _authenticationState = AuthenticationStateEnum.needEmailVerification;
        if (_usersListener != null) {
          _usersListener?.cancel();
          _usersListener = null;
        }
      } else {
        _authenticationState = AuthenticationStateEnum.signedIn;
        _usersListener = FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .snapshots()
            .listen((event) {
          var data = event.data();
          if (data != null) {
            if (data.containsKey("country")) {
              _country = data["country"];
            }
            if (data.containsKey("state")) {
              _state = data["state"];
            }
            log("state changed to " + _state);
            notifyListeners();
          }
        });
      }
      notifyListeners();
    });
  }

  Future<void> checkEmail(
    String email,
  ) async {
    try {
      _email = email;
      _message = null;
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      _authenticationState = methods.contains('password')
          ? AuthenticationStateEnum.needLoginPassword
          : AuthenticationStateEnum.needRegistrationPassword;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  Future<void> signIn(
    String password,
  ) async {
    try {
      _message = null;
      notifyListeners();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: password);
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  Future<void> register(
    String password,
  ) async {
    try {
      _message = null;
      notifyListeners();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: password);
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  Future<void> veryifyEmail() async {
    try {
      await _user?.sendEmailVerification();
      _authenticationState = AuthenticationStateEnum.needEmail;
      _message = "Check your email to verify your account.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      _authenticationState = AuthenticationStateEnum.needEmail;
      _message = "Check your email to reset your password.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  void startOver() {
    _authenticationState = AuthenticationStateEnum.needEmail;
    _message = null;
    notifyListeners();
  }

  void signOut() {
    try {
      FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteUser() async {
    try {
      await _user?.delete();
      _authenticationState = AuthenticationStateEnum.needEmail;
      _message = "Your account has been deleted.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  String _country = "";
  String get country => _country;
  set country(String country) {
    if (isSignedIn) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(<String, dynamic>{
        'country': country,
      }, SetOptions(merge: true));
    }
  }

  String _state = "";
  String get state => _state;
  set state(String state) {
    if (isSignedIn) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(<String, dynamic>{
        'state': state,
      }, SetOptions(merge: true));
    }
  }
}
