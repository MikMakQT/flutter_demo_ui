import 'constants.dart';

class TodoItem {
  int id = 0;
  String title = "";
  String description = "";
  DateTime deadline = DateTime.now();
  bool done = false;
  String? fbid; //Firebase id

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.done,
  });

  Map<String, dynamic> toFBMap() {
    return {
      columnTitle: title,
      columnDescription: description,
      columnDeadline: deadline.toString(),
      columnDone: done,
    };
  }

  TodoItem.fromFBMap(Map<dynamic, dynamic> data)
    : title = data[columnTitle],
      description = data[columnDescription],
      deadline = DateTime.parse(data[columnDeadline] as String),
      done = data[columnDone] as bool;
}
