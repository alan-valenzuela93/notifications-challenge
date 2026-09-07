import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/config/app_config.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  AppConfig.validate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notificaciones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationsPage(),
    );
  }
}
