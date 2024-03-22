import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_project/theme_mode_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeModeProvider(),
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeModeProvider, _) {
          return MaterialApp(
            theme: ThemeData.light(), // Your light theme
            darkTheme: ThemeData.dark(), // Your dark theme
            themeMode: themeModeProvider.themeMode == ThemeModeType.light
                ? ThemeMode.light
                : ThemeMode.dark,
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Light/Dark Mode'),
      ),
      body: Center(
        child: Consumer<ThemeModeProvider>(
          builder: (context, themeModeProvider, _) {
            IconData iconData = themeModeProvider.themeMode == ThemeModeType.light
                ? Icons.wb_sunny
                : Icons.nightlight_round;
            String text = themeModeProvider.themeMode == ThemeModeType.light
                ? 'Light'
                : 'Dark';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 50), // Display moon or sun icon
                SizedBox(height: 20),
                Text(text, style: TextStyle(fontSize: 20)), // Display "Dark" or "Light" text
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    themeModeProvider.toggleTheme();
                  },
                  child: Text('Toggle Theme'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
