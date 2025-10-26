class Todo {
  final int? key;
  final String name;
  final String phone;

  Todo({this.key, required this.name, required this.phone});

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone};

  factory Todo.fromMap(Map map, {int? key}) {
    return Todo(key: key, name: map['name'] ?? '', phone: map['phone'] ?? '');
  }
}
