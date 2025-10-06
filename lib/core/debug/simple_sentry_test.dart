import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// Simple widget to test Sentry integration directly
class SimpleSentryTest extends StatelessWidget {
  const SimpleSentryTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentry Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Sentry Integration Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Click the button below to send a test error to Sentry',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _sendTestError(context),
              icon: const Icon(Icons.send),
              label: const Text('Send Test Error to Sentry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _sendTestMessage(context),
              icon: const Icon(Icons.message),
              label: const Text('Send Test Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendTestError(BuildContext context) async {
    try {
      // Generate unique event ID
      final eventId = _generateEventId();

      await _sendToSentry(
        eventId: eventId,
        level: 'error',
        message:
            '🔥 FLUTTER TEST ERROR - OZPOS Sentry Integration Test from Flutter App',
        extra: {
          'source': 'flutter_app',
          'widget': 'SimpleSentryTest',
          'test_type': 'error',
          'user_triggered': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test error sent to Sentry! Check your dashboard.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _sendTestMessage(BuildContext context) async {
    try {
      // Generate unique event ID
      final eventId = _generateEventId();

      await _sendToSentry(
        eventId: eventId,
        level: 'info',
        message:
            '📧 FLUTTER TEST MESSAGE - OZPOS Sentry Integration working correctly',
        extra: {
          'source': 'flutter_app',
          'widget': 'SimpleSentryTest',
          'test_type': 'message',
          'user_triggered': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Test message sent to Sentry! Check your dashboard.',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send message: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _sendToSentry({
    required String eventId,
    required String level,
    required String message,
    Map<String, dynamic>? extra,
  }) async {
    const sentryDsn =
        'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824';
    const projectId = '4510112203341824';
    const publicKey = '5043c056bceb3ca2e4a92d2e6e2b0235';

    final url =
        'https://o4509604948869120.ingest.us.sentry.io/api/$projectId/store/';

    final event = {
      'event_id': eventId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'platform': 'flutter',
      'logger': 'flutter-test',
      'level': level,
      'server_name': 'ozpos-flutter',
      'release': 'ozpos-flutter@1.0.0+1',
      'environment': 'flutter-test',
      'message': {'formatted': message},
      'tags': {
        'app_name': 'OZPOS',
        'framework': 'flutter',
        'test_type': 'manual_flutter_test',
        'source': 'simple_sentry_test_widget',
      },
      'extra': extra ?? {},
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Sentry-Auth':
            'Sentry sentry_version=7, sentry_key=$publicKey, sentry_client=flutter-test/1.0.0',
        'User-Agent': 'ozpos-flutter/1.0.0',
      },
      body: json.encode(event),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  String _generateEventId() {
    final random = Random();
    return List.generate(
      32,
      (index) => random.nextInt(16).toRadixString(16),
    ).join('');
  }
}
