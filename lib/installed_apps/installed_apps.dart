import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppsScreen extends StatefulWidget {
  const InstalledAppsScreen({super.key});

  @override
  createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  List<AppInfo> _paymentApps = [];

  @override
  void initState() {
    super.initState();
    _getPaymentApps();
  }

  Future<void> _getPaymentApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
      true,
      true,
      "",
    );
    List<AppInfo> paymentApps = [];

    for (AppInfo app in apps) {
      if (await _isPaymentApp(app.packageName)) {
        paymentApps.add(app);
      }
    }

    setState(() {
      _paymentApps = paymentApps;
    });
  }

  Future<bool> _isPaymentApp(String packageName) async {
    return packageName.contains('pay') ||
        packageName.contains('upiapp') ||
        packageName.contains('paisa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upi Apps'),
      ),
      body: ListView.builder(
        itemCount: _paymentApps.length,
        itemBuilder: (context, index) {
          AppInfo app = _paymentApps[index];

          return ListTile(
            onTap: () async {
              openApp(app.packageName);
            },
            leading: buildAppIcon(app),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${app.name}\n${app.packageName}'),
                // if (app.icon != null)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildAppIcon(AppInfo app) {
    if (app.icon != null) {
      return Image.memory(
        app.icon!,
        width: 32.0,
        height: 32.0,
        errorBuilder: (context, error, stackTrace) {
          print('Error displaying icon: $error');
          return const Icon(Icons.payment);
        },
      );
    } else {
      return const Icon(Icons.error);
    }
  }

  void openApp(packageName) {
    InstalledApps.startApp(packageName);
  }

  void getAppInfo(packageName) async {
    InstalledApps.getAppInfo(packageName);
  }
}
