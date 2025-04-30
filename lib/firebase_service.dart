import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final String userId = 'demo_user';
  final _tasksCollection = 'tasks';

  Stream<List<TaskModel>> getTasks() {
    try {
      return _firestore
          .collection(_tasksCollection)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) {
            print('Received ${snap.docs.length} tasks from Firestore');
            return snap.docs.map((d) => TaskModel.fromJson(d.data())).toList();
          });
    } catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      // Validate task
      if (task.description.trim().isEmpty) {
        print('Cannot add empty task');
        return;
      }

      final taskData = {
        ...task.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      };
      
      print('Adding task to Firestore: ${task.description}');
      
      // Simple duplicate check using just the description
      final existingTasks = await _firestore
          .collection(_tasksCollection)
          .where('description', isEqualTo: task.description)
          .limit(1)
          .get();

      if (existingTasks.docs.isNotEmpty) {
        print('Duplicate task detected, skipping');
        return;
      }
      
      await _firestore
          .collection(_tasksCollection)
          .doc(task.id)
          .set(taskData);
          
      print('Task added successfully');
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String id, String newDescription) async {
    try {
      if (newDescription.trim().isEmpty) {
        print('Cannot update task with empty description');
        return;
      }

      print('Updating task: $id with new description: $newDescription');
      
      await _firestore
          .collection(_tasksCollection)
          .doc(id)
          .update({
            'description': newDescription,
            'lastModified': FieldValue.serverTimestamp(),
          });
          
      print('Task updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> markComplete(String id) async {
    try {
      print('Marking task as complete: $id');
      
      await _firestore
          .collection(_tasksCollection)
          .doc(id)
          .update({
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          });
          
      print('Task marked as complete successfully');
    } catch (e) {
      print('Error marking task as complete: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      print('Deleting task: $id');
      
      await _firestore
          .collection(_tasksCollection)
          .doc(id)
          .delete();
          
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
