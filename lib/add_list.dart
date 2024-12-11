import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class AddList extends StatefulWidget {

  const AddList ({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkIfEmpty);
  }

  void _checkIfEmpty() {
    setState(() {
      _isButtonDisabled = _controller.text.isEmpty;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:  _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String getFormattedDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Masukkan To Do List',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => _selectDate(),
                      child: const Text('Pilih Tanggal'),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      getFormattedDate(_selectedDate),
                      style: const TextStyle(fontSize: 20),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isButtonDisabled ? null : () {
                final newItem = Todolist(_controller.text, date: _selectedDate.toString());
                Navigator.pop(context, newItem); // Pass new item back to HomeScreen
              },
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}