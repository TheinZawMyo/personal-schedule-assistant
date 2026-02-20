import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/timetable_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/timetable_entry.dart';
import '../home/widgets/timeline_view.dart';

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<TimetableEntry> _getEventsForDay(
    DateTime day,
    List<TimetableEntry> allEntries,
  ) {
    return allEntries.where((entry) {
      return isSameDay(entry.startTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(timetableProvider);
    final selectedEntries = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      allEntries,
    );
    selectedEntries.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar View')),
      body: Column(
        children: [
          TableCalendar<TimetableEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _getEventsForDay(day, allEntries),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.primary),
                ),
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                LucideIcons.chevronLeft,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              rightChevronIcon: Icon(
                LucideIcons.chevronRight,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              formatButtonTextStyle: const TextStyle(color: AppColors.primary),
              formatButtonDecoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.primary),
                ),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: selectedEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No activities for this day',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    )
                  : TimelineView(entries: selectedEntries),
            ),
          ),
        ],
      ),
    );
  }
}
