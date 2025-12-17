import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_schedule.dart';

class HiveService {
  static const String schedulesBoxName = 'waterBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // register adapter if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WaterScheduleAdapter());
    }

    if (!Hive.isBoxOpen(schedulesBoxName)) {
      await Hive.openBox<WaterSchedule>(schedulesBoxName);
    }
  }
}
