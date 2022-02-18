import 'dart:async';
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

  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _censusSubscription;
  List<CensusCountry> censusCountries = [];

  FacebookAuthProvider facebookProvider = FacebookAuthProvider();

  FirebaseChangeNotifier() {
    init();
  }

  Future<void> init() async {
    facebookProvider.addScope('email');
    facebookProvider.setCustomParameters({
      'display': 'popup',
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;
      _userId = user?.uid ?? "";

      if (user == null) {
        _authenticationState = AuthenticationStateEnum.needEmail;
      } else if (user.emailVerified == false) {
        _authenticationState = AuthenticationStateEnum.needEmailVerification;
      } else {
        _authenticationState = AuthenticationStateEnum.signedIn;
      }

      notifyListeners();

      if (user != null) {
        _userSubscription ??= FirebaseFirestore.instance
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
            notifyListeners();
          }
        });
        _censusSubscription ??= FirebaseFirestore.instance
            .collection('census')
            .orderBy(FieldPath.documentId)
            .snapshots()
            .listen((census) {
          censusCountries.clear();
          for (final country in census.docs) {
            var censusStates = <CensusState>[];
            int censusCountry = 0;
            var states = country.data().entries.toList();
            states.sort((a, b) => a.key.compareTo(b.key));
            for (var state in states) {
              censusStates.add(CensusState(state.key, state.value));
              censusCountry += state.value as int;
            }
            censusCountries
                .add(CensusCountry(country.id, censusCountry, censusStates));
          }
          notifyListeners();
        });
      } else {
        _userSubscription?.cancel();
        _censusSubscription?.cancel();
        _userSubscription = null;
        _censusSubscription = null;
      }
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

  Future<void> signInFacebook() async {
    try {
      _message = null;
      notifyListeners();
      await FirebaseAuth.instance.signInWithPopup(facebookProvider);
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
      //_authenticationState = AuthenticationStateEnum.needEmail;
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
      //_authenticationState = AuthenticationStateEnum.needEmail;
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .delete();
      _message = "Your data has been deleted.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }

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

  Future<void> setCountryState(String country, String state) async {
    if (isSignedIn) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(<String, dynamic>{
        'country': country,
        'state': state,
      }, SetOptions(merge: true));
    }
  }

  String _country = "";
  String get country => _country;

  String _state = "";
  String get state => _state;
}

class CensusCountry {
  final String name;
  final int census;
  final List<CensusState> states;
  CensusCountry(this.name, this.census, this.states);
}

class CensusState {
  final String name;
  final int census;
  CensusState(this.name, this.census);
}
