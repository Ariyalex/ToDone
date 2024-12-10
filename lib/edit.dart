import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';
import 'package:to_do_list/home_screen.dart';

class EditList extends StatefulWidget {
  final int index;
  final String initialText;

  const EditList({super.key, required this.index, required this.initialText});

  @override
  _EditListState createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        leading: IconButton(
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
              if (widget.index >= 0 && widget.index < Todolist.todoList.length) {
                setState(() {
                  Todolist.todoList.removeAt(widget.index);
                });
                await Todolist.saveTodoList();
                if (context.mounted) {
                  Navigator.pop(context, 'deleted');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
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
                  Navigator.pop(context, Todolist(controller.text, isDone: Todolist.todoList[widget.index].isDone));
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