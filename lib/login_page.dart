import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_project/register_page.dart';
import 'package:demo_project/home_page.dart';
import 'package:provider/provider.dart';
import 'package:demo_project/theme_mode_provider.dart';
import 'package:demo_project/localization_service.dart'; // Import LocalizationService

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _errorMessage = '';

  void onChange() {
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    emailController.addListener(onChange);
    passwordController.addListener(onChange);

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final errorMessage = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        _errorMessage,
        style: TextStyle(fontSize: 14.0, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );

    final email = TextFormField(
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email.';
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,
      decoration: InputDecoration(
        hintText: LocalizationService.instance.getString('email_hint'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        FocusScope.of(context).unfocus();
        _submit();
      },
      decoration: InputDecoration(
        hintText: LocalizationService.instance.getString('password_hint'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.lightBlueAccent,
        ),
        onPressed: _submit,
        child: Text(LocalizationService.instance.getString('login'), style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = Consumer<ThemeModeProvider>(
      builder: (context, themeModeProvider, _) {
        return TextButton(
          onPressed: () {},
          child: Text(
            LocalizationService.instance.getString('forgot_password'),
            style: TextStyle(color: themeModeProvider.themeMode == ThemeModeType.light ? Colors.black54 : Colors.white),
          ),
        );
      },
    );

    final registerButton = Padding(
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.lightGreen,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
        },
        child: Text(LocalizationService.instance.getString('register'), style: TextStyle(color: Colors.white)),
      ),
    );

    return Consumer<ThemeModeProvider>(
      builder: (context, themeModeProvider, _) {
        return Scaffold(
          backgroundColor: themeModeProvider.themeMode == ThemeModeType.light ? Colors.white : Colors.black,
          appBar: AppBar(
            title: Text(LocalizationService.instance.getString('login')),
            actions: [

              IconButton(
                onPressed: () {
                  Provider.of<ThemeModeProvider>(context, listen: false).toggleTheme();
                },
                icon: Consumer<ThemeModeProvider>(
                  builder: (context, themeModeProvider, _) {
                    IconData iconData = themeModeProvider.themeMode == ThemeModeType.light
                        ? Icons.wb_sunny
                        : Icons.nightlight_round;
                    return Icon(iconData);
                  },
                ),
              ),
            ],
          ),
          body: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  logo,
                  SizedBox(height: 24.0),
                  errorMessage,
                  SizedBox(height: 12.0),
                  email,
                  SizedBox(height: 8.0),
                  password,
                  SizedBox(height: 24.0),
                  loginButton,
                  registerButton,
                  forgotLabel
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      signIn(emailController.text, passwordController.text)
          .then((_) {
        // Successful login
        showSnackBar('Login successful');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        });
      })
          .catchError((error) {
        // Handle login failure
        if (error is FirebaseAuthException) {
          print('Error code: ${error.code}'); // Print error code for debugging
          switch (error.code) {
            case 'invalid-credential':
              showSnackBar('Incorrect email or password.');
              break;
            default:
              showSnackBar('Error: ${error.message}');
          }
        } else {
          showSnackBar('Error: $error');
        }
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}