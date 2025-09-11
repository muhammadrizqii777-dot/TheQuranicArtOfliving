// lib/habit_model.dart

import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late List<bool> isDone;

  @HiveField(2)
  late DateTime startDate;

  @HiveField(3)
  late int duration;
}