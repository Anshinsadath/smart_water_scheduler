import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'water_schedule.g.dart';

@HiveType(typeId: 0)
class WaterSchedule {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String plantName;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final String reminderTime; // HH:mm

  @HiveField(4)
  final DateTime createdAt;

  WaterSchedule({
    required this.id,
    required this.plantName,
    required this.amount,
    required this.reminderTime,
    required this.createdAt,
  });

  /// 🔥 Firestore → Model
  factory WaterSchedule.fromMap(Map<String, dynamic> map, String id) {
    return WaterSchedule(
      id: id,
      plantName: map['plantName'],
      amount: map['amount'],
      reminderTime: map['reminderTime'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'plantName': plantName,
      'amount': amount,
      'reminderTime': reminderTime,
      'createdAt': Timestamp.fromDate(createdAt), // ✅ FIX
    };
  }
}
