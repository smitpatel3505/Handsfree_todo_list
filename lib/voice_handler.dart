import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';
import 'firebase_service.dart';

class VoiceHandler {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> init() async {
    await _stt.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> startListening(Function(String) onCommand) async {
    await _stt.listen(
      onResult: (result) async {
        String command = result.recognizedWords.toLowerCase();
        print('Recognized command: $command'); // Debug log
        
        if (command.contains("add task")) {
          String desc = command.replaceFirst("add task", "").trim();
          print('Adding task: $desc'); // Debug log
          
          TaskModel task = TaskModel(id: const Uuid().v4(), description: desc);
          await _firebaseService.addTask(task);
          await _tts.speak("Task added: $desc");
          onCommand(command);
        } else if (command.contains("complete task")) {
          String keyword = command.replaceFirst("complete task", "").trim();
          print('Completing task with keyword: $keyword'); // Debug log
          
          List<TaskModel> tasks = await _firebaseService.getTasks().first;
          for (var task in tasks) {
            if (task.description.toLowerCase().contains(keyword) && !task.completed) {
              await _firebaseService.markComplete(task.id);
              await _tts.speak("Marked task as complete: ${task.description}");
              onCommand(command);
              return;
            }
          }
          await _tts.speak("Task not found");
          onCommand(command);
        } else {
          await _tts.speak("Sorry, I didn't understand");
          onCommand(command);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void stopListening() => _stt.stop();
}
