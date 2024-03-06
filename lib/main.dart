import 'package:demo_project/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: Text('Light/Dark Mode Example'),
      ),
      body: Center(
        child: Consumer<ThemeModeProvider>(
          builder: (context, themeModeProvider, _) {
            return ElevatedButton(
              onPressed: () {
                themeModeProvider.toggleTheme();
              },
              child: Text('Toggle Theme'),
            );
          },
        ),
      ),
    );
  }
}
