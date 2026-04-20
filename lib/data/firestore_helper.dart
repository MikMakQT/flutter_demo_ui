import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_demo_ui/data/todo_item.dart';

class FirestoreHelper {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late final ref = db
      .collection("data")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("items");

  Future<void> saveTodoItem(TodoItem item) async {
    await ref
        .add(item.toFBMap())
        .then((DocumentReference doc) => item.fbid = doc.id);
  }

  Future<void> deleteTodoItem(TodoItem item) async {
    await ref
        .doc(item.fbid)
        .delete()
        .then(
          (doc) => print("Document Deleted"),
          onError: (e) => print("Error Deleting Document"),
        );
  }

  Future<void> updateTodoItem(TodoItem item) async {
    await ref
        .doc(item.fbid)
        .set(item.toFBMap())
        .onError((e, _) => print("Error Updating Data"));
  }

  Future<List<TodoItem>> getData() async {
    List<TodoItem> items = [];

    await ref.get().then((event) {
      for (var doc in event.docs) {
        TodoItem item = TodoItem.fromFBMap(doc.data() as Map<dynamic, dynamic>);
        item.fbid = doc.id;
        items.add(item);
      }
    });
    return items;
  }
}
