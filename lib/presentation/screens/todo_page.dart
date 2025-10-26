import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../data/model/todo.dart';

class TodoPage extends StatefulWidget {
  final String? username;
  const TodoPage({super.key, this.username});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Box? todosBox;

  @override
  void initState() {
    super.initState();
    _ensureBox();
  }

  Future<void> _ensureBox() async {
    if (!Hive.isBoxOpen('todos')) {
      await Hive.openBox('todos');
    }
    setState(() {
      todosBox = Hive.box('todos');
    });
  }

  void _showAddEditDialog({int? key, Todo? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'Add Todo' : 'Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please provide name and phone.')),
                );
                return;
              }

              final todo = Todo(name: name, phone: phone);
              if (key != null) {
                todosBox!.put(key, todo.toMap());
              } else {
                todosBox!.add(todo.toMap());
              }

              Navigator.of(c).pop();
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleUsername =
        widget.username ?? Hive.box('myBox').get('email') ?? '';

    if (todosBox == null) {
      return Scaffold(
        appBar: AppBar(title: Text(titleUsername)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(titleUsername)),
      body: ValueListenableBuilder(
        valueListenable: todosBox!.listenable(),
        builder: (context, Box box, _) {
          final keys = box.keys.cast<dynamic>().toList();
          if (keys.isEmpty) {
            return Center(child: Text('No todos yet. Tap + to add.'));
          }

          return ListView.separated(
            itemCount: keys.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final key = keys[index];
              final map = box.get(key) as Map;
              final todo = Todo.fromMap(map as Map, key: key as int?);

              return ListTile(
                title: Text(todo.name),
                subtitle: Text(todo.phone),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          _showAddEditDialog(key: key as int?, existing: todo),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        box.delete(key);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
