import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/water_schedule.dart';
import '../services/firestore_service.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  // ✅ CONTROLLERS
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // ✅ TIME
  TimeOfDay? _selectedTime;

  // ⏰ PICK TIME
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // 💾 SAVE
  Future<void> _saveSchedule() async {
    if (_plantController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    final schedule = WaterSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantName: _plantController.text.trim(),
      amount: int.parse(_amountController.text),
      reminderTime:
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
      createdAt: DateTime.now(),
    );

    // 🔥 FIRESTORE (source of truth)
    await FirestoreService.saveSchedule(schedule);

    // 📦 HIVE (local cache)
    Hive.box<WaterSchedule>('schedules').put(schedule.id, schedule);

    // 🧹 CLEAR
    _plantController.clear();
    _amountController.clear();
    setState(() => _selectedTime = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Schedule saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _plantController,
            decoration: const InputDecoration(labelText: "Plant name"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Water amount (ml)"),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveSchedule,
            child: const Text("Save Schedule"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _plantController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
