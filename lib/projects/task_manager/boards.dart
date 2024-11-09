import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_series/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Boards extends StatefulWidget {
  const Boards({super.key});

  @override
  State<Boards> createState() => _BoardsState();
}

class _BoardsState extends State<Boards> {
  DatabaseReference boardsRef = FirebaseDatabase.instance.ref().child('boards');
  List boards = [];
  TextEditingController boardNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listenToBoards();
  }

  void listenToBoards() {
    boardsRef.onChildAdded.listen((event) {
      final board = {
        'id': event.snapshot.key,
        'name': event.snapshot.child('name').value,
      };

      setState(() {
        boards.add(board);
      });
    });

    boardsRef.onChildChanged.listen((event) {
      final board =
          boards.firstWhere((board) => board['id'] == event.snapshot.key);

      setState(() {
        board['name'] = event.snapshot.child('name').value;
      });
    });

    boardsRef.onChildRemoved.listen((event) {
      setState(() {
        boards.removeWhere((board) => board['id'] == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boards'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GridView.builder(
            itemCount: boards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              childAspectRatio: 2,
              crossAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              final boardID = boards[index]['id'];
              final boardName = boards[index]['name'];

              return GestureDetector(
                onTap: () {
                  navigateToTasksPage(boardID, boardName);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            boardName.isNotEmpty && boardName != null
                                ? boardName
                                : 'Untitled',
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: boardName.isNotEmpty
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: boardName.isNotEmpty
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          InkWell(
                            onTap: () {
                              deleteBoard(boardID);
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          DatabaseReference newBoardRef = boardsRef.push();
          String? newBoardKey = newBoardRef.key;

          print('newboardKey = $newBoardKey');

          String bdName = '';

          navigateToTasksPage(newBoardKey, bdName);

          if (bdName.isNotEmpty) {
            addBoard(bdName);
          }
        },
        label: const Row(
          children: [
            Text(
              'Create',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.add,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteBoard(boardID) => boardsRef.child(boardID).remove();

  void addBoard(String boardName) async {
    await boardsRef.push().set(
      {
        'name': boardName,
        'tasks': {},
      },
    );
  }

  navigateToTasksPage(boardID, boardName) {
    Get.toNamed(Routes.taskManager, arguments: {
      'boardID': boardID,
      'boardName': boardName,
    })!
        .then((value) {});
  }
}
