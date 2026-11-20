import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';

class MassApp extends StatelessWidget {
  const MassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPlaceholder(),
        AppRoutes.teacherDashboard: (context) =>
            const Scaffold(body: Center(child: Text('Teacher Dashboard'))),
        AppRoutes.studentDashboard: (context) =>
            const Scaffold(body: Center(child: Text('Student Dashboard'))),
      },
    );
  }
}

class LoginPlaceholder extends StatelessWidget {
  const LoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('MASS Login Screen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.teacherDashboard);
              },
              child: const Text('Test Teacher Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.studentDashboard);
              },
              child: const Text('Test Student Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
// do first commit
// do second commit
// third commit
