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

    final languages = ['English', 'Malay', 'Chinese']; // List of supported languages

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
      case 'Malay':
        return 'Hey! Nama saya Seemon, peminat Flutter yang bersemangat dan pelajar di MSU. Dengan kebolehan untuk inovasi dan keinginan untuk belajar, saya menyertai pasukan AQ Wise sebagai pembangun pelatih, bersedia untuk mencipta gelombang dalam dunia pembangunan aplikasi.'
            'Didorong oleh keinginan untuk meneroka ufuk baharu dan berbekalkan asas yang kukuh dalam kejuruteraan perisian.';
      case 'Chinese':
        return '嘿！我叫 Seemon，是一位熱情的 Flutter 愛好者，也是密西根州立大學的學生。憑藉創新的訣竅和學習的渴望，我作為實習開發人員加入 AQ Wise 團隊，準備在應用程式開發領域掀起波瀾。'
            '在探索新視野的願望的驅使下，並憑藉紮實的軟體工程基礎，我為該專案帶來了新鮮的想法和獨特的視角。';
     default:
        return 'Hey there! My name is Seemon, a passionate Flutter enthusiast and a student at MSU. With a knack for innovation and a hunger to learn, I joins AQ Wise team as an intern developer, ready to make waves in the '
            'world of app development.Driven by a desire to explore new horizons and armed with a solid foundation in software engineering, I brings fresh ideas and a unique perspective to the project.';
    }
  }
}
