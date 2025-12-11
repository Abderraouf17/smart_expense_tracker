import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    final Map<String, double> categoryTotals = {};
    for (var exp in expenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0) + exp.amount;
    }

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categoryTotals.isEmpty
            ? const Center(child: Text("No data to display yet."))
            : Column(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: categoryTotals.entries.map((entry) {
                          final percent = ((entry.value / total) * 100)
                              .toStringAsFixed(1);
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${entry.key}\n$percent%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...categoryTotals.entries.map(
                    (entry) => ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(entry.key),
                      trailing: Text(entry.value.toStringAsFixed(2)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
