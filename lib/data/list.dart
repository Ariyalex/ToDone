import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todolist {
  String listTodo;
  String date;
  bool isDone;

  Todolist(this.listTodo, {this.isDone = false, required String date}) 
      : date = DateTime.parse(date).toIso8601String().split('T').first;

  static List<Todolist> todoList = [];

  set title(String title) {}

  static void addTodoItem(String item, String date) {
    todoList.add(Todolist(item, date: DateTime.parse(date).toIso8601String().split('T').first));
  }

  Map<String, dynamic> toJson() => {
    'listTodo': listTodo,
    'isDone': isDone,
    'date': date,
  };

  static Todolist fromJson(Map<String, dynamic> json) => Todolist(
    json['listTodo'] ?? '',
    isDone: json['isDone'] ?? false,
    date: (json['date'] ?? '').split('T').first,
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