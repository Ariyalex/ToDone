import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todolist {
  String listTodo;
  String date;
  String? time; // Add new property
  bool isDone;

  Todolist(this.listTodo, {this.isDone = false, required String date, this.time}) 
      : date = DateTime.parse(date).toIso8601String().split('T').first;

  static List<Todolist> todoList = [];

  set title(String title) {}

  static void addTodoItem(String item, String date, {String? time}) {
    todoList.add(Todolist(item, date: DateTime.parse(date).toIso8601String().split('T').first, time: time));
  }

  Map<String, dynamic> toJson() => {
    'listTodo': listTodo,
    'isDone': isDone,
    'date': date,
    'time': time,
  };

  static Todolist fromJson(Map<String, dynamic> json) => Todolist(
    json['listTodo'] ?? '',
    isDone: json['isDone'] ?? false,
  date: (json['date'] ?? '').split('T').first,
    time: json['time'],
  );

  static Future<void> saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todoList', todoList.map((e) => json.encode(e.toJson())).toList());
  }

  static Future<void> loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoListString = prefs.getStringList('todoList');
    if (todoListString != null) {
      todoList = todoListString.map((item) => Todolist.fromJson(json.decode(item))).toList();
    }
  }
}