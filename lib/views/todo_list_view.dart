import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/todo_list_manager.dart';
import 'package:flutter_demo_ui/views/input_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/todo_item.dart';

class TodoListView extends StatelessWidget {
  //final List<TodoItem> _items = [];

  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListManager>(
      builder: (context, listManager, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tehtävä Lista'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/input');
                },
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/info');
                },
                icon: Icon(Icons.menu_book),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: listManager.items.length,
            itemBuilder: (context, index) {
              return _buildTodoCard(
                listManager.items[index],
                context,
                listManager,
              );
            },
          ),
        );
      },
    );
  }
}

Center _buildTodoCard(
  TodoItem item,
  BuildContext context,
  TodoListManager manager,
) {
  return Center(
    child: Card(
      child: Column(
        children: <Widget>[
          ListTile(
            trailing: IconButton(
              onPressed: () {
                manager.toggleDone(item);
              },
              icon: Icon(
                Icons.done,
                color: item.done ? Colors.green : Colors.grey,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.title),
                Text(DateFormat('dd.MM.yyyy').format(item.deadline)),
              ],
            ),
            subtitle: Text(item.description),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputView(item: item),
                    ),
                  );
                },
                child: const Text("Muokkaa"),
              ),
              TextButton(
                onPressed: () {
                  manager.delete(item);
                },
                child: const Text("Poista"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
