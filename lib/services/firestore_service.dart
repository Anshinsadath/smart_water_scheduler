import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_schedule.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 SAVE TO CLOUD
  static Future<void> saveSchedule(WaterSchedule s) async {
    try {
      await _db.collection('schedules').doc(s.id).set({
        'id': s.id,
        'plantName': s.plantName,
        'amount': s.amount,
        'reminderTime': s.reminderTime,
        'createdAt': s.createdAt.toIso8601String(),
        'notificationId': s.notificationId,
      });
    } catch (e) {
      // Firebase not available, skip cloud save
      print('Firestore save failed: $e');
    }
  }

  // ❌ DELETE FROM CLOUD
  static Future<void> deleteSchedule(String id) async {
    try {
      await _db.collection('schedules').doc(id).delete();
    } catch (e) {
      // Firebase not available, skip cloud delete
      print('Firestore delete failed: $e');
    }
  }

  // 🔁 RESTORE FROM CLOUD
  static Future<List<WaterSchedule>> fetchAll() async {
    try {
      final snapshot = await _db.collection('schedules').get();

      final List<WaterSchedule> schedules = [];

      for (final doc in snapshot.docs) {
        final d = doc.data();

        schedules.add(
          WaterSchedule(
            id: d['id'],
            plantName: d['plantName'],
            amount: (d['amount'] as num).toDouble(),
            reminderTime: d['reminderTime'],
            createdAt: DateTime.parse(d['createdAt']),
            notificationId: d['notificationId'],
          ),
        );
      }

      return schedules;
    } catch (e) {
      // Firebase not available, return empty list
      print('Firestore fetch failed: $e');
      return [];
    }
  }
}
