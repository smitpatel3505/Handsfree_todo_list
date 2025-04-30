class TaskModel {
  final String id;
  final String description;
  final bool completed;
  final DateTime? timestamp;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.description,
    this.completed = false,
    this.timestamp,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'completed': completed,
        'timestamp': timestamp,
        'completedAt': completedAt,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        description: json['description'],
        completed: json['completed'] ?? false,
        timestamp: json['timestamp']?.toDate(),
        completedAt: json['completedAt']?.toDate(),
      );
}
