// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Persists multi-step expense-flow state in sessionStorage so that a
/// browser refresh can return the user to the screen they were on.
///
/// Usage pattern
/// ─────────────
/// • Each screen calls [save] just before pushing the *next* route,
///   storing the step name the user is *about to see* plus all data
///   collected so far.
/// • [HomeScreen] reads [savedStep] / [savedData] on startup and
///   navigates directly to the saved step.
/// • [ExpenseAddedScreen] (flow complete) calls [clear].
class FlowStateService {
  FlowStateService._();

  static const _stepKey = 'ez_flow_step';
  static const _dataKey = 'ez_flow_data';

  // Step name constants (match the destination screen).
  static const String stepChooseCategory     = 'choose_category';
  static const String stepAmountPaid         = 'amount_paid';
  static const String stepTransactionDetails = 'transaction_details';
  static const String stepPaymentMethod      = 'payment_method';

  /// Persists the current step and all accumulated form data.
  static void save({
    required String step,
    required Map<String, String> data,
  }) {
    html.window.sessionStorage[_stepKey] = step;
    html.window.sessionStorage[_dataKey] = jsonEncode(data);
  }

  /// The step name saved in the last [save] call, or `null` if none.
  static String? get savedStep =>
      html.window.sessionStorage[_stepKey];

  /// The data map saved in the last [save] call, or an empty map.
  static Map<String, String> get savedData {
    final raw = html.window.sessionStorage[_dataKey];
    if (raw == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  /// Removes all persisted state.  Call when the flow completes or the
  /// user explicitly cancels.
  static void clear() {
    html.window.sessionStorage.remove(_stepKey);
    html.window.sessionStorage.remove(_dataKey);
  }
}