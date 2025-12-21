import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/water_schedule.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<WaterSchedule>('schedules');

    if (box.isEmpty) {
      return const Center(child: Text("No logs yet"));
    }

    final schedules = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (_, i) {
        final s = schedules[i];
        return ListTile(
          leading: const Icon(Icons.water_drop),
          title: Text(s.plantName),
          subtitle: Text(
            "Amount: ${s.amount}ml • Time: ${s.reminderTime}",
          ),
          trailing: Text(
            "${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}",
          ),
        );
      },
    );
  }
}
