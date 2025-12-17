import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/water_schedule.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<WaterSchedule>('schedules');

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<WaterSchedule> box, _) {
          final schedules = box.values.toList();

          final todayCount = schedules.where((s) {
            final now = DateTime.now();
            return s.createdAt.year == now.year &&
                s.createdAt.month == now.month &&
                s.createdAt.day == now.day;
          }).length;

          final nextSchedule = schedules.isEmpty
              ? null
              : schedules.reduce((a, b) =>
                  a.reminderTime.compareTo(b.reminderTime) < 0 ? a : b);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StatCard(
                  title: "Total schedules",
                  value: schedules.length.toString(),
                  icon: Icons.list,
                ),
                _StatCard(
                  title: "Today",
                  value: todayCount.toString(),
                  icon: Icons.today,
                ),
                _StatCard(
                  title: "Next watering",
                  value: nextSchedule?.plantName ?? "—",
                  icon: Icons.alarm,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Schedules Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (_, i) {
                      final s = schedules[i];
                      return ListTile(
                        leading: const Icon(Icons.local_florist),
                        title: Text(s.plantName),
                        subtitle: Text(
                            "${s.amount} ml at ${s.reminderTime}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
