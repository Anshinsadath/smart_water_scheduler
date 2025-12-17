import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'firebase_options.dart';
import 'models/water_schedule.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 Timezone
  tzdata.initializeTimeZones();

  // 🔥 Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🔐 Anonymous Auth
    await AuthService.signInAnonymously();
  } catch (e) {
    // Firebase initialization failed, continue without it
    print('Firebase initialization failed: $e');
  }

  // 📦 Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(WaterScheduleAdapter());
  }
  await Hive.openBox<WaterSchedule>('schedules');

  // 🔔 Notifications
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Water Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
