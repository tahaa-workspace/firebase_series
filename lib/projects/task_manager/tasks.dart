import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  DatabaseReference boardsRef = FirebaseDatabase.instance
      .ref()
      .child('boards/${Get.arguments['boardID']}');

  DatabaseReference taskRef = FirebaseDatabase.instance
      .ref()
      .child('boards/${Get.arguments['boardID']}/tasks');

  String boardID = Get.arguments['boardID'];
  String boardName = Get.arguments['boardName'];

  TextEditingController titleController = TextEditingController();

  List tasks = [];

  List get pendingTasks =>
      tasks.where((task) => task['checked'] == false).toList();

  List get checkedTasks =>
      tasks.where((task) => task['checked'] == true).toList();

  String item1 = 'Untick all tasks', item2 = 'Remove all';

  @override
  void initState() {
    super.initState();
    titleController.text = boardName;
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
      final task = {
        'id': event.snapshot.key,
        'text': event.snapshot.child('text').value,
        'controller': TextEditingController(
          text: event.snapshot.child('text').value.toString() ?? '',
        ),
        'title': event.snapshot.child('title').value,
        'checked': event.snapshot.child('checked').value,
      };

      setState(() {
        tasks.add(task);
      });
    });

    taskRef.onChildChanged.listen((event) {
      final task = tasks.firstWhere((task) => task['id'] == event.snapshot.key,
          orElse: () => null);

      setState(() {
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
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == item2) {
                taskRef.remove();
              }

              if (value == item1) {
                for (Map task in checkedTasks) {
                  taskRef.child(task['id']).update({'checked': false});
                }
              }
            },
            itemBuilder: (context) {
              return [
                if (checkedTasks.isNotEmpty) ...[
                  PopupMenuItem(
                    value: item1,
                    child: Text(item1),
                  ),
                ],
                PopupMenuItem(
                  value: item2,
                  child: Text(item2),
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
                TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 22),
                  cursorColor: Colors.black,
                  cursorWidth: 1.5,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 22),
                    border: InputBorder.none,
                  ),
                  onChanged: (newValue) {
                    updateTitle(newValue);
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
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
                GestureDetector(
                  onTap: () {
                    addItem('', false);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Task'),
                  ),
                ),
                if (checkedTasks.isNotEmpty) ...[
                  const Divider(),
                  Text(
                    '${checkedTasks.length} Checked Tasks',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: checkedTasks.length,
                  itemBuilder: (context, index) {
                    final finishedTask = checkedTasks[index];
                    final finishedTaskID = finishedTask['id'];

                    return TextField(
                      controller: finishedTask['controller'],
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough),
                      decoration: InputDecoration(
                        prefixIcon: Checkbox(
                          activeColor: Colors.black45,
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

  Future<void> updateTitle(String newValue) => boardsRef.update(
        {'name': newValue},
      );
}
