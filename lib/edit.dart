import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class EditList extends StatelessWidget {
  final int index;
  final String initialText;

  const EditList({super.key, required this.index, required this.initialText});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialText);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        leading: 
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'ToDone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                if (index >= 0 && index < Todolist.todoList.length) {
                  Todolist.todoList.removeAt(index);
                  await Todolist.saveTodoList();
                  if (context.mounted) {
                    Navigator.pop(context, 'deleted');
                  }
                }
              },
            ),
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Edit To Do',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, Todolist(controller.text, isDone: Todolist.todoList[index].isDone));
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}