import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/timetable_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timetable_entry.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(timetableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(context, entries),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Category Breakdown'),
            const SizedBox(height: 16),
            _buildCategoryPieChart(context, entries),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Weekly Performance'),
            const SizedBox(height: 16),
            _buildWeeklyBarChart(context, entries),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, List<TimetableEntry> entries) {
    final totalCompleted = entries.where((e) => e.isCompleted).length;
    final completionRate = entries.isEmpty
        ? 0
        : (totalCompleted / entries.length * 100).toInt();

    return Row(
      children: [
        _buildStatCard(
          context,
          'Total Tasks',
          entries.length.toString(),
          LucideIcons.listTodo,
          AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          'Completion',
          '$completionRate%',
          LucideIcons.checkCircle2,
          AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    List<TimetableEntry> entries,
  ) {
    if (entries.isEmpty) return const Center(child: Text('No data available'));

    final Map<ActivityCategory, int> counts = {};
    for (var cat in ActivityCategory.values) {
      counts[cat] = entries.where((e) => e.category == cat).length;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: ActivityCategory.values.map((cat) {
            final count = counts[cat] ?? 0;
            final percentage = (count / entries.length * 100);
            return PieChartSectionData(
              color: AppColors.getCategoryColor(cat.name),
              value: count.toDouble(),
              title: percentage > 5 ? '${percentage.toInt()}%' : '',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(
    BuildContext context,
    List<TimetableEntry> entries,
  ) {
    if (entries.isEmpty) return const Center(child: Text('No data available'));

    // Get the last 7 days including today
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    final List<BarChartGroupData> barGroups = [];
    double maxCount = 5; // Default max for scaling

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final dayEntries = entries.where((e) {
        return e.startTime.year == day.year &&
            e.startTime.month == day.month &&
            e.startTime.day == day.day;
      });

      final completedCount = dayEntries.where((e) => e.isCompleted).length;
      if (completedCount > maxCount) maxCount = completedCount.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: completedCount.toDouble(),
              color: AppColors.primary,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxCount,
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} tasks',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= last7Days.length) {
                    return const Text('');
                  }
                  final day = last7Days[index];
                  final label = DateFormat('E').format(day)[0]; // First letter
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
