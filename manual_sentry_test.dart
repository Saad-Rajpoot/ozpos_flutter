import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🚀 Sending test error directly to Sentry...');

  final sentryDsn =
      'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824';

  // Parse the DSN to get the endpoint
  final uri = Uri.parse(sentryDsn);
  final projectId = '4510112203341824';
  final publicKey = '5043c056bceb3ca2e4a92d2e6e2b0235';

  // Sentry envelope endpoint
  final envelopeUrl =
      'https://o4509604948869120.ingest.us.sentry.io/api/$projectId/envelope/';

  // Create a simple error event
  final event = {
    'event_id': 'test-error-${DateTime.now().millisecondsSinceEpoch}',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'platform': 'dart',
    'logger': 'manual-test',
    'level': 'error',
    'server_name': 'ozpos-test',
    'release': 'ozpos-flutter@1.0.0+1',
    'environment': 'test',
    'tags': {
      'app_name': 'OZPOS',
      'test_type': 'manual_verification',
      'source': 'dart_script',
    },
    'exception': {
      'values': [
        {
          'type': 'TestException',
          'value':
              '🔥 MANUAL TEST ERROR - OZPOS Sentry Integration Verification from Dart Script',
          'stacktrace': {
            'frames': [
              {
                'filename': 'manual_sentry_test.dart',
                'function': 'main',
                'lineno': 42,
                'in_app': true,
              },
            ],
          },
        },
      ],
    },
    'message': {
      'formatted':
          '🧪 OZPOS Manual Test - This error was sent directly to verify Sentry integration is working',
    },
    'extra': {
      'test_timestamp': DateTime.now().toIso8601String(),
      'sent_from': 'manual_dart_script',
      'purpose': 'integration_verification',
    },
  };

  // Create Sentry envelope format
  final eventHeader = {
    'event_id': event['event_id'],
    'dsn': sentryDsn,
    'timestamp': event['timestamp'],
  };

  final itemHeader = {'type': 'event', 'content_type': 'application/json'};

  // Format as Sentry envelope
  final envelope =
      '${json.encode(eventHeader)}\n${json.encode(itemHeader)}\n${json.encode(event)}';

  try {
    print('📤 Sending to: $envelopeUrl');

    final response = await http.post(
      Uri.parse(envelopeUrl),
      headers: {
        'Content-Type': 'application/x-sentry-envelope',
        'X-Sentry-Auth':
            'Sentry sentry_version=7, sentry_key=$publicKey, sentry_client=manual-test/1.0.0',
        'User-Agent': 'manual-sentry-test/1.0.0',
      },
      body: envelope,
    );

    print('📨 Response Status: ${response.statusCode}');
    print('📨 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('');
      print('✅ SUCCESS! Error sent to Sentry dashboard!');
      print('🎯 Check your Sentry dashboard now:');
      print('   📍 https://sentry.io/');
      print('   🔍 Look for: "MANUAL TEST ERROR - OZPOS Sentry Integration"');
      print('   🏷️  Environment: test');
      print('   📅 Timestamp: ${DateTime.now().toLocal()}');
      print('');
      print(
        'If you see this error in your dashboard, the integration is working! 🎉',
      );
    } else {
      print('');
      print('❌ FAILED to send error to Sentry');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
      print('');
      print('This might indicate:');
      print('1. DSN might be incorrect');
      print('2. Network connectivity issues');
      print('3. Sentry project configuration issues');
    }
  } catch (e, stackTrace) {
    print('');
    print('❌ ERROR sending to Sentry: $e');
    print('Stack trace: $stackTrace');
    print('');
    print('This might indicate network or configuration issues.');
  }
}
