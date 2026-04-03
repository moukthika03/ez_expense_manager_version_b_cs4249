import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics instrumentation for the expense logging flow.
///
/// Implements the two DVs specified in Section B of the project plan:
///
/// DV1 — Time Taken (s):
///   Total seconds from "Add Expense" tap to "Confirm Log" tap.
///   Events: expense_logging_started, expense_logging_completed (duration_s)
///
/// DV2 — Navigational Friction (screen transition count):
///   Every forward AND back navigation is counted, capturing corrective
///   loops (backtracking). Enables friction score:
///     frictionScore = (totalTransitions - P_opt) / P_opt × 100%
///   Events: nav_transition_step (per hop), expense_logging_total_steps (final count)
///
/// Usage:
///   1. Set appVersion + trialId once in main().
///   2. Call startSession()   → when user taps "Add Expense"
///   3. Call logTransition()  → on every forward/back nav button
///   4. Call logCompleted()   → inside "Confirm Log", before saving expense
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  // ── Session config — set once in main.dart ───────────────────────────────
  static String appVersion = 'B'; // 'A' or 'B'
  static String trialId = DateTime.now().millisecondsSinceEpoch.toString();

  // ── Internal state ───────────────────────────────────────────────────────
  static double? _startTime;
  static int _screenTransitionCount = 0;

  // ── Screen name constants (use in logTransition calls) ───────────────────
  static const String screenHome = 'home';
  static const String screenNewExpense = 'new_expense';
  static const String screenChooseCategory = 'choose_category';
  static const String screenAmountPaid = 'amount_paid';
  static const String screenTransactionDetails = 'transaction_details';
  static const String screenPaymentMethod = 'payment_method';
  static const String screenExpenseAdded = 'expense_added';

  // ── DV1: Start ───────────────────────────────────────────────────────────

  /// Call when the user taps "Add Expense" on HomeScreen.
  static Future<void> startSession() async {
    _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _screenTransitionCount = 0;

    await _fa.logEvent(
      name: 'expense_logging_started',
      parameters: {
        'app_version': appVersion,
        'trial_id': trialId,
        'start_timestamp': _startTime!,
        'debug_mode': 'true',
      },
    );
  }

  // ── DV2: Per-transition ──────────────────────────────────────────────────

  /// Call on every forward AND back navigation during the expense flow.
  /// [navButtonId]: 'forward', 'back', or 'confirm'
  static Future<void> logTransition({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) async {
    _screenTransitionCount++;

    await _fa.logEvent(
      name: 'nav_transition_step',
      parameters: {
        'start': fromScreen,
        'destination': destination,
        'navButtonId': navButtonId,
        'current_index': _screenTransitionCount,
        'trialId': trialId,
        'appVersion': appVersion,
        'debug_mode': 'true',
      },
    );
  }

  // ── DV1 + DV2: Completion ────────────────────────────────────────────────

  /// Call when the user taps "Confirm Log" on PaymentMethodScreen.
  /// Logs duration_s (DV1) and total_transitions (DV2), then resets state.
  static Future<void> logCompleted() async {
    final double stopTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final double durationS =
        _startTime != null ? stopTime - _startTime! : 0.0;

    // DV1
    await _fa.logEvent(
      name: 'expense_logging_completed',
      parameters: {
        'app_version': appVersion,
        'trial_id': trialId,
        'stop_timestamp': stopTime,
        'duration_s': durationS,
        'debug_mode': 'true',
      },
    );

    // DV2
    await _fa.logEvent(
      name: 'expense_logging_total_steps',
      parameters: {
        'total_transitions': _screenTransitionCount,
        'trialId': trialId,
        'appVersion': appVersion,
        'debug_mode': 'true',
      },
    );

    _startTime = null;
    _screenTransitionCount = 0;
  }
}
