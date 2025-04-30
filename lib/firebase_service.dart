import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final String userId = 'demo_user';

  Stream<List<TaskModel>> getTasks() {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('timestamp', descending: true)  // Order by newest first
          .snapshots()
          .map((snap) {
            print('Received ${snap.docs.length} tasks from Firestore'); // Debug log
            return snap.docs.map((d) => TaskModel.fromJson(d.data())).toList();
          });
    } catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final taskData = {
        ...task.toJson(),
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp
      };
      
      print('Adding task to Firestore: ${task.description}'); // Debug log
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .set(taskData);
          
      print('Task added successfully'); // Debug log
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> markComplete(String id) async {
    try {
      print('Marking task as complete: $id'); // Debug log
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(id)
          .update({
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          });
          
      print('Task marked as complete successfully'); // Debug log
    } catch (e) {
      print('Error marking task as complete: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      print('Deleting task: $id'); // Debug log
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(id)
          .delete();
          
      print('Task deleted successfully'); // Debug log
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
