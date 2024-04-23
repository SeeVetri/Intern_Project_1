import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_project/theme_mode_provider.dart';
import 'package:demo_project/localization_service.dart'; // Import LocalizationService
import 'login_page.dart'; // Import LoginPage
import 'register_page.dart'; // Import RegisterPage
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalizationService.instance.loadLanguage('en'); // Load default language
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeModeProvider(),
      child: LocalizationProvider( // Wrap with LocalizationProvider
        child: Consumer<ThemeModeProvider>(
          builder: (context, themeModeProvider, _) {
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeModeProvider.themeMode == ThemeModeType.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
              home: HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

class LocalizationProvider extends StatelessWidget {
  final Widget child;

  const LocalizationProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.instance.getString('title')), // Localized title
        actions: [
          LanguageDropdown(), // Language selection dropdown menu
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/background_light.jpg'
                  : 'assets/background_dark.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text(LocalizationService.instance.getString('login')), // Localized button text
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                  },
                  child: Text(LocalizationService.instance.getString('register')), // Localized button text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class LanguageDropdown extends StatefulWidget {
  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String _selectedLanguage = 'English'; // Default language

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<String>(
        icon: Icon(Icons.language),
        onChanged: (String? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
            print('Selected language: $_selectedLanguage');
            switch (_selectedLanguage) {
              case 'English':
                LocalizationService.instance.loadLanguage('en');
                break;
              case 'Malay':
                LocalizationService.instance.loadLanguage('ml');
                break;
            // Add cases for other languages
            }
            // Reload the page
            Navigator.popAndPushNamed(context, '/');
          });
        },
        items: <String>['English', 'Malay'] // Add other language options here
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
