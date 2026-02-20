import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/timetable_entry.dart';
import '../../../providers/timetable_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../../services/haptic_service.dart';
import '../../entry/entry_form_screen.dart';

class TimelineView extends ConsumerWidget {
  final List<TimetableEntry> entries;

  const TimelineView({super.key, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildTimelineItem(
          context,
          ref,
          entry,
          index == entries.length - 1,
        );
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    WidgetRef ref,
    TimetableEntry entry,
    bool isLast,
  ) {
    final startTimeStr = DateFormat('HH:mm').format(entry.startTime);
    final endTimeStr = DateFormat('HH:mm').format(entry.endTime);
    final categoryColor = AppColors.getCategoryColor(entry.category.name);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          Column(
            children: [
              Text(
                startTimeStr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endTimeStr,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Connector & Card column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  HapticService.success(ref);
                  ref.read(timetableProvider.notifier).deleteEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${entry.title} deleted')),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.trash2,
                    color: Colors.redAccent,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticService.selection(ref);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EntryFormScreen(entry: entry),
                      ),
                    );
                  },
                  child:
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(
                                  color: categoryColor,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: entry.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: entry.isCompleted,
                                      onChanged: (val) {
                                        HapticService.selection(ref);
                                        ref
                                            .read(timetableProvider.notifier)
                                            .toggleComplete(entry.id);
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                                if (entry.description != null &&
                                    entry.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.description!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                CategoryBadge(
                                  label: entry.category.name,
                                  color: categoryColor,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.1, end: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
