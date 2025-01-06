import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todolist {
  String listTodo;
  String? date; // Allow date to be null
  String? time;
  bool isDone;

  Todolist(this.listTodo, {this.isDone = false, this.date, this.time});

  static List<Todolist> todoList = [];

  set title(String title) {}

  static void addTodoItem(String item, {String? date, String? time}) {
    todoList.add(Todolist(item, date: date, time: time));
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
        date: json['date'],
        time: json['time'],
      );

  static Future<void> saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'todoList', todoList.map((e) => json.encode(e.toJson())).toList());
  }

  static Future<void> loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoListString = prefs.getStringList('todoList');
    if (todoListString != null) {
      todoList = todoListString
          .map((item) => Todolist.fromJson(json.decode(item)))
          .toList();
    }
  }
}
