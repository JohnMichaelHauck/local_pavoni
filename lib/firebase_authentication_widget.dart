import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_cnp.dart';

class FirebaseAuthenticationWidget extends StatefulWidget {
  const FirebaseAuthenticationWidget({Key? key}) : super(key: key);

  @override
  State<FirebaseAuthenticationWidget> createState() =>
      _FirebaseAuthenticationWidgetState();
}

class _FirebaseAuthenticationWidgetState
    extends State<FirebaseAuthenticationWidget> {
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
