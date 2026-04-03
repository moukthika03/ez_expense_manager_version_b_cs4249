import 'package:http/http.dart' as http;

/// Analytics service that logs events to Google Sheets via
/// a Google Apps Script Web App using GET requests (avoids CORS).
class AnalyticsService {
  // ── CONFIGURE THIS ────────────────────────────────────────────────
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbzQtYiJ0XwbXxfdwhf3CefQyiurJW4pMf2GT5R6vYLnyD5UQs6yHbjN5oqnltenrPuJCg/exec';
  // ─────────────────────────────────────────────────────────────────

  // Screen name constants
  static const String screenHome               = 'home';
  static const String screenNewExpense         = 'new_expense';
  static const String screenChooseCategory     = 'choose_category';
  static const String screenAmountPaid         = 'amount_paid';
  static const String screenTransactionDetails = 'transaction_details';
  static const String screenPaymentMethod      = 'payment_method';
  static const String screenExpenseAdded       = 'expense_added';

  // Session metadata (set in main.dart)
  static String appVersion = '';
  static String trialId    = '';

  // ── Internal helper ───────────────────────────────────────────────

  static Future<void> _get(Map<String, String> params) async {
    try {
      params['app_version'] = appVersion;
      params['trial_id']    = trialId;
      params['timestamp']   = DateTime.now().toIso8601String();

      final uri = Uri.parse(_webAppUrl).replace(queryParameters: params);
      await http.get(uri);
    } catch (e) {
      // ignore: avoid_print
      print('[AnalyticsService] GET failed: $e');
    }
  }

  // ── Public API ────────────────────────────────────────────────────

  static Future<void> startSession() => _get({
    'event':  'session_start',
    'screen': screenHome,
  });

  static Future<void> logTransition({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) =>
      _get({
        'event':         'transition',
        'from_screen':   fromScreen,
        'destination':   destination,
        'nav_button_id': navButtonId,
      });

  static Future<void> logCompleted() => _get({
    'event':  'expense_completed',
    'screen': screenExpenseAdded,
  });
}