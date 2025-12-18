import 'package:hive/hive.dart';

part 'water_schedule.g.dart';

@HiveType(typeId: 1)
class WaterSchedule {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String plantName;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final DateTime reminderTime;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int notificationId;

  WaterSchedule({
    required this.id,
    required this.plantName,
    required this.amount,
    required this.reminderTime,
    required this.createdAt,
    required this.notificationId,
  });

  /// 🔥 Firestore → Model
  factory WaterSchedule.fromMap(Map<String, dynamic> map) {
    return WaterSchedule(
      id: map['id'],
      plantName: map['plantName'],
      amount: map['amount'],
      reminderTime: DateTime.parse(map['reminderTime']),
      createdAt: DateTime.parse(map['createdAt']),
      notificationId: map['notificationId'],
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantName': plantName,
      'amount': amount,
      'reminderTime': reminderTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
    };
  }
}
