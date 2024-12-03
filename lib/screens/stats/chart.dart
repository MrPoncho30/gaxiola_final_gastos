import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  final List<String> categories;
  final List<double> expenses;
  final List<IconData> categoryIcons;

  const MyChart({
    super.key,
    required this.categories,
    required this.expenses,
    required this.categoryIcons,
  });

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      mainBarData(),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
            transform: const GradientRotation(pi / 40),
          ),
          width: 20,
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 5, color: Colors.grey.shade300))
    ]);
  }

  List<BarChartGroupData> showingGroups() {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < widget.categories.length; i++) {
      groups.add(makeGroupData(i, widget.expenses[i]));
    }
    return groups;
  }

  BarChartData mainBarData() {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: getTiles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }

  Widget getTiles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    Widget icon;

    if (value < widget.categoryIcons.length) {
      icon = Icon(
        widget.categoryIcons[value.toInt()],
        color: Colors.grey,
        size: 30,
      );
    } else {
      return const SizedBox();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: icon,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    // Mostrar las cantidades en el eje Y
    String text = value.toStringAsFixed(0); // Formatear como número entero

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}
