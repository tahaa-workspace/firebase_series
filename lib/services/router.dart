import 'package:firebase_series/projects/task_manager/boards.dart';
import 'package:get/get.dart';

import '../projects/installed_apps/installed_apps.dart';
import '../projects/projects.dart';
import '../projects/task_manager/tasks.dart';
import 'navigation.dart';

class AppRouter {
  static List<GetPage<dynamic>>? pages = [
    GetPage(
      name: Routes.projects,
      page: () => const Projects(),
    ),
    GetPage(
      name: Routes.boards,
      page: () => const Boards(),
    ),
    GetPage(
      name: Routes.taskManager,
      page: () => const TaskManager(),
    ),
    GetPage(
      name: Routes.installedApps,
      page: () => const InstalledAppsScreen(),
    ),
  ];
}
