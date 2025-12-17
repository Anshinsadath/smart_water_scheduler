import 'package:hive/hive.dart';
part 'water_schedule.g.dart';

@HiveType(typeId: 1)
class WaterSchedule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String plantName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String reminderTime;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int notificationId;

  WaterSchedule({
    required this.id,
    required this.plantName,
    required this.amount,
    required this.reminderTime,
    required this.createdAt,
    required this.notificationId,
  });
}

