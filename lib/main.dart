import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'firebase_options.dart';
import 'models/water_schedule.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 Timezone → NOT supported on Web
  if (!kIsWeb) {
    tzdata.initializeTimeZones();
  }

  // 🔥 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 📦 Hive (Web-safe with hive_flutter)
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(WaterScheduleAdapter());
  }

  final box = await Hive.openBox<WaterSchedule>('schedules');

  // 🔁 Restore cloud data (Firestore works on Web)
  
  

  // 🔔 Notifications → HARD RULE: DISABLE ON WEB
  if (!kIsWeb) {
    await NotificationService.init();
  }

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
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home:  AuthGate(),
    );
  }
}
