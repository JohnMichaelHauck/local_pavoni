import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

enum AuthenticationStateEnum {
  needEmail,
  needLoginPassword,
  needRegistrationPassword,
  needEmailVerification,
  signedIn,
}

StreamSubscription? _listener;

class FirebaseChangeNotifier extends ChangeNotifier {
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
        if (_listener != null) {
          _listener?.cancel();
          _listener = null;
        }
      } else if (user.emailVerified == false) {
        _authenticationState = AuthenticationStateEnum.needEmailVerification;
        if (_listener != null) {
          _listener?.cancel();
          _listener = null;
        }
      } else {
        _authenticationState = AuthenticationStateEnum.signedIn;
        _listener = FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .snapshots()
            .listen((event) {
          log("heard from firestore");
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
      }
      notifyListeners();
    });
  }

//request.auth != null && request.auth.uid == userId;

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

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({Key? key}) : super(key: key);

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext bc) {
    return Consumer<FirebaseChangeNotifier>(
        builder: (context, authenticationChangeNotifier, child) {
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (authenticationChangeNotifier.authenticationState ==
                AuthenticationStateEnum.needEmail) ...[
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'Enter your email',
                    labelText: 'email',
                  ),
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (value) => authenticationChangeNotifier
                      .checkEmail(_emailController.text),
                ),
              ),
            ],
            if (authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needRegistrationPassword ||
                authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needLoginPassword) ...[
              SizedBox(
                width: 400,
                child: TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.password),
                    hintText:
                        (authenticationChangeNotifier.authenticationState ==
                                AuthenticationStateEnum.needLoginPassword)
                            ? 'Enter your password'
                            : "Create your password",
                    labelText: 'password',
                  ),
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (value) {
                    if (authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.needRegistrationPassword) {
                      authenticationChangeNotifier
                          .register(_passwordController.text);
                    } else {
                      authenticationChangeNotifier
                          .signIn(_passwordController.text);
                    }
                  },
                ),
              ),
            ],
            if (authenticationChangeNotifier.message != null) ...[
              Container(height: 8),
              Text(authenticationChangeNotifier.message.toString()),
            ],
            Container(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needEmail) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier
                            .checkEmail(_emailController.text);
                      }
                    },
                    child: const Text("Continue Login / Registration"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needLoginPassword) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier
                            .signIn(_passwordController.text);
                      }
                    },
                    child: const Text("Login"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier.resetPassword();
                      }
                    },
                    child: const Text("Send Me Password Reset Email"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needRegistrationPassword) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier
                            .register(_passwordController.text);
                      }
                    },
                    child: const Text("Register My New Account"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                    AuthenticationStateEnum.needEmailVerification) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier.veryifyEmail();
                      }
                    },
                    child: const Text("Send Me Verification Email"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.needLoginPassword ||
                    authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.needRegistrationPassword) ...[
                  OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier.startOver();
                      }
                    },
                    child: const Text("Cancel"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.signedIn ||
                    authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.needEmailVerification) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier.signOut();
                      }
                    },
                    child: const Text("Signout"),
                  ),
                ],
                if (authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.signedIn ||
                    authenticationChangeNotifier.authenticationState ==
                        AuthenticationStateEnum.needEmailVerification) ...[
                  OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authenticationChangeNotifier.deleteUser();
                      }
                    },
                    child: const Text("Delete My Account"),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }
}
