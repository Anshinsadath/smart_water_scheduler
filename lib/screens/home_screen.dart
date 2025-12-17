import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/water_schedule.dart';
import '../services/firestore_service.dart';
import 'dashboard_view.dart';
import 'add_schedule_screen.dart';
import 'logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    DashboardView(), // ✅ USE ANALYTICS DASHBOARD
    AddScheduleScreen(),
    LogsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _restoreFromCloud();
  }

  Future<void> _restoreFromCloud() async {
    final box = Hive.box<WaterSchedule>('schedules');
    final cloudSchedules = await FirestoreService.fetchAll();

    for (final s in cloudSchedules) {
      box.put(s.id, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
