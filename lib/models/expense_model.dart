import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category; // e.g. 'food', 'transport', 'shopping', 'other'

  ExpenseModel({
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}
