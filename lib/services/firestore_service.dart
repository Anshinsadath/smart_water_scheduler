import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_schedule.dart';

class FirestoreService {
  static final _ref =
      FirebaseFirestore.instance.collection('schedules');

  /// Fetch all schedules from cloud
  static Future<List<WaterSchedule>> fetchAll() async {
    final snap = await _ref.get();

    return snap.docs
        .map<WaterSchedule>((doc) =>
            WaterSchedule.fromMap(doc.data()))
        .toList();
  }

  /// Save schedule to cloud
  static Future<void> saveSchedule(WaterSchedule schedule) async {
    await _ref.doc(schedule.id).set(schedule.toMap());
  }

  /// Delete schedule
  static Future<void> deleteSchedule(String id) async {
    await _ref.doc(id).delete();
  }
}
