import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

enum AuthenticationStateEnum {
  checkEmail,
  getLoginPassword,
  getRegistrationPassword,
  getEmailVerification,
  allowSignOut,
}

class AuthenticationChangeNotifier extends ChangeNotifier {
  AuthenticationChangeNotifier() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;
      if (user == null) {
        _authenticationState = AuthenticationStateEnum.checkEmail;
      } else if (user.emailVerified == false) {
        _authenticationState = AuthenticationStateEnum.getEmailVerification;
      } else {
        _authenticationState = AuthenticationStateEnum.allowSignOut;
      }
      notifyListeners();
    });
  }

  User? _user;
  User? get user => _user;

  String _email = "";
  String get email => _email;

  String? _message;
  String? get message => _message;

  AuthenticationStateEnum _authenticationState =
      AuthenticationStateEnum.checkEmail;
  AuthenticationStateEnum get authenticationState => _authenticationState;

  Future<void> checkEmail(
    String email,
  ) async {
    try {
      _email = email;
      _message = "";
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      _authenticationState = methods.contains('password')
          ? AuthenticationStateEnum.getLoginPassword
          : AuthenticationStateEnum.getRegistrationPassword;
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
      _authenticationState = AuthenticationStateEnum.checkEmail;
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
      _authenticationState = AuthenticationStateEnum.checkEmail;
      _message = "Check your email to reset your password.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
    }
  }

  void startOver() {
    _authenticationState = AuthenticationStateEnum.checkEmail;
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
      _authenticationState = AuthenticationStateEnum.checkEmail;
      _message = "Your account has been deleted.";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _message = e.message;
      notifyListeners();
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
  Widget build(BuildContext bc) {
    return Consumer<AuthenticationChangeNotifier>(
        builder: (context, value, child) {
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (value.authenticationState ==
                AuthenticationStateEnum.checkEmail) ...[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter your email',
                  labelText: 'email',
                ),
              ),
            ],
            if (value.authenticationState ==
                    AuthenticationStateEnum.getRegistrationPassword ||
                value.authenticationState ==
                    AuthenticationStateEnum.getLoginPassword) ...[
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.password),
                  hintText: (value.authenticationState ==
                          AuthenticationStateEnum.getLoginPassword)
                      ? 'Enter your password'
                      : "Create your password",
                  labelText: 'password',
                ),
              ),
            ],
            if (value.message != null) ...[
              Container(height: 8),
              Text(value.message.toString()),
            ],
            if (value.authenticationState ==
                AuthenticationStateEnum.checkEmail) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.checkEmail(_emailController.text);
                  }
                },
                child: const Text("Continue Login / Registration"),
              ),
            ],
            if (value.authenticationState ==
                AuthenticationStateEnum.getLoginPassword) ...[
              Column(
                children: [
                  Container(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        value.signIn(_passwordController.text);
                      }
                    },
                    child: const Text("Login"),
                  ),
                  Container(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        value.resetPassword();
                      }
                    },
                    child: const Text("Send Me Password Reset Email"),
                  ),
                ],
              ),
            ],
            if (value.authenticationState ==
                AuthenticationStateEnum.getRegistrationPassword) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.register(_passwordController.text);
                  }
                },
                child: const Text("Register My New Account"),
              ),
            ],
            if (value.authenticationState ==
                AuthenticationStateEnum.getEmailVerification) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.veryifyEmail();
                  }
                },
                child: const Text("Send Me Verification Email"),
              ),
            ],
            if (value.authenticationState ==
                    AuthenticationStateEnum.getLoginPassword ||
                value.authenticationState ==
                    AuthenticationStateEnum.getRegistrationPassword) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.startOver();
                  }
                },
                child: const Text("Cancel"),
              ),
            ],
            if (value.authenticationState ==
                    AuthenticationStateEnum.allowSignOut ||
                value.authenticationState ==
                    AuthenticationStateEnum.getEmailVerification) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.signOut();
                  }
                },
                child: const Text("Signout"),
              ),
            ],
            if (value.authenticationState ==
                    AuthenticationStateEnum.allowSignOut ||
                value.authenticationState ==
                    AuthenticationStateEnum.getEmailVerification) ...[
              Container(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    value.deleteUser();
                  }
                },
                child: const Text("Delete My Account"),
              ),
            ],
          ],
        ),
      );
    });
  }
}
