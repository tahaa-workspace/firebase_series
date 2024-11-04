import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  DatabaseReference taskRef = FirebaseDatabase.instance.ref().child('tasks');
  DatabaseReference checkedRef =
      FirebaseDatabase.instance.ref().child('checkedItemsList');
  List tasks = [];
  List checkedTasks = [];

  String item1 = 'Remove Unchecked Tasks';
  String item2 = 'Remove Checked Tasks';
  String item3 = 'Remove All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenToTasksActivity();
    listenToCheckedActivity();
  }

  Future<void> addItem(String text, bool isChecked) async {
    await taskRef.push().set(
      {
        'text': text,
        'checked': isChecked,
      },
    );
  }

  Future<void> addCheckedItem(String text, bool isChecked) async {
    await checkedRef.push().set({
      'text': text,
      'checked': isChecked,
    });
  }

  Future<void> removeItem(id) async {
    await taskRef.child(id).remove();
  }

  Future<void> removeCheckedItem(id) async {
    await checkedRef.child(id).remove();
  }

  void listenToTasksActivity() {
    taskRef.onChildAdded.listen((event) {
      final item = {
        'id': event.snapshot.key,
        'text': event.snapshot.child('text').value,
        'checked': event.snapshot.child('checked').value,
        'controller': TextEditingController(
          text: event.snapshot.child('text').value.toString() ?? 'nil',
        ),
      };
      setState(() {
        tasks.add(item);
      });
    });

    taskRef.onChildChanged.listen((event) {
      final task = tasks.firstWhere((task) => task['id'] == event.snapshot.key);
      setState(() {
        task['checked'] = event.snapshot.child('checked').value;
        task['text'] = event.snapshot.child('text').value;
      });
    });
    taskRef.onChildRemoved.listen((event) {
      setState(() {
        tasks.removeWhere((task) => task['id'] == event.snapshot.key);
      });
    });
  }

  void listenToCheckedActivity() {
    checkedRef.onChildAdded.listen((event) {
      final item = {
        'id': event.snapshot.key,
        'text': event.snapshot.child('text').value,
        'checked': event.snapshot.child('checked').value,
        'controller': TextEditingController(
          text: event.snapshot.child('text').value.toString() ?? 'nil',
        ),
      };
      setState(() {
        checkedTasks.add(item);
      });
    });
    checkedRef.onChildChanged.listen((event) {
      final checkedTask = checkedTasks
          .firstWhere((checkedTask) => checkedTask['id'] == event.snapshot.key);

      setState(() {
        checkedTask['checked'] = event.snapshot.child('checked').value;
        checkedTask['text'] = event.snapshot.child('text').value;
      });
    });

    checkedRef.onChildRemoved.listen((event) {
      setState(() {
        checkedTasks.removeWhere(
            (checkedTask) => checkedTask['id'] == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton(onSelected: (value) {
            if (value == item1) {
              taskRef.remove();
            } else if (value == item2) {
              checkedRef.remove();
            } else {
              taskRef.remove();
              checkedRef.remove();
            }
          }, itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: item1,
                child: Text(item1),
              ),
              PopupMenuItem(
                value: item2,
                child: Text(item2),
              ),
              PopupMenuItem(
                value: item3,
                child: Text(item3),
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

                    return TextField(
                      controller: task['controller'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: task['checked'] ?? false,
                          onChanged: (newVal) async {
                            await taskRef
                                .child(taskID)
                                .update({'checked': newVal});
                            if (newVal != null && newVal == true) {
                              await removeItem(taskID);
                              await addCheckedItem(
                                  task['controller'].text, true);
                            }
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
              if (checkedTasks.isNotEmpty) ...[
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
                  itemCount: checkedTasks.length,
                  itemBuilder: (context, index) {
                    final checkedTask = checkedTasks[index];
                    final checkedTaskID = checkedTask['id'];

                    return TextField(
                      controller: checkedTask['controller'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: checkedTask['checked'] ?? false,
                          onChanged: (newVal) async {
                            await checkedRef
                                .child(checkedTaskID)
                                .update({'checked': newVal});
                            if (newVal != null && newVal == false) {
                              await removeCheckedItem(checkedTaskID);

                              await addItem(
                                  checkedTask['controller'].text, false);
                            }
                            setState(() {});
                          },
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              removeCheckedItem(checkedTaskID);
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                      onChanged: (newVal) {
                        checkedRef
                            .child(checkedTaskID)
                            .update({'text': newVal});
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
