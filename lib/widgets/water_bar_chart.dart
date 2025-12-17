import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WaterBarChart extends StatelessWidget {
  final Map<String, double> data;

  const WaterBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final entries = data.entries.toList();

    return BarChart(
      BarChartData(
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value,
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(entries[value.toInt()].key);
              },
            ),
          ),
        ),
      ),
    );
  }
}
