import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';
import 'dart:async';

class EditList extends StatefulWidget {
  final int index;
  final String initialText;
  final String? initialDate; // Allow initialDate to be null
  final String? initialTime;

  const EditList({super.key, required this.index, required this.initialText, this.initialDate, this.initialTime});

  @override
  EditListState createState() => EditListState();
}

class EditListState extends State<EditList> {
  late TextEditingController _textController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _dateController = TextEditingController(text: widget.initialDate ?? ''); // Initialize date controller
    _timeController = TextEditingController(text: widget.initialTime ?? ''); // Initialize time controller
    _selectedDate = widget.initialDate != null ? DateTime.tryParse(widget.initialDate!) : null; // Initialize selected date
    _selectedTime = widget.initialTime != null ? TimeOfDay(
      hour: int.parse(widget.initialTime!.split(':')[0]),
      minute: int.parse(widget.initialTime!.split(' ')[0].split(':')[1]),
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
    _dateController.dispose();
    _timeController.dispose();
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
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time'),
                readOnly: true,
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      final updatedItem = Todolist(
                        _textController.text,
                        isDone: Todolist.todoList[widget.index].isDone,
                        date: _dateController.text.isEmpty ? null : _dateController.text,
                        time: _timeController.text.isEmpty ? null : _timeController.text,
                      );
                      Navigator.pop(context, updatedItem);
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