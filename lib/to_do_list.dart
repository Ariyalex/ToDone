import 'package:flutter/material.dart';
import 'package:to_do_list/add_list.dart';
import 'package:to_do_list/data/list.dart'; // Import the Todolist class
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // Import json
import 'package:to_do_list/edit.dart'; // Import the EditList class
import 'package:to_do_list/main.dart';
import 'package:timezone/data/latest.dart' as tz;

class ToDoList extends StatefulWidget {
  // Change class name
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState(); // Update state class name
}

class _ToDoListState extends State<ToDoList> {
  // Change state class name
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add GlobalKey

  DateTime selectedDate = DateTime.now();
  TimeOfDay selecedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize time zones
    _loadToDoList();
  }

  void _loadToDoList() async {
    await Todolist.loadTodoList();
    setState(() {});
  }

  void _addToDoItem(Todolist item) async {
    setState(() {
      Todolist.addTodoItem(item.listTodo,
          date: item.date,
          time: item.time); // Add item with date and time to Todolist
    });
    await Todolist.saveTodoList(); // Save the updated todo list

    setState(() {}); // Ensure the UI updates immediately
  }

  void _updateToDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todoList',
        Todolist.todoList.map((e) => json.encode(e.toJson())).toList());
  }

  void _deleteCheckedItems() async {
    setState(() {
      Todolist.todoList.removeWhere((item) => item.isDone);
    });
    await Todolist.saveTodoList();
    setState(() {}); // Ensure the UI updates immediately
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        backgroundColor: const Color(0xFFA294F9),
        title: const Text(
          'ToDone',
          style: TextStyle(
            color: Color(0xFFF5EFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (Todolist.todoList
              .any((item) => item.isDone)) // Check if any item is checked
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCheckedItems,
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use GlobalKey to open the drawer
          },
        ),
      ),
      drawer: Drawer(
        width: 250, // Set the width of the Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFA294F9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ToDone',
                      style: TextStyle(
                        color: Color(0xFFF5EFFF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Buat To Do List dan Jadwalmu',
                      style: TextStyle(
                        color: Color(0xFFF5EFFF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('To Do List'),
              onTap: () {
                null;
              },
            ),
            ListTile(
              title: const Text('Jadwal'),
              onTap: () {
                null;
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            if (Todolist.todoList.isEmpty) ...[
              // Check if Todolist is empty
              Expanded(
                child: Center(
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
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: Todolist.todoList.length, // Use Todolist length
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (index >= 0 &&
                                index < Todolist.todoList.length) {
                              final result = await Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: EditList(
                                    index: index,
                                    initialText:
                                        Todolist.todoList[index].listTodo,
                                    initialDate: Todolist.todoList[index]
                                        .date, // Pass the initial date
                                    initialTime: Todolist.todoList[index]
                                        .time, // Pass the initial time
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  Todolist.todoList[index].listTodo =
                                      result.listTodo;
                                  Todolist.todoList[index].date =
                                      result.date; // Update the date
                                  Todolist.todoList[index].time =
                                      result.time; // Update the time
                                  Todolist.todoList[index].isDone =
                                      result.isDone;
                                });
                                await Todolist.saveTodoList();
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      Todolist.todoList[index].listTodo,
                                      style: TextStyle(
                                        decoration:
                                            Todolist.todoList[index].isDone
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        decorationColor:
                                            Todolist.todoList[index].isDone
                                                ? Colors.red
                                                : Colors.transparent,
                                        decorationThickness:
                                            Todolist.todoList[index].isDone
                                                ? 2.0
                                                : 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Text(Todolist.todoList[index].date ??
                                      'Tanggal tidak dipilih'), // Display default text if date is null
                                  const SizedBox(width: 10),
                                  Text(Todolist.todoList[index].time ??
                                      ''), // Ensure time is displayed
                                ],
                              ), // Display the date
                              trailing: Checkbox(
                                value: Todolist.todoList[index]
                                    .isDone, // Use isDone status
                                onChanged: (bool? value) {
                                  setState(() {
                                    Todolist.todoList[index].isDone =
                                        value ?? false; // Update isDone status
                                  });
                                  _updateToDoList(); // Save updated status
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 10), // Add gap between list items
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            SlidePageRoute(
                page: const AddList()), // Use page instead of builder
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
