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

  List get pendingTasks =>
      tasks.where((task) => task['checked'] == false).toList();

  List get finishedTasks =>
      tasks.where((task) => task['checked'] == true).toList();

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
          // 'focus': FocusNode(),
        };
        tasks.add(task);
      });
    });

    taskRef.onChildChanged.listen((event) {
      setState(() {
        final task = tasks.firstWhere(
            (task) => task['id'] == event.snapshot.key,
            orElse: () => null);
        task['checked'] = event.snapshot.child('checked').value;
        task['text'] = event.snapshot.child('text').value;
        task['controller'].text = event.snapshot.child('text').value.toString();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (Map task in pendingTasks)
                  TextField(
                    controller: task['controller'],
                    decoration: InputDecoration(
                      prefixIcon: Checkbox(
                        value: task['checked'] ?? false,
                        onChanged: (newVal) async {
                          await toggleChecked(task['id'], newVal ?? false);
                        },
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            removeItem(task['id']);
                          });
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                    ),
                    onChanged: (newVal) {
                      setState(() {
                        taskRef
                            .child(task['id'])
                            .update({'text': task['controller'].text});
                      });
                    },
                  ),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: pendingTasks.length,
                //     itemBuilder: (context, index) {
                //       final task = pendingTasks[index];
                //       final taskID = pendingTasks[index]['id'];
                //
                //       return TextField(
                //         controller: task['controller'],
                //         decoration: InputDecoration(
                //           prefixIcon: Checkbox(
                //             value: task['checked'] ?? false,
                //             onChanged: (newVal) async {
                //               await toggleChecked(taskID, newVal ?? false);
                //
                //               setState(() {});
                //             },
                //           ),
                //           suffixIcon: IconButton(
                //             onPressed: () {
                //               setState(() {
                //                 removeItem(taskID);
                //               });
                //             },
                //             icon: const Icon(Icons.cancel),
                //           ),
                //         ),
                //         onChanged: (newVal) {
                //           taskRef.child(taskID).update({'text': newVal});
                //         },
                //       );
                //     },
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    addItem('', false);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Task'),
                  ),
                ),
                if (finishedTasks.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Completed Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: finishedTasks.length,
                  itemBuilder: (context, index) {
                    final finishedTask = finishedTasks[index];
                    final finishedTaskID = finishedTask['id'];

                    return TextField(
                      controller: finishedTask['controller'],
                      // focusNode: finishedTask['focus'],
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          value: finishedTask['checked'] ?? false,
                          onChanged: (newVal) async {
                            await toggleChecked(
                                finishedTaskID, newVal ?? false);

                            setState(() {});
                          },
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              removeItem(finishedTaskID);
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                      onChanged: (newVal) {
                        taskRef.child(finishedTaskID).update({'text': newVal});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
