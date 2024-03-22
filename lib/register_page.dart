import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:demo_project/home_page.dart';
import 'package:provider/provider.dart';
import 'package:demo_project/theme_mode_provider.dart';
import 'package:demo_project/localization_service.dart';

class RegisterPage extends StatefulWidget {
  static String tag = 'register-page';
  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailTextEditController = TextEditingController();
  final firstNameTextEditController = TextEditingController();
  final lastNameTextEditController = TextEditingController();
  final passwordTextEditController = TextEditingController();
  final confirmPasswordTextEditController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    return Consumer<ThemeModeProvider>(
      builder: (context, themeModeProvider, _) {
        return Scaffold(
          backgroundColor: themeModeProvider.themeMode == ThemeModeType.light ? Colors.white : Colors.black,
          appBar: AppBar(
            title: Text(LocalizationService.instance.getString('signup')),
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
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                children: <Widget>[
                  SizedBox(height: 10.0),
                  logo, // Logo widget added here
                  SizedBox(height: 20.0),
                  Text(
                    _errorMessage,
                    style: TextStyle(fontSize: 14.0, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) => value?.isEmpty ?? true || !value!.contains('@') ? LocalizationService.instance.getString('email_validation') : null,
                    controller: emailTextEditController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_firstNameFocus),
                    decoration: InputDecoration(
                      hintText: LocalizationService.instance.getString('email_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) => value?.isEmpty ?? true ? LocalizationService.instance.getString('first_name_validation') : null,
                    controller: firstNameTextEditController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _firstNameFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                    decoration: InputDecoration(
                      hintText: LocalizationService.instance.getString('first_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) => value?.isEmpty ?? true ? LocalizationService.instance.getString('last_name_validation') : null,
                    controller: lastNameTextEditController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _lastNameFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                    decoration: InputDecoration(
                      hintText: LocalizationService.instance.getString('last_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) => (value?.length ?? 0) < 8 ? LocalizationService.instance.getString('password_length_validation') : null,
                    autofocus: false,
                    obscureText: true,
                    controller: passwordTextEditController,
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                    decoration: InputDecoration(
                      hintText: LocalizationService.instance.getString('password_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) {
                      if (passwordTextEditController.text.length > 8 && passwordTextEditController.text != value) {
                        return LocalizationService.instance.getString('password_match_validation');
                      }
                      return null;
                    },
                    autofocus: false,
                    obscureText: true,
                    controller: confirmPasswordTextEditController,
                    textInputAction: TextInputAction.done,
                    focusNode: _confirmPasswordFocus,
                    decoration: InputDecoration(
                      hintText: LocalizationService.instance.getString('confirm_password'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _firebaseAuth.createUserWithEmailAndPassword(
                          email: emailTextEditController.text,
                          password: passwordTextEditController.text,
                        ).then((userCredential) {
                          FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                            'firstName': firstNameTextEditController.text,
                            'lastName': lastNameTextEditController.text,
                          }).then((_) {
                            Navigator.of(context).pushNamed(HomePage.tag);
                          });
                        }).catchError((error) {
                          processError(error as PlatformException);
                        });
                      }
                    },
                    child: Text(LocalizationService.instance.getString('register').toUpperCase()),
                  ),
                  SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      LocalizationService.instance.getString('cancel'),
                      style: TextStyle(fontSize: 12.0, color: themeModeProvider.themeMode == ThemeModeType.light ? Colors.black87 : Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void processError(final dynamic error) {
    if (error is PlatformException) {
      // Handle platform exceptions
      if (error.code == "ERROR_USER_NOT_FOUND") {
        setState(() {
          _errorMessage = LocalizationService.instance.getString('user_not_found_error');
        });
      } else if (error.code == "ERROR_WRONG_PASSWORD") {
        setState(() {
          _errorMessage = LocalizationService.instance.getString('incorrect_password_error');
        });
      } else {
        setState(() {
          _errorMessage = LocalizationService.instance.getString('login_error');
        });
      }
    } else {
      // Handle other types of errors
      setState(() {
        _errorMessage = LocalizationService.instance.getString('unexpected_error') + ": $error";
      });
    }
  }
}
