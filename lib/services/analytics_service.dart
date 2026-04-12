// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'device_detector_stub.dart' if (dart.library.html) 'device_detector_web.dart';

class AnalyticsService {
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbxMo7GYJpl-nuJIL1qt-nVV-8F1UxH3pC3MUhL4B8Z-VILOMzbrHEr6Nbp3ZqXKcaxuAw/exec';

  static final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  // Screen names
  static const String screenHome               = 'HomeScreen';
  static const String screenNewExpense         = 'NewExpenseScreen';
  static const String screenChooseCategory     = 'ChooseCategoryScreen';
  static const String screenAmountPaid         = 'AmountPaidScreen';
  static const String screenTransactionDetails = 'TransactionDetailsScreen';
  static const String screenPaymentMethod      = 'PaymentMethodScreen';
  static const String screenExpenseAdded       = 'ExpenseAddedScreen';

  static String appVersion = '1.0.0';
  static String trialId = '';
  static String _device = '';
  static String _platform = '';
  static String _sessionId = '';
  static bool _sessionInitialized = false;
  static DateTime? _sessionStartedAt;
  static String _currentScreen = '';
  static DateTime? _screenEnteredAt;
  static int _clickCountOnScreen = 0;

  static Future _lastEvent = Future.value();

  static void _detectDevice() {
    if (kIsWeb) {
      _platform = 'web';
      final screenWidth = getScreenWidth();
      if (screenWidth < 768) {
        _device = 'mobile';
      } else if (screenWidth < 1024) {
        _device = 'tablet';
      } else {
        _device = 'desktop';
      }
    } else if (Platform.isAndroid) {
      _platform = 'android';
      _device = 'mobile';
    } else if (Platform.isIOS) {
      _platform = 'ios';
      _device = 'mobile';
    } else if (Platform.isMacOS) {
      _platform = 'macos';
      _device = 'desktop';
    } else if (Platform.isWindows) {
      _platform = 'windows';
      _device = 'desktop';
    } else if (Platform.isLinux) {
      _platform = 'linux';
      _device = 'desktop';
    } else {
      _platform = 'unknown';
      _device = 'unknown';
    }
    // ignore: avoid_print
    print('[Analytics] Device detected: $_device ($_platform)');
  }

  static void setDeviceFromScreenWidth(double screenWidth) {
    if (kIsWeb) {
      if (screenWidth < 768) {
        _device = 'mobile';
      } else if (screenWidth < 1024) {
        _device = 'tablet';
      } else {
        _device = 'desktop';
      }
      if (kDebugMode) {
        print('📊 Device detected: $_device (width: $screenWidth)');
      }
    }
  }

  static void initParticipant() {
    if (!_sessionInitialized) {
      _sessionId = 'P${DateTime.now().millisecondsSinceEpoch}';
      _sessionInitialized = true;
      // ignore: avoid_print
      print('[Analytics] initParticipant — sessionId=$_sessionId');
    }
  }

  static Future enableDebugMode() async {
    try {
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);
      // ignore: avoid_print
      print('[Firebase Analytics] ✅ Debug mode enabled!');
      print('[Firebase Analytics] Session ID: $_sessionId');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] ❌ Error enabling debug mode: $e');
    }
  }

  static Future checkFirebaseStatus() async {
    try {
      // ignore: avoid_print
      print('========== Firebase Analytics Status ==========');
      print('📱 Session ID: $_sessionId');
      print('🔄 Trial ID: $trialId');
      print('📊 Device: $_device ($_platform)');
      print('============================================');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] Error checking status: $e');
    }
  }

  static void startSession() {
    initParticipant();
    trialId = _generateTrialId();
    _sessionStartedAt = DateTime.now();
    _currentScreen = screenHome;
    _screenEnteredAt = DateTime.now();
    _clickCountOnScreen = 0;
    _detectDevice();
    _lastEvent = Future.value();
    // ignore: avoid_print
    print('[Analytics] startSession — sessionId=$_sessionId, trialId=$trialId');
  }

  static String _generateTrialId() {
    final now = DateTime.now();
    final random = now.microsecond.toRadixString(16);
    return '${random.substring(0, 8.clamp(0, random.length))}'
        '-${now.millisecond.toRadixString(16).padLeft(4, '0')}'
        '-${now.second.toRadixString(16).padLeft(2, '0')}'
        '${now.minute.toRadixString(16).padLeft(2, '0')}'
        '-${now.hour.toRadixString(16).padLeft(2, '0')}'
        '${now.day.toRadixString(16).padLeft(2, '0')}'
        '-${now.month.toRadixString(16).padLeft(2, '0')}'
        '${now.year.toRadixString(16)}';
  }

  static void logScreenView(String screenName) {
    final prevScreenTimeMs = _screenEnteredAt != null
        ? DateTime.now().difference(_screenEnteredAt!).inMilliseconds
        : 0;
    final prevScreenTimeSeconds = prevScreenTimeMs / 1000.0;

    _sendEvent(
      event: 'screen_view',
      data: 'prev_screen_time_seconds:${prevScreenTimeSeconds.toStringAsFixed(2)}',
      fromScreen: _currentScreen,
      destination: screenName,
      timeOnScreenSeconds: prevScreenTimeSeconds,
      clickCount: _clickCountOnScreen,
    );

    _currentScreen = screenName;
    _screenEnteredAt = DateTime.now();
    _clickCountOnScreen = 0;
  }

  static void logNavigation({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) {
    _clickCountOnScreen++;
    _sendEvent(event: 'nav_$navButtonId', data: '', fromScreen: fromScreen, destination: destination);
  }

  static void logTabSelected(String tabName, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'tab_selected', data: tabName, fromScreen: fromScreen);
  }

  static void logAmountClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'amount_clicked', fromScreen: fromScreen);
  }

  static void logAmountEntered(String amount, String fromScreen) {
    _sendEvent(event: 'amount_entered', data: amount, fromScreen: fromScreen);
  }

  static void logCategoryClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'category_clicked', fromScreen: fromScreen);
  }

  static void logCategorySelected(String category, String fromScreen) {
    _sendEvent(event: 'category_selected', data: category, fromScreen: fromScreen);
  }

  static void logDateSelected(DateTime date, String fromScreen) {
    final formatted =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    _sendEvent(event: 'date_selected', data: formatted, fromScreen: fromScreen);
  }

  static void logPaymentMethodClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'payment_method_clicked', fromScreen: fromScreen);
  }

  static void logPaymentMethodSelected(String method, String fromScreen) {
    _sendEvent(event: 'payment_method_selected', data: method, fromScreen: fromScreen);
  }

  static void logPaymentMethodDeselected(String method, String fromScreen) {
    _sendEvent(event: 'payment_method_deselected', data: method, fromScreen: fromScreen);
  }

  static void logDescriptionClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'description_clicked', fromScreen: fromScreen);
  }

  static void logDescriptionEntered(String description, String fromScreen) {
    _sendEvent(event: 'description_entered', data: description, fromScreen: fromScreen);
  }

  static void logPayeeClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'payee_clicked', fromScreen: fromScreen);
  }

  static void logPayeeEntered(String payee, String fromScreen) {
    _sendEvent(event: 'payee_entered', data: payee, fromScreen: fromScreen);
  }

  static void logPayeeSuggestionSelected(String payee, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'payee_suggestion_selected', data: payee, fromScreen: fromScreen);
  }

  static void logExpenseTypeSelected(String expenseType, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'expense_type_selected', data: expenseType, fromScreen: fromScreen);
  }

  /// Log final expense submission — accepts the user-selected date
  static void logConfirmClicked({
    required String fromScreen,
    required String amount,
    required String category,
    required String description,
    required String paymentMethod,
    required DateTime date, // ← user-selected date passed in from screen
  }) {
    _clickCountOnScreen++;

    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final totalSessionSeconds = _sessionStartedAt != null
        ? DateTime.now().difference(_sessionStartedAt!).inMilliseconds / 1000.0
        : 0.0;

    final payload =
        'amount:$amount|category:$category|desc:$description|payment:$paymentMethod|date:$formattedDate|total_time:${totalSessionSeconds.toStringAsFixed(2)}';

    // ignore: avoid_print
    print('[Analytics] expense_logged payload: $payload');

    _sendEvent(
      event: 'expense_logged',
      data: payload,
      fromScreen: fromScreen,
      totalSessionSeconds: totalSessionSeconds,
      clickCount: _clickCountOnScreen,
    );
  }

  static void logCompleted({
    String category = '',
    String amount = '',
    String payee = '',
    String description = '',
    String paymentMethod = '',
  }) {
    final totalSessionSeconds = _sessionStartedAt != null
        ? DateTime.now().difference(_sessionStartedAt!).inMilliseconds / 1000.0
        : null;

    final details = [
      if (category.isNotEmpty) 'category:$category',
      if (amount.isNotEmpty) 'amount:$amount',
      if (payee.isNotEmpty) 'payee:$payee',
      if (description.isNotEmpty) 'description:$description',
      if (paymentMethod.isNotEmpty) 'payment_method:$paymentMethod',
    ].join(',');

    _sendEvent(
      event: 'expense_logged',
      data: details,
      fromScreen: _currentScreen,
      totalSessionSeconds: totalSessionSeconds,
    );
    // ignore: avoid_print
    print('[Analytics] logCompleted — expense_logged (total_session_seconds=${totalSessionSeconds?.toStringAsFixed(2) ?? ''})');
  }

  static void logAbandoned() {
    _sendEvent(event: 'task_abandoned', fromScreen: _currentScreen);
    // ignore: avoid_print
    print('[Analytics] logAbandoned — task abandoned');
  }

  static void logButtonClick(String buttonName, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'button_click', data: buttonName, fromScreen: fromScreen);
  }

  static void logBackToHome(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(event: 'back_to_home', fromScreen: fromScreen, destination: screenHome);
  }

  static void logTransition({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) {
    logNavigation(fromScreen: fromScreen, destination: destination, navButtonId: navButtonId);
  }

  static void _sendEvent({
    required String event,
    String data = '',
    String fromScreen = '',
    String destination = '',
    double? timeOnScreenSeconds,
    double? totalSessionSeconds,
    int? clickCount,
  }) {
    final timestamp = DateTime.now().toUtc().toIso8601String();

    final params = {
      'timestamp': timestamp,
      'session_id': _sessionId,
      'trial_id': trialId,
      'event': event,
      'data': data,
      'from_screen': fromScreen,
      'destination': destination,
      'time_on_screen_seconds': timeOnScreenSeconds?.toStringAsFixed(2) ?? '',
      'total_session_seconds': totalSessionSeconds?.toStringAsFixed(2) ?? '',
      'click_count': clickCount?.toString() ?? '',
      'device': _device,
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final url = '$_webAppUrl?$queryString';

    // ignore: avoid_print
    print('[Analytics] Queuing event: $event');

    _lastEvent = _lastEvent.then((_) {
      // ignore: avoid_print
      print('[Analytics] Sending event: $event');

      js.context.callMethod('fetch', [
        url,
        js.JsObject.jsify({'method': 'GET', 'mode': 'no-cors'}),
      ]);

      _logToFirebase(
        event: event,
        data: data,
        fromScreen: fromScreen,
        destination: destination,
        timeOnScreenSeconds: timeOnScreenSeconds,
        totalSessionSeconds: totalSessionSeconds,
        clickCount: clickCount,
      );
    }).catchError((Object error) {
      // ignore: avoid_print
      print('[Analytics] Failed event: $event — $error');
    });
  }

  static Future _logToFirebase({
    required String event,
    String data = '',
    String fromScreen = '',
    String destination = '',
    double? timeOnScreenSeconds,
    double? totalSessionSeconds,
    int? clickCount,
  }) async {
    try {
      final Map<String, Object> firebaseParams = {
        'session_id': _sessionId,
        'trial_id': trialId,
        'device': _device,
      };

      if (data.isNotEmpty) firebaseParams['data'] = data;
      if (fromScreen.isNotEmpty) firebaseParams['from_screen'] = fromScreen;
      if (destination.isNotEmpty) firebaseParams['destination'] = destination;
      if (timeOnScreenSeconds != null) firebaseParams['time_on_screen_seconds'] = timeOnScreenSeconds;
      if (totalSessionSeconds != null) firebaseParams['total_session_seconds'] = totalSessionSeconds;
      if (clickCount != null) firebaseParams['click_count'] = clickCount;

      await _firebaseAnalytics.logEvent(name: event, parameters: firebaseParams);

      // ignore: avoid_print
      print('[Firebase Analytics] ✅ Event logged: $event | Params: $firebaseParams');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] ❌ Error logging event "$event": $e');
      print('[Firebase Analytics] Stack trace: ${StackTrace.current}');
    }
  }

  static Future flushEvents() => _lastEvent;
}