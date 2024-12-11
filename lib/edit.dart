import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class EditList extends StatefulWidget {
  final int index;
  final String initialText;
  final String initialDate; // Add initialDate parameter

  const EditList({super.key, required this.index, required this.initialText, required this.initialDate});

  @override
  _EditListState createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  late TextEditingController _textController;
  late TextEditingController _dateController; // Add date controller
  DateTime? _selectedDate; // Add selected date

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _dateController = TextEditingController(text: widget.initialDate); // Initialize date controller
    _selectedDate = DateTime.tryParse(widget.initialDate); // Initialize selected date
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate!.toIso8601String().split('T').first;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _dateController.dispose(); // Dispose date controller
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Edit To Do',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'), // Add date input field
                readOnly: true,
                onTap: () => _selectDate(context), // Open date picker on tap
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, Todolist(_textController.text, isDone: Todolist.todoList[widget.index].isDone, date: _dateController.text));
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