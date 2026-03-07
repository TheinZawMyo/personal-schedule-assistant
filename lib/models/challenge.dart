import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'challenge.g.dart';

@HiveType(typeId: 4)
class Challenge extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String? description;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late DateTime endDate;

  @HiveField(5)
  late bool isSpecificTime; // True for specific time, False for "every time" (all day)

  @HiveField(6)
  late DateTime? specificTime; // Only used if isSpecificTime is true

  @HiveField(7)
  late bool isActive;

  @HiveField(8)
  late DateTime createdAt;

  Challenge({
    String? id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isSpecificTime = false,
    this.specificTime,
    this.isActive = true,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSpecificTime,
    DateTime? specificTime,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isSpecificTime: isSpecificTime ?? this.isSpecificTime,
      specificTime: specificTime ?? this.specificTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
