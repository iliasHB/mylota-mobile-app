class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});

  Map<String, dynamic> toJson() => {'title': title, 'completed': completed};

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(title: json['title'], completed: json['completed']);
}
