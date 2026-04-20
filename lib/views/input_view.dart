import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/todo_item.dart';
import 'package:flutter_demo_ui/data/todo_list_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InputView extends StatelessWidget {
  final TodoItem? item;
  const InputView({super.key, this.item});

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lisää uusi tehtävä")),
      body: InputForm(item: item),
    );
  }
}

class InputForm extends StatefulWidget {
  final TodoItem? item;
  const InputForm({super.key, this.item});

  @override
  State<StatefulWidget> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();

  int id = 0;
  String title = "";
  String description = "";
  bool done = false;
  DateTime deadline = DateTime.now();
  bool isEdit = false;

  @override
  void initState() {
    if (widget.item != null) {
      isEdit = true;
      title = widget.item!.title;
      description = widget.item!.description;
      deadline = widget.item!.deadline;
      done = widget.item!.done;
      id = widget.item!.id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: title,
              decoration: const InputDecoration(
                hintText: "Tehtävän Nimi",
                labelText: "Nimi",
              ),
              onChanged: (value) => {
                setState(() {
                  title = value;
                }),
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Anna Tehtävälle Nimi";
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(
                hintText: "Tehtävän Kuvaus",
                labelText: "Kuvaus",
              ),
              onChanged: (value) => {
                setState(() {
                  description = value;
                }),
              },
              minLines: 5,
              maxLines: 10,
            ),
            _DatePicker(
              date: deadline,
              onChanged: (value) {
                setState(() {
                  deadline = value;
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: done,
                  onChanged: (value) {
                    setState(() {
                      done = value!;
                    });
                  },
                ),
                const Text("Valmis"),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  TodoItem item = TodoItem(
                    id: id,
                    title: title,
                    description: description,
                    deadline: deadline,
                    done: done,
                  );
                  if (isEdit) {
                    Provider.of<TodoListManager>(
                      context,
                      listen: false,
                    ).update(item);
                  } else {
                    Provider.of<TodoListManager>(
                      context,
                      listen: false,
                    ).add(item);
                  }
                  Navigator.pop(context);
                },
                child: isEdit ? const Text("Muokkaa") : Text("Lisää"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePicker({required this.date, required this.onChanged});

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  final formatter = DateFormat("d.M.yyyy");
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formatter.format(widget.date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextButton(
          child: const Text("Muokkaa"),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (newDate == null) {
              return;
            }
            widget.onChanged(newDate);
          },
        ),
      ],
    );
  }
}
