import 'dart:collection';

import 'package:flutter/material.dart';
//import 'package:flutter_demo_ui/data/db_helper.dart';
import 'package:flutter_demo_ui/data/firestore_helper.dart';
import 'package:flutter_demo_ui/data/todo_item.dart';

class TodoListManager extends ChangeNotifier {
  final List<TodoItem> _items = [];
  //final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final fbHelper = FirestoreHelper();

  Future<void> init() async {
    //loadFromDB();
    loadFromFirebase();
  }

  UnmodifiableListView<TodoItem> get items =>
      UnmodifiableListView(_items.reversed);

  UnmodifiableListView<TodoItem> get todoitems =>
      UnmodifiableListView(_items.where((item) => false));

  void add(TodoItem item) async {
    if (_items.isEmpty) {
      item.id = 1;
    } else {
      item.id = _items.last.id + 1;
    }
    _items.add(item);
    //dbHelper.insert(item);
    fbHelper.saveTodoItem(item);
    notifyListeners();
  }

  void delete(TodoItem item) async {
    _items.remove(item);
    //await dbHelper.delete(item.id);
    await fbHelper.deleteTodoItem(item);
    notifyListeners();
  }

  void update(TodoItem item) async {
    TodoItem? oldItem;

    for (TodoItem i in _items) {
      if (i.id == item.id) {
        oldItem = i;
        break;
      }
    }
    if (oldItem != null) {
      oldItem.title = item.title;
      oldItem.description = item.description;
      oldItem.deadline = item.deadline;
      oldItem.done = item.done;

      //await dbHelper.update(item);
      await fbHelper.updateTodoItem(item);
      notifyListeners();
    }
  }

  Future<void> toggleDone(TodoItem item) async {
    item.done = !item.done;
    //await dbHelper.update(item);
    notifyListeners();
  }

  Future<void> loadFromFirebase() async {
    final list = await fbHelper.getData();

    int id = 1;
    for (TodoItem item in list) {
      item.id = id;
      _items.add(item);
      id++;
    }

    notifyListeners();
  }
}
