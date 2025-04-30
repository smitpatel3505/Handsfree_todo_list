import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicedo/task_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBSrITnlHrZAZJRBzlFTa1xW9ZrdUb57B8",
          authDomain: "voicedo-eda53.firebaseapp.com",
          projectId: "voicedo-eda53",
          storageBucket: "voicedo-eda53.firebasestorage.app",
          messagingSenderId: "232586260836",
          appId: "1:232586260836:web:4bc8a5fe338a78a4464a71",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const VoiceDoApp());
}

class VoiceDoApp extends StatelessWidget {
  const VoiceDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const TaskScreen(),
    );
  }
}
