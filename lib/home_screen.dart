import 'package:flutter/material.dart';
import 'package:to_do_list/add_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _toDoList = [];

  void _addToDoItem(String item) {
    setState(() {
      _toDoList.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
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
        child: Column(
          children: <Widget>[
            if (_toDoList.isEmpty) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/home_screen.jpg',
                      width: 400,
                    ),
                    const Text(
                      'Belum ada To Do List, coba tambahkan lewat tombol di bawah',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(_toDoList[index]),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (bool? value) {
                        setState(() {
                          _toDoList.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddList()),
          );
          if (result != null) {
            _addToDoItem(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}