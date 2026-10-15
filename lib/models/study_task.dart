
enum TaskPriority { low, medium, high }

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final DateTime deadline;
  final TaskPriority priority;
  bool isCompleted;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });
}
