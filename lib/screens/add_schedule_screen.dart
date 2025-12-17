import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/water_schedule.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _plantController = TextEditingController();
  final _amountController = TextEditingController();
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _saveSchedule() async {
    if (_plantController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ SAFE, STABLE notification id
    final notificationId = id.hashCode & 0x7fffffff;

    final schedule = WaterSchedule(
      id: id,
      plantName: _plantController.text.trim(),
      amount: double.parse(_amountController.text),
      reminderTime:
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
      createdAt: DateTime.now(),
      notificationId: notificationId,
    );

    // 📦 LOCAL SAVE
    final box = Hive.box<WaterSchedule>('schedules');
    await box.put(id, schedule);

    // ☁️ CLOUD BACKUP
    await FirestoreService.saveSchedule(schedule);

    // 🔔 NOTIFICATIONS (MOBILE ONLY)
    if (!kIsWeb) {
      await NotificationService.scheduleDaily(
        id: notificationId,
        title: "Water Reminder",
        body:
            "Time to water ${schedule.plantName} (${schedule.amount} ml)",
        hour: _selectedTime!.hour,
        minute: _selectedTime!.minute,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Schedule Saved")),
    );

    setState(() {
      _plantController.clear();
      _amountController.clear();
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _plantController,
              decoration: const InputDecoration(labelText: "Plant Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount (ml)"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? "No time selected"
                        : "Time: ${_selectedTime!.format(context)}",
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text("Pick Time"),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: const Text("Save Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}
