import 'package:sentry_flutter/sentry_flutter.dart';

/// Simple test to verify Sentry is working with your DSN
void main() async {
  print('🔍 Testing Sentry Integration...');
  
  // Initialize Sentry with your DSN
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824';
      options.environment = 'test';
      options.release = 'ozpos-flutter@1.0.0+1';
      options.debug = true; // Enable debug logging
    },
  );
  
  print('✅ Sentry initialized successfully');
  
  // Send a test message
  await Sentry.captureMessage(
    '🧪 OZPOS Test Message - Sentry Integration Verification',
    level: SentryLevel.info,
  );
  print('📤 Test message sent to Sentry');
  
  // Send a test error
  try {
    throw Exception('🔥 OZPOS Test Error - This is a test error to verify Sentry integration is working correctly');
  } catch (error, stackTrace) {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('test_type', 'integration_verification');
        scope.setTag('app_name', 'OZPOS');
        scope.setTag('timestamp', DateTime.now().toIso8601String());
      },
    );
    print('🚨 Test error sent to Sentry');
  }
  
  // Wait a moment for the requests to complete
  await Future.delayed(Duration(seconds: 3));
  
  print('');
  print('🎯 Test complete! Check your Sentry dashboard:');
  print('   Dashboard URL: https://sentry.io/');
  print('   Look for: "OZPOS Test Error" and "OZPOS Test Message"');
  print('   Environment: test');
  print('   Release: ozpos-flutter@1.0.0+1');
  print('');
  print('   If you see these events, Sentry integration is working! ✅');
  print('   If not, there might be a network or configuration issue. ❌');
}