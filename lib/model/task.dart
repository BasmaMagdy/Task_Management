class Task {
  String task;
  DateTime time;

  Task({required this.task, required this.time});

  factory Task.fromString(String task) {
    return Task(
      task: task,
      time: DateTime.now(),
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      task: map['task'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }

  Map<String, dynamic> getMap() {
    return {
      'task': task,
      'time': time.millisecondsSinceEpoch,
    };
  }
}
