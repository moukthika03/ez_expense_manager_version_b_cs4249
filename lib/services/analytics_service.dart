// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'device_detector_stub.dart'
    if (dart.library.html) 'device_detector_web.dart';


class AnalyticsService {
  // Google Apps Script web app URL (doGet endpoint)
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbxMo7GYJpl-nuJIL1qt-nVV-8F1UxH3pC3MUhL4B8Z-VILOMzbrHEr6Nbp3ZqXKcaxuAw/exec';

  // Screen names
  static const String screenHome               = 'HomeScreen';
  static const String screenNewExpense         = 'NewExpenseScreen';
  static const String screenChooseCategory     = 'ChooseCategoryScreen';
  static const String screenAmountPaid         = 'AmountPaidScreen';
  static const String screenTransactionDetails = 'TransactionDetailsScreen';
  static const String screenPaymentMethod      = 'PaymentMethodScreen';
  static const String screenExpenseAdded       = 'ExpenseAddedScreen';

  static String appVersion = '1.0.0';
  static String trialId    = '';
  // Device info
  static String _device = '';
  static String _platform = '';
  static String _sessionId = '';  // Participant ID - set once on app init
  static bool _sessionInitialized = false;
  static String _currentScreen = '';
  static DateTime? _screenEnteredAt;
  static int _clickCountOnScreen = 0;
  
  // Async queue - each event waits for previous to complete
  static Future<void> _lastEvent = Future.value();

  // Detect device type and platform
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
  
  /// Set device type based on screen width (call from widget with context)
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

  /// Initialize participant ID (call once on app start)
  static void initParticipant() {
    if (!_sessionInitialized) {
      _sessionId = 'P${DateTime.now().millisecondsSinceEpoch}';
      _sessionInitialized = true;
      // ignore: avoid_print
      print('[Analytics] initParticipant — sessionId=$_sessionId');
    }
  }

  /// Start a new trial (call each time user starts logging an expense)
  static void startSession() {
    initParticipant();  // Ensure participant ID exists
    trialId = _generateTrialId();
    _currentScreen = screenHome;  // Start from HomeScreen
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
    return '${random.substring(0, 8.clamp(0, random.length))}-${now.millisecond.toRadixString(16).padLeft(4, '0')}-${now.second.toRadixString(16).padLeft(2, '0')}${now.minute.toRadixString(16).padLeft(2, '0')}-${now.hour.toRadixString(16).padLeft(2, '0')}${now.day.toRadixString(16).padLeft(2, '0')}-${now.month.toRadixString(16).padLeft(2, '0')}${now.year.toRadixString(16)}';
  }

  /// Log a screen view event
  static void logScreenView(String screenName) {
    final prevScreenTimeMs = _screenEnteredAt != null
        ? DateTime.now().difference(_screenEnteredAt!).inMilliseconds
        : 0;

    _sendEvent(
      event: 'screen_view',
      data: 'prev_screen_time_ms:$prevScreenTimeMs',
      fromScreen: _currentScreen,
      destination: screenName,
      timeOnScreenSeconds: prevScreenTimeMs / 1000.0,
      clickCount: _clickCountOnScreen,
    );

    _currentScreen = screenName;
    _screenEnteredAt = DateTime.now();
    _clickCountOnScreen = 0;
  }

  /// Log a navigation button click (forward/back)
  static void logNavigation({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'nav_$navButtonId',
      data: '',
      fromScreen: fromScreen,
      destination: destination,
    );
  }

  /// Log a tab selection event
  static void logTabSelected(String tabName, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'tab_selected',
      data: tabName,
      fromScreen: fromScreen,
    );
  }

  /// Log when amount field is clicked/focused
  static void logAmountClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'amount_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log when amount is entered/changed
  static void logAmountEntered(String amount, String fromScreen) {
    _sendEvent(
      event: 'amount_entered',
      data: amount,
      fromScreen: fromScreen,
    );
  }

  /// Log when category dropdown is clicked
  static void logCategoryClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'category_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log when a category is selected
  static void logCategorySelected(String category, String fromScreen) {
    _sendEvent(
      event: 'category_selected',
      data: category,
      fromScreen: fromScreen,
    );
  }

  /// Log when payment method is clicked
  static void logPaymentMethodClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'payment_method_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log when a payment method is selected
  static void logPaymentMethodSelected(String method, String fromScreen) {
    _sendEvent(
      event: 'payment_method_selected',
      data: method,
      fromScreen: fromScreen,
    );
  }

  /// Log when description field is clicked/focused
  static void logDescriptionClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'description_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log when description is entered
  static void logDescriptionEntered(String description, String fromScreen) {
    _sendEvent(
      event: 'description_entered',
      data: description,
      fromScreen: fromScreen,
    );
  }

  /// Log when payee field is clicked/focused
  static void logPayeeClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'payee_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log when payee is entered
  static void logPayeeEntered(String payee, String fromScreen) {
    _sendEvent(
      event: 'payee_entered',
      data: payee,
      fromScreen: fromScreen,
    );
  }

  /// Log when payee suggestion is selected
  static void logPayeeSuggestionSelected(String payee, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'payee_suggestion_selected',
      data: payee,
      fromScreen: fromScreen,
    );
  }

  /// Log expense type selection (new/unlogged)
  static void logExpenseTypeSelected(String expenseType, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'expense_type_selected',
      data: expenseType,
      fromScreen: fromScreen,
    );
  }

  /// Log confirm button click
  static void logConfirmClicked(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'confirm_clicked',
      fromScreen: fromScreen,
    );
  }

  /// Log task completion
  static void logCompleted() {
    _sendEvent(
      event: 'new_expense_logged',
      fromScreen: _currentScreen,
    );
    // ignore: avoid_print
    print('[Analytics] logCompleted — new_expense_logged');
  }

  /// Log task abandoned
  static void logAbandoned() {
    _sendEvent(
      event: 'task_abandoned',
      fromScreen: _currentScreen,
    );
    // ignore: avoid_print
    print('[Analytics] logAbandoned — task abandoned');
  }

  /// Log generic button click
  static void logButtonClick(String buttonName, String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'button_click',
      data: buttonName,
      fromScreen: fromScreen,
    );
  }

  /// Log back to home click
  static void logBackToHome(String fromScreen) {
    _clickCountOnScreen++;
    _sendEvent(
      event: 'back_to_home',
      fromScreen: fromScreen,
      destination: screenHome,
    );
  }

  /// Legacy transition logging (for backward compatibility)
  static void logTransition({
    required String fromScreen,
    required String destination,
    required String navButtonId,
  }) {
    logNavigation(
      fromScreen: fromScreen,
      destination: destination,
      navButtonId: navButtonId,
    );
  }

  /// Send event to Google Apps Script via GET request
  static void _sendEvent({
    required String event,
    String data = '',
    String fromScreen = '',
    String destination = '',
    double? timeOnScreenSeconds,
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
      'click_count': clickCount?.toString() ?? '',
      'device': _device,
    };

    // Build query string for GET request
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final url = '$_webAppUrl?$queryString';

    // ignore: avoid_print
    print('[Analytics] Queuing event: $event');

    // Chain this event after previous one completes
    _lastEvent = _lastEvent.then((_) {
      // ignore: avoid_print
      print('[Analytics] Sending event: $event');
      
      js.context.callMethod('fetch', [
        url,
        js.JsObject.jsify({
          'method': 'GET',
          'mode': 'no-cors',
        }),
      ]);
    });
  }
}