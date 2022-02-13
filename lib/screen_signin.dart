import 'package:flutter/material.dart';
import 'firebase_authentication_widget.dart';
import 'main.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signin / Signout'),
      ),
      body: SigninBody(key: key),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
    );
  }
}

class SigninBody extends StatelessWidget {
  const SigninBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
            width: 200,
            height: 200,
            child: Image(image: AssetImage('assets/silhouette.png'))),
        Text(
          "Local Pavoni",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        Text("Organizing Espresso Meet-ups",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: FirebaseAuthenticationWidget(key: key)),
      ],
    );
  }
}
