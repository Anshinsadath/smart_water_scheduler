import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_schedule.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<WaterSchedule>('schedules').listenable(),
      builder: (context, Box<WaterSchedule> box, _) {
        final schedules = box.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (schedules.isEmpty) {
          return const Center(child: Text("No schedules yet"));
        }

        final now = DateTime.now();

        final todaySchedules = schedules.where((s) {
          return s.createdAt.year == now.year &&
              s.createdAt.month == now.month &&
              s.createdAt.day == now.day;
        }).toList();

        final nextReminder = _getNextReminder(schedules);

        final Map<String, int> plantCount = {};
        for (var s in schedules) {
          plantCount[s.plantName] = (plantCount[s.plantName] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _statCard("Total", schedules.length.toString(), Icons.calendar_month),
                  _statCard("Today", todaySchedules.length.toString(), Icons.today),
                ],
              ),
              const SizedBox(height: 10),

              _wideStatCard(
                "Next Reminder",
                nextReminder ?? "No upcoming reminder",
                Icons.alarm,
              ),

              const SizedBox(height: 25),

              const Text("Schedules per Plant",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    barGroups: _buildBarGroups(plantCount),
                    titlesData: _barTitles(plantCount),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text("Plant Distribution",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(plantCount),
                    centerSpaceRadius: 40,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text("Recent Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...schedules.take(5).map(
                (s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.water_drop),
                    title: Text(s.plantName),
                    subtitle: Text(
                      "Amount: ${s.amount} ml • Time: ${s.reminderTime}",
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// HELPERS

  static String? _getNextReminder(List<WaterSchedule> schedules) {
    final now = DateTime.now();
    DateTime? nextTime;
    String? plant;

    for (var s in schedules) {
      final parts = s.reminderTime.split(":");
      final t = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final candidate = t.isAfter(now) ? t : t.add(const Duration(days: 1));

      if (nextTime == null || candidate.isBefore(nextTime!)) {
        nextTime = candidate;
        plant = s.plantName;
      }
    }

    if (nextTime == null) return null;
    return "$plant at ${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}";
  }

  static Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  static Widget _wideStatCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  static List<BarChartGroupData> _buildBarGroups(Map<String, int> plantCount) {
    int i = 0;
    return plantCount.entries.map((e) {
      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }

  static FlTitlesData _barTitles(Map<String, int> plantCount) {
    final names = plantCount.keys.toList();
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= names.length) return const SizedBox();
            return Text(names[value.toInt()], style: const TextStyle(fontSize: 10));
          },
        ),
      ),
    );
  }

  static List<PieChartSectionData> _buildPieSections(
      Map<String, int> plantCount) {
    final total = plantCount.values.fold<int>(0, (a, b) => a + b);

    return plantCount.entries.map((e) {
      final percent = (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: "${percent.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
