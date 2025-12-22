import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/water_schedule.dart';
import '../services/firestore_service.dart';
import 'dashboard_view.dart';
import 'add_schedule_screen.dart';
import 'logs_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _synced = false;
  String? _lastUid;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardView(), // ❗ NOT const
      const AddScheduleScreen(),
      const LogsScreen(),
    ];

    _listenAuthAndRestore();
  }

  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email ?? "User";
  }

  /// 🔐 Listen to auth changes
  void _listenAuthAndRestore() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;

      if (_lastUid != user.uid) {
        _synced = false;
        _lastUid = user.uid;
      }

      if (!_synced) {
        await _restoreFromCloud();
      }
    });
  }

  /// 🔁 Restore schedules from Firestore → Hive
  Future<void> _restoreFromCloud() async {
    final box = Hive.box<WaterSchedule>('schedules');

    final cloudSchedules = await FirestoreService.fetchAll();

    for (final s in cloudSchedules) {
      box.put(s.id, s);
    }

    _synced = true;
    if (mounted) setState(() {});
  }

  /// 🔐 Logout
  Future<void> _logout() async {
    await Hive.box<WaterSchedule>('schedules').clear();
    _synced = false;
    _lastUid = null;
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Water Scheduler'),
            Text("Hello, $userName", style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated == true && mounted) setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logs'),
        ],
      ),
    );
  }
}
