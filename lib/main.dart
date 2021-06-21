import 'package:enstagram/pages/onbording_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Firebase.initializeApp();
    return MaterialApp(
      title: 'Enstagram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        accentColor: Colors.lime,
        iconTheme: IconThemeData(color: Colors.black45),
      ),
      home: OnBordingScreen(),
    );
  }
}
