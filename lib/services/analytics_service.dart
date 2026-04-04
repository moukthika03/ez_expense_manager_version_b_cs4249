// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:js' as js;

class AnalyticsService {
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbx4Rsa_jvmHI2X64vRZfkOdeXaxCtRZ2hNgVTIrdMcqHqV7cK6k10Z9Lofms3cwTiUBxg/exec';

  static const String screenHome               = 'home';
  static const String screenNewExpense         = 'new_expense';
  static const String screenChooseCategory     = 'choose_category';
  static const String screenAmountPaid         = 'amount_paid';
  static const String screenTransactionDetails = 'transaction_details';
  static const String screenPaymentMethod      = 'payment_method';
  static const String screenExpenseAdded       = 'expense_added';

  static String appVersion = '';
  static String trialId    = '';

  static String _sessionId      = '';
  static DateTime? _sessionStart;
  static final List<String> _screenSequence = [];

  static void startSession() {
    _sessionId    = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStart = DateTime.now();
    _screenSequence
      ..clear()
      ..add(screenHome);
    // ignore: avoid_print
    print('[Analytics] startSession called — sessionId=$_sessionId');
  }

  static void logTransition({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) {
    _screenSequence.add('$destination($navButtonId)');
    // ignore: avoid_print
    print('[Analytics] logTransition: $fromScreen → $destination ($navButtonId) | sequence so far: $_screenSequence');
  }

  static void logCompleted() {
    // ignore: avoid_print
    print('[Analytics] logCompleted called — _sessionStart=$_sessionStart, sequence=$_screenSequence');
    _flush(completed: true, outcome: 'completed');
  }

  static void logAbandoned() {
    // ignore: avoid_print
    print('[Analytics] logAbandoned called');
    _flush(completed: false, outcome: 'abandoned');
  }

  static void _flush({required bool completed, required String outcome}) {
    if (_sessionStart == null) {
      // ignore: avoid_print
      print('[Analytics] _flush bailed — _sessionStart is null (startSession was never called)');
      return;
    }

    final timeTaken = DateTime.now().difference(_sessionStart!).inSeconds;
    final params = {
      'trial_id'                  : trialId,
      'session_id'                : _sessionId,
      'app_version'               : appVersion,
      'session_start'             : _sessionStart!.toIso8601String(),
      'completed'                 : completed ? 'TRUE' : 'FALSE',
      'outcome'                   : outcome,
      'screen_sequence'           : _screenSequence.join(' > '),
      'time_taken_seconds'        : timeTaken.toString(),
      'number_of_screens_visited' : _screenSequence.length.toString(),
    };

    // ignore: avoid_print
    print('[Analytics] _flush firing with params: $params');

    // ── Why fetch + no-cors instead of XHR ─────────────────────────────
    // Google Apps Script (doPost) does not send CORS headers, so a normal
    // cross-origin XHR or fetch is blocked by the browser.
    // `mode: 'no-cors'` bypasses that restriction: the request IS sent and
    // executed on the server; the response is just opaque (unreadable).
    // That is fine for fire-and-forget analytics.
    // A string body without an explicit Content-Type is treated as
    // text/plain — a "simple" content type that never triggers a preflight.
    // The Apps Script receives the JSON string in e.postData.contents and
    // parses it normally.
    // ───────────────────────────────────────────────────────────────────
    final body = jsonEncode(params);
    js.context.callMethod('fetch', [
      _webAppUrl,
      js.JsObject.jsify({
        'method': 'POST',
        'body'  : body,
        'mode'  : 'no-cors',
      }),
    ]);

    // ignore: avoid_print
    print('[Analytics] fetch dispatched (no-cors POST)');

    _sessionStart = null;
    _screenSequence.clear();
  }
}