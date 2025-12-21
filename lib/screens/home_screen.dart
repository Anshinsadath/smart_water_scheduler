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

  final List<Widget> _screens = const [
    DashboardView(),
    AddScheduleScreen(),
    LogsScreen(),
  ];

  /// 🔤 Logged-in user name (always fresh)
  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email ?? "User";
  }

  @override
  void initState() {
    super.initState();
    _restoreFromCloud();
  }

  /// 🔁 Restore schedules from Firestore → Hive
  /// ✅ Runs ONLY ONCE per login
  Future<void> _restoreFromCloud() async {
    if (_synced) return;

    final box = Hive.box<WaterSchedule>('schedules');
    final cloudSchedules = await FirestoreService.fetchAll();

    for (final schedule in cloudSchedules) {
      box.put(schedule.id, schedule);
    }

    _synced = true;

    if (mounted) {
      setState(() {});
    }
  }

  /// 🔐 Logout
  /// ✅ Clear local cache
  /// ✅ Firebase sign out
  /// ✅ AuthGate will redirect automatically
  Future<void> _logout() async {
    await Hive.box<WaterSchedule>('schedules').clear();
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
            Text(
              "Hello, $userName",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          /// 👤 Profile
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );

              /// 🔁 Refresh ONLY if name changed
              if (updated == true && mounted) {
                setState(() {});
              }
            },
          ),

          /// 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
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
