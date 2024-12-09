import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';

class AddList extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddList ({super.key});

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
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                final newItem = Todolist(_controller.text);
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