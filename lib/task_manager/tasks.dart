import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  DatabaseReference taskRef = FirebaseDatabase.instance.ref().child('tasks');
  List tasks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenToTasksActivity();
  }

  void addItem(String text, bool isChecked) {
    taskRef.push().set(
      {
        'text': text,
        'checked': isChecked,
      },
    );
  }

  void removeItem(id) {
    print('id = ${id.runtimeType}');
    taskRef.child(id).remove();
  }

  void listenToTasksActivity() {
    taskRef.onChildAdded.listen((event) {
      final item = {
        'id': event.snapshot.key,
        'text': event.snapshot.child('text').value,
        'checked': event.snapshot.child('checked').value,
        'controller': TextEditingController(
          text: event.snapshot.child('text').value.toString(),
        ),
      };
      setState(() {
        tasks.add(item);
      });
    });

    taskRef.onChildChanged.listen((event) {
      final item = tasks.firstWhere((task) => task['id'] == event.snapshot.key);
      print('item** = $item');
      setState(() {
        item['checked'] = event.snapshot.child('checked').value;
        item['text'] = event.snapshot.child('text').value;
      });
    });
    taskRef.onChildRemoved.listen((event) {
      setState(() {
        tasks.removeWhere((task) => task['id'] == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem(
                child: Text('item1'),
              ),
            ];
          })
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final taskID = tasks[index]['id'];
                    print('task = $task');
                    return TextField(
                      controller: task['controller'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: task['checked'] ?? false,
                          onChanged: (newVal) {
                            print('new = $newVal');
                            setState(() {
                              taskRef.child(taskID).update({'checked': newVal});
                            });
                          },
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              removeItem(taskID);
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                      onChanged: (newVal) {
                        taskRef.child(taskID).update({'text': newVal});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            addItem('', false);
          });
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
