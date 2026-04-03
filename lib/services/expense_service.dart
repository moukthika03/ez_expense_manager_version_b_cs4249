import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

/// Singleton service that wraps the Hive box for expenses.
/// Call [ExpenseService.init()] once in main() before runApp().
class ExpenseService {
  static const String _boxName = 'expenses';

  static Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(_boxName);

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Call once in main(), after [Hive.initFlutter()].
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    await Hive.openBox<ExpenseModel>(_boxName);
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  static Future<void> addExpense(ExpenseModel expense) async {
    await _box.add(expense);
  }

  static Future<void> deleteExpense(int index) async {
    await _box.deleteAt(index);
  }

  // ── Read ─────────────────────────────────────────────────────────────────────

  /// All expenses, newest first.
  static List<ExpenseModel> getAll() {
    return _box.values.toList().reversed.toList();
  }

  /// A [ValueListenable] so widgets can rebuild automatically on changes.
  static ValueListenable<Box<ExpenseModel>> listenable() =>
      _box.listenable();

  // ── Summary helpers ──────────────────────────────────────────────────────────

  static double _sum(Iterable<ExpenseModel> items) =>
      items.fold(0.0, (acc, e) => acc + e.amount);

  static double totalToday() {
    final now = DateTime.now();
    return _sum(_box.values.where((e) =>
    e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day));
  }

  static double totalThisWeek() {
    final now = DateTime.now();
    // Start of the current ISO week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _sum(_box.values.where((e) => !e.date.isBefore(weekStart)));
  }

  static double totalThisMonth() {
    final now = DateTime.now();
    return _sum(_box.values.where(
            (e) => e.date.year == now.year && e.date.month == now.month));
  }

  static double totalThisYear() {
    final now = DateTime.now();
    return _sum(_box.values.where((e) => e.date.year == now.year));
  }

  static double totalThisMonthByCategory(String category) {
    final now = DateTime.now();
    return _sum(_box.values.where((e) =>
    e.date.year == now.year &&
        e.date.month == now.month &&
        e.category.toLowerCase() == category.toLowerCase()));
  }
}