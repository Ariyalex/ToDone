import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class EditList extends StatefulWidget {
  final int index;
  final String initialText;
  final String initialDate; // Add initialDate parameter
  final String? initialTime; // Add initialTime parameter

  const EditList({super.key, required this.index, required this.initialText, required this.initialDate, this.initialTime});

  @override
  _EditListState createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  late TextEditingController _textController;
  late TextEditingController _dateController; // Add date controller
  late TextEditingController _timeController; // Add time controller
  DateTime? _selectedDate; // Add selected date
  TimeOfDay? _selectedTime; // Add selected time

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _dateController = TextEditingController(text: widget.initialDate); // Initialize date controller
    _timeController = TextEditingController(text: widget.initialTime ?? ''); // Initialize time controller
    _selectedDate = DateTime.tryParse(widget.initialDate); // Initialize selected date
    _selectedTime = widget.initialTime != null ? TimeOfDay(
      hour: int.parse(widget.initialTime!.split(':')[0]),
      minute: int.parse(widget.initialTime!.split(':')[1].split(' ')[0]),
    ) : null; // Initialize selected time
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime!.format(context); // Ensure time is formatted correctly
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _dateController.dispose(); // Dispose date controller
    _timeController.dispose(); // Dispose time controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA294F9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
            'ToDone',
            style: TextStyle(
              color: Color(0xFFF5EFFF),
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
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time'), // Add time input field
                readOnly: true,
                onTap: () => _selectTime(context), // Open time picker on tap
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(context, Todolist(
                        _textController.text,
                        isDone: Todolist.todoList[widget.index].isDone,
                        date: _dateController.text,
                        time: _timeController.text,
                      ));
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}