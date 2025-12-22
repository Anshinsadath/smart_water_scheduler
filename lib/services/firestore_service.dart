import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/water_schedule.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _ref() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('schedules');
  }

  static Future<List<WaterSchedule>> fetchAll() async {
    final snap = await _ref()
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => WaterSchedule.fromMap(d.data(), d.id))
        .toList();
  }

  static Future<void> saveSchedule(WaterSchedule s) async {
    await _ref().doc(s.id).set(s.toMap());
  }
}

