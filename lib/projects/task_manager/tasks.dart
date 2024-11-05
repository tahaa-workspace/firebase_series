import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  DatabaseReference taskRef = FirebaseDatabase.instance.ref().child('tasks');

  List pendingTasks = [];
  List completedTasks = [];

  String item1 = 'Remove All';

  @override
  void initState() {
    super.initState();

    listenToTasksActivity();
  }

  Future<void> addItem(String text, bool isChecked) async {
    await taskRef.push().set(
      {
        'text': text,
        'checked': isChecked,
      },
    );
  }

  Future<void> removeItem(taskID) async {
    await taskRef.child(taskID).remove();
  }

  Future<void> toggleChecked(taskID, bool isChecked) async {
    await taskRef.child(taskID).update({'checked': isChecked});
  }

  void listenToTasksActivity() {
    taskRef.onChildAdded.listen((event) {
      setState(() {
        final task = {
          'id': event.snapshot.key,
          'text': event.snapshot.child('text').value,
          'checked': event.snapshot.child('checked').value,
          'controller': TextEditingController(
            text: event.snapshot.child('text').value.toString() ?? '',
          ),
        };

        if (task['checked'] == true) {
          completedTasks.add(task);
        } else {
          pendingTasks.add(task);
        }
      });
    });

    taskRef.onChildChanged.listen((event) {
      setState(() {
        if (event.snapshot.child('checked').value == true) {
          pendingTasks.removeWhere((task) => task['id'] == event.snapshot.key);

          final completedTask = completedTasks.firstWhere(
              (task) => task['id'] == event.snapshot.key,
              orElse: () => false);

          if (completedTask != false) {
            completedTask['checked'] = event.snapshot.child('checked').value;
            completedTask['text'] = event.snapshot.child('text').value;
          } else {
            completedTasks.add({
              'id': event.snapshot.key,
              'text': event.snapshot.child('text').value,
              'checked': event.snapshot.child('checked').value,
              'controller': TextEditingController(
                text: event.snapshot.child('text').value.toString() ?? '',
              ),
            });
          }
        } else {
          completedTasks
              .removeWhere((task) => task['id'] == event.snapshot.key);

          final pendingTask = pendingTasks.firstWhere(
              (task) => task['id'] == event.snapshot.key,
              orElse: () => false);

          if (pendingTask != false) {
            pendingTask['checked'] = event.snapshot.child('checked').value;
            pendingTask['text'] = event.snapshot.child('text').value;
          } else {
            pendingTasks.add({
              'id': event.snapshot.key,
              'text': event.snapshot.child('text').value,
              'checked': event.snapshot.child('checked').value,
              'controller': TextEditingController(
                text: event.snapshot.child('text').value.toString() ?? '',
              ),
            });
          }
        }
      });
    });

    taskRef.onChildRemoved.listen((event) {
      setState(() {
        pendingTasks.removeWhere((task) => task['id'] == event.snapshot.key);

        completedTasks.removeWhere((task) => task['id'] == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == item1) {
                taskRef.remove();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: item1,
                  child: Text(item1),
                ),
              ];
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
                    final taskID = pendingTasks[index]['id'];

                    return TextField(
                      controller: task['controller'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: task['checked'] ?? false,
                          onChanged: (newVal) async {
                            await toggleChecked(taskID, newVal ?? false);

                            setState(() {});
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
              // InkWell(
              //     onTap: () {
              //       addItem('', false);
              //     },
              //     child: const Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(Icons.add),
              //         Text('Add Item'),
              //       ],
              //     )),
              if (completedTasks.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Completed Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final completedTask = completedTasks[index];
                    final completedTaskID = completedTask['id'];

                    return TextField(
                      controller: completedTask['controller'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: completedTask['checked'] ?? false,
                          onChanged: (newVal) async {
                            await toggleChecked(
                                completedTaskID, newVal ?? false);

                            setState(() {});
                          },
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              removeItem(completedTaskID);
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                      onChanged: (newVal) {
                        taskRef.child(completedTaskID).update({'text': newVal});
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
          addItem('', false);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
