import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';
import 'firebase_service.dart';

class VoiceHandler {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final FirebaseService _firebaseService = FirebaseService();
  String _lastRecognizedText = '';
  DateTime? _lastRecognitionTime;

  Future<void> init() async {
    await _stt.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> startListening(Function(String) onCommand) async {
    _lastRecognizedText = '';
    _lastRecognitionTime = null;

    await _stt.listen(
      onResult: (result) async {
        String text = result.recognizedWords.trim();
        
        // Skip if this is the same text we just processed
        if (text == _lastRecognizedText) {
          return;
        }

        // Check if this is a duplicate within 2 seconds
        if (_lastRecognitionTime != null && 
            DateTime.now().difference(_lastRecognitionTime!) < const Duration(seconds: 2)) {
          return;
        }

        print('Recognized text: $text'); // Debug log
        
        if (text.isNotEmpty) {
          _lastRecognizedText = text;
          _lastRecognitionTime = DateTime.now();
          
          TaskModel task = TaskModel(id: const Uuid().v4(), description: text);
          await _firebaseService.addTask(task);
          await _tts.speak("Added: $text");
          onCommand(text);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false, // Only get final results
      onSoundLevelChange: (level) {
        // Optional: Add visual feedback for sound level
        print('Sound level: $level');
      },
    );
  }

  void stopListening() {
    _stt.stop();
    _lastRecognizedText = '';
    _lastRecognitionTime = null;
  }
}
