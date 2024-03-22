import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project/theme_mode_provider.dart';
import 'package:provider/provider.dart';

import 'localization_service.dart'; // Import the ThemeModeProvider

class HomePage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _firstName = '';
  String _lastName = '';
  String _selectedLanguage = 'English'; // Default language

  @override
  void initState() {
    super.initState();
    _getName();
  }

  Future<void> _getName() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userData.exists && userData.data() != null) {
        setState(() {
          _firstName = userData.data()!['firstName'];
          _lastName = userData.data()!['lastName'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModeProvider = Provider.of<ThemeModeProvider>(context); // Get the theme mode provider instance

    final alucard = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 72.0,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/profile.png'),
        ),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '$_firstName $_lastName',
        style: TextStyle(
          fontSize: 28.0,
          color: themeModeProvider.themeMode == ThemeModeType.light ? Colors.black : Colors.white, // Adjust text color based on theme mode
        ),
      ),
    );

    final languages = ['English', 'Spanish', 'French']; // List of supported languages

    final languageDropdown = DropdownButton<String>(
      value: _selectedLanguage,
      items: languages.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedLanguage = newValue!;
        });
      },
    );

    final lorem = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        _getLoremIpsumText(), // Get the Lorem ipsum text based on the selected language
        style: TextStyle(
          fontSize: 16.0,
          color: themeModeProvider.themeMode == ThemeModeType.light ? Colors.black : Colors.white, // Adjust text color based on theme mode
        ),
      ),
    );

    final logoutButton = Padding(
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ), backgroundColor: Colors.brown,
        ),
        onPressed: () {
          _firebaseAuth.signOut();
          Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        },
        child: Text('Logout', style: TextStyle(color: Colors.white)),
      ),
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      child: Column(
        children: <Widget>[
          alucard,
          welcome,
          languages.isNotEmpty ? languageDropdown : SizedBox.shrink(), // Show language dropdown if there are languages available
          lorem,
          SizedBox(height: 24.0),
          logoutButton,
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(LocalizationService.instance.getString('home_page')),
            automaticallyImplyLeading: false, // Remove the back arrow icon
            actions: [
              IconButton(
                icon: Icon(themeModeProvider.themeMode == ThemeModeType.light ? Icons.brightness_2 : Icons.wb_sunny),
                onPressed: () {
                  themeModeProvider.toggleTheme(); // Toggle theme mode on button press
                },
              ),
            ],
          ),
          body: Container(
            color: themeModeProvider.themeMode == ThemeModeType.light ? Colors.redAccent : Colors.black, // Set background color based on theme mode
            child: body,
          ),
        );
      },
    );
  }

  String _getLoremIpsumText() {
    // Return Lorem ipsum text based on the selected language
    switch (_selectedLanguage) {
      case 'Spanish':
        return 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec hendrerit condimentum mauris id tempor. Praesent eu commodo lacus. Praesent eget mi sed libero eleifend tempor. Sed at fringilla ipsum. Duis malesuada feugiat urna vitae convallis. Aliquam eu libero arcu.';
      case 'French':
        return ' ipsum dolor sit amet, consectetur adipiscing elit. Donec hendrerit condimentum mauris id tempor. Praesent eu commodo lacus. Praesent eget mi sed libero eleifend tempor. Sed at fringilla ipsum. Duis malesuada feugiat urna vitae convallis. Aliquam eu libero arcu.';
      default:
        return 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec hendrerit condimentum mauris id tempor. Praesent eu commodo lacus. Praesent eget mi sed libero eleifend tempor. Sed at fringilla ipsum. Duis malesuada feugiat urna vitae convallis. Aliquam eu libero arcu.';
    }
  }
}
