import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_schedule.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';





class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<WaterSchedule>('schedules');

    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<WaterSchedule> b, _) {
          if (b.values.isEmpty) {
            return const Center(child: Text("No schedules yet"));
          }

          final schedules = b.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, i) {
              final s = schedules[i];
              return Card(
                child: ListTile(
                  title: Text(s.plantName),
                  subtitle: Text(
                    "Amount: ${s.amount} ml • Time: ${s.reminderTime}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
  // 1️⃣ Cancel notification
  await NotificationService.cancel(s.notificationId);

  // 2️⃣ Delete local
  await Hive.box<WaterSchedule>('schedules').delete(s.id);

  // 3️⃣ Delete cloud
  await FirestoreService.deleteSchedule(s.id);

  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Schedule deleted")),
    );
  } catch (e) {
    // Context might be invalid, ignore
  }
},

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
