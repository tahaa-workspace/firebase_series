import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/navigation.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  List projects = [
    {
      'title': 'Task Manager',
      'onTap': () {
        Get.toNamed(Routes.boards);
      },
    },
    {
      'title': 'Installed Apps',
      'onTap': () {
        Get.toNamed(Routes.installedApps);
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

              return ElevatedButton(
                onPressed: projects[index]['onTap'],
                child: Text(
                  projects[index]['title'],
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }),
      ),
    );
  }
}
