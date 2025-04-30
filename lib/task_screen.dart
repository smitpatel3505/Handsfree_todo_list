import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'voice_handler.dart';
import 'task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final VoiceHandler _voiceHandler = VoiceHandler();
  bool _isListening = false;
  String _lastCommand = '';

  @override
  void initState() {
    super.initState();
    _voiceHandler.init();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    if (_isListening) {
      _voiceHandler.startListening((command) {
        setState(() {
          _isListening = false;
          _lastCommand = command;
        });
      });
    } else {
      _voiceHandler.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VoiceDo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            if (_lastCommand.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last command: $_lastCommand',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Commands:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Say "add task" followed by your task'),
                  const Text('Example: "add task buy groceries"'),
                  const SizedBox(height: 8),
                  const Text('• Say "complete task" followed by task description'),
                  const Text('Example: "complete task buy groceries"'),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TaskModel>>(
                stream: _firebaseService.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_none,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet.\nTap the mic button and say "add task" followed by your task!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Icon(
                            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: task.completed ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            task.description,
                            style: TextStyle(
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                              color: task.completed ? Colors.grey : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.timestamp != null)
                                Text(
                                  'Added: ${_formatDate(task.timestamp!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (task.completed && task.completedAt != null)
                                Text(
                                  'Completed: ${_formatDate(task.completedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[300],
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: Text('Are you sure you want to delete "${task.description}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _firebaseService.deleteTask(task.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            _firebaseService.markComplete(task.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Listening...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          FloatingActionButton(
            onPressed: _toggleListening,
            backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
            child: Icon(
              _isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
