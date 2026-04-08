// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'device_detector_stub.dart'
    if (dart.library.html) 'device_detector_web.dart';


class AnalyticsService {
  // Google Apps Script web app URL (doGet endpoint)
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbxMo7GYJpl-nuJIL1qt-nVV-8F1UxH3pC3MUhL4B8Z-VILOMzbrHEr6Nbp3ZqXKcaxuAw/exec';

  // Firebase Analytics instance
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
  static String trialId    = '';
  // Device info
  static String _device = '';
  static String _platform = '';
  static String _sessionId = '';  // Participant ID - set once on app init
  static bool _sessionInitialized = false;
  static DateTime? _sessionStartedAt;
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

  /// Enable Firebase Analytics Debug Mode (for development/testing)
  /// This allows you to see events in real-time in Firebase Console DebugView
  static Future<void> enableDebugMode() async {
    try {
      // Enable analytics collection
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);
      

      // ignore: avoid_print
      print('[Firebase Analytics] ✅ Debug mode enabled!');
      print('[Firebase Analytics] Session ID: $_sessionId');
      print('[Firebase Analytics] To see events:');
      print('[Firebase Analytics] 1. Go to: https://console.firebase.google.com/');
      print('[Firebase Analytics] 2. Select your project');
      print('[Firebase Analytics] 3. Go to: Analytics > DebugView');
      print('[Firebase Analytics] 4. Events should appear in real-time');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] ❌ Error enabling debug mode: $e');
    }
  }

  /// Check Firebase Analytics status and connectivity (for debugging)
  static Future<void> checkFirebaseStatus() async {
    try {
      // ignore: avoid_print
      print('\n========== Firebase Analytics Status ==========');
      print('📱 Session ID: $_sessionId');
      print('🔄 Trial ID: $trialId');
      print('📊 Device: $_device ($_platform)');
      print('✅ Analytics collection should be enabled');
      print('\n📝 What to check:');
      print('1. Open Firebase Console → Analytics → DebugView');
      print('2. Look for device with session ID: $_sessionId');
      print('3. Perform an action (tap button, navigate screen)');
      print('4. Check if event appears in real-time');
      print('\n🔗 Direct link: https://console.firebase.google.com/');
      print('============================================\n');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] Error checking status: $e');
    }
  }

  /// Start a new trial (call each time user starts logging an expense)
  static void startSession() {
    initParticipant();  // Ensure participant ID exists
    trialId = _generateTrialId();
    _sessionStartedAt = DateTime.now();
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

  /// Log final expense submission
  static void logConfirmClicked({
    required String fromScreen,
    required String amount,
    required String category,
    required String description,
    required String paymentMethod,
  }) {
    _clickCountOnScreen++;

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final totalSessionSeconds = _sessionStartedAt != null
        ? DateTime.now().difference(_sessionStartedAt!).inMilliseconds / 1000.0
        : 0.0;

    final payload =
        'amount:$amount|category:$category|desc:$description|payment:$paymentMethod|date:$date|total_time:${totalSessionSeconds.toStringAsFixed(2)}';

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

  /// Log task completion
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

   /// Send event to Google Apps Script via GET request AND Firebase Analytics
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

      // Send to Google Sheets
      js.context.callMethod('fetch', [
        url,
        js.JsObject.jsify({
          'method': 'GET',
          'mode': 'no-cors',
        }),
      ]);

      // Send to Firebase Analytics
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

  /// Log event to Firebase Analytics
  static Future<void> _logToFirebase({
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

      // Add optional parameters if they have values
      if (data.isNotEmpty) {
        firebaseParams['data'] = data;
      }
      if (fromScreen.isNotEmpty) {
        firebaseParams['from_screen'] = fromScreen;
      }
      if (destination.isNotEmpty) {
        firebaseParams['destination'] = destination;
      }
      if (timeOnScreenSeconds != null) {
        firebaseParams['time_on_screen_seconds'] = timeOnScreenSeconds;
      }
      if (totalSessionSeconds != null) {
        firebaseParams['total_session_seconds'] = totalSessionSeconds;
      }
      if (clickCount != null) {
        firebaseParams['click_count'] = clickCount;
      }

      // Log to Firebase Analytics
      await _firebaseAnalytics.logEvent(
        name: event,
        parameters: firebaseParams,
      );

      // ignore: avoid_print
      print('[Firebase Analytics] ✅ Event logged: $event | Params: $firebaseParams');
    } catch (e) {
      // ignore: avoid_print
      print('[Firebase Analytics] ❌ Error logging event "$event": $e');
      print('[Firebase Analytics] Stack trace: ${StackTrace.current}');
    }
  }

  /// Wait until all queued analytics events are sent.
  static Future<void> flushEvents() => _lastEvent;
}