import 'package:hive/hive.dart';

part 'timetable_entry.g.dart';

@HiveType(typeId: 0)
enum ActivityCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  health,
  @HiveField(3)
  study,
  @HiveField(4)
  other,
}

@HiveType(typeId: 1)
enum RepeatCycle {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 2)
class TimetableEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String? description;

  @HiveField(3)
  late DateTime startTime;

  @HiveField(4)
  late DateTime endTime;

  @HiveField(5)
  late ActivityCategory category;

  @HiveField(6)
  late int reminderMinutes; // 5, 10, 15, 30

  @HiveField(7)
  late RepeatCycle repeat;

  @HiveField(8)
  late List<int>? customDays; // 1-7 (Mon-Sun)

  @HiveField(9)
  late bool isCompleted;

  @HiveField(10)
  late DateTime createdAt;

  TimetableEntry({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.reminderMinutes = 10,
    this.repeat = RepeatCycle.none,
    this.customDays,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TimetableEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ActivityCategory? category,
    int? reminderMinutes,
    RepeatCycle? repeat,
    List<int>? customDays,
    bool? isCompleted,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      repeat: repeat ?? this.repeat,
      customDays: customDays ?? this.customDays,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
