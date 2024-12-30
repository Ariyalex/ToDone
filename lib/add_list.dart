import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class AddList extends StatefulWidget {
  const AddList ({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate; // Allow selectedDate to be null
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA294F9),
        leading: 
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!mounted) return; // Add this line
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () => _pickTime(),
                   child: const Text('Pilih Waktu'),
                ),
                const SizedBox(width: 20),
                Text(
                  _selectedTime == null ? 'Waktu tidak dipilih' : _selectedTime!.format(context),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  
                  onPressed: _isButtonDisabled ? null : () async {
                    final newItem = Todolist(
                      _controller.text, 
                      date: _selectedDate?.toIso8601String().split('T').first,
                      time: _selectedTime?.format(context),
                    );
                    if (!mounted) return; // Add this line
                    Navigator.pop(context, newItem); // Pass new item back to HomeScreen
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return 'Tanggal belum dipilih';
    return "${date.day}-${date.month}-${date.year}";
  }
}

