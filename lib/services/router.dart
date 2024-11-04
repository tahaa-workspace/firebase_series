import 'package:firebase_series/task_manager/tasks.dart';
import 'package:get/get.dart';

import '../installed_apps/installed_apps.dart';
import '../projects.dart';
import 'navigation.dart';

class AppRouter {
  static List<GetPage<dynamic>>? pages = [
    GetPage(
      name: Routes.projects,
      page: () => const Projects(),
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
