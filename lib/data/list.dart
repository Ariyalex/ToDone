import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todolist {
  String listTodo;
  bool isDone;

  Todolist(this.listTodo, {this.isDone = false});

  static List<Todolist> todoList = [];

  static void addTodoItem(String item) {
    todoList.add(Todolist(item));
  }

  Map<String, dynamic> toJson() => {
    'listTodo': listTodo,
    'isDone': isDone,
  };

  static Todolist fromJson(Map<String, dynamic> json) => Todolist(
    json['listTodo'],
    isDone: json['isDone'],
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