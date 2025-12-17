import 'package:hive/hive.dart';
import '../models/water_schedule.dart';

class AnalyticsService {
  static Box<WaterSchedule> get _box =>
      Hive.box<WaterSchedule>('schedules');

  // 1️⃣ Total schedules
  static int totalSchedules() {
    return _box.length;
  }

  // 2️⃣ Today schedules
  static int todaySchedules() {
    final today = DateTime.now();
    return _box.values.where((s) {
      return s.createdAt.year == today.year &&
          s.createdAt.month == today.month &&
          s.createdAt.day == today.day;
    }).length;
  }

  // 3️⃣ Next reminder
  static String nextReminder() {
    if (_box.isEmpty) return "No reminders";

    final now = DateTime.now();

    final upcoming = _box.values.toList()
      ..sort((a, b) {
        return a.reminderTime.compareTo(b.reminderTime);
      });

    return upcoming.first.reminderTime;
  }

  // 4️⃣ Amount per plant
  static Map<String, double> waterPerPlant() {
    final Map<String, double> map = {};

    for (final s in _box.values) {
      map[s.plantName] =
          (map[s.plantName] ?? 0) + s.amount;
    }

    return map;
  }
}
