import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/sentry_service.dart';

/// Debug screen for testing Sentry integration
/// Only available in debug builds
class SentryTestScreen extends StatelessWidget {
  const SentryTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (kReleaseMode) {
      return const Scaffold(
        body: Center(
          child: Text('Sentry test screen is only available in debug mode'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentry Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Sentry Integration Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use the buttons below to test different types of error reporting to Sentry. Check your Sentry dashboard to verify errors are being captured.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic error test
            ElevatedButton.icon(
              onPressed: () => _testBasicError(context),
              icon: const Icon(Icons.error_outline),
              label: const Text('Test Basic Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // POS operation error
            ElevatedButton.icon(
              onPressed: () => _testPOSError(context),
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Test POS Operation Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Payment error
            ElevatedButton.icon(
              onPressed: () => _testPaymentError(context),
              icon: const Icon(Icons.payment),
              label: const Text('Test Payment Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Network error
            ElevatedButton.icon(
              onPressed: () => _testNetworkError(context),
              icon: const Icon(Icons.wifi_off),
              label: const Text('Test Network Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Database error
            ElevatedButton.icon(
              onPressed: () => _testDatabaseError(context),
              icon: const Icon(Icons.storage),
              label: const Text('Test Database Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Message and breadcrumb tests
            ElevatedButton.icon(
              onPressed: () => _testMessage(context),
              icon: const Icon(Icons.message),
              label: const Text('Test Custom Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () => _testBreadcrumb(context),
              icon: const Icon(Icons.timeline),
              label: const Text('Add Test Breadcrumb'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // User context test
            ElevatedButton.icon(
              onPressed: () => _testUserContext(context),
              icon: const Icon(Icons.person),
              label: const Text('Set Test User Context'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testBasicError(BuildContext context) {
    try {
      throw Exception('This is a test error from the Sentry test screen');
    } catch (error, stackTrace) {
      SentryService.reportError(
        error,
        stackTrace,
        hint: 'Basic error test from debug screen',
        extra: {
          'test_type': 'basic_error',
          'user_triggered': true,
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Basic error sent to Sentry'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testPOSError(BuildContext context) {
    try {
      throw Exception('Failed to process order #12345');
    } catch (error, stackTrace) {
      SentryService.reportPOSError(
        'process_order',
        error,
        stackTrace,
        orderId: '12345',
        tableId: 'T-08',
        context: {
          'items_count': 3,
          'total_amount': 45.99,
          'payment_method': 'credit_card',
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ POS operation error sent to Sentry'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testPaymentError(BuildContext context) {
    try {
      throw Exception('Payment processing failed - invalid card');
    } catch (error, stackTrace) {
      SentryService.reportPaymentError(
        'credit_card',
        error,
        stackTrace,
        transactionId: 'txn_test_123456',
        amount: 45.99,
        currency: 'USD',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment error sent to Sentry'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testNetworkError(BuildContext context) {
    try {
      throw Exception('Network request timeout');
    } catch (error, stackTrace) {
      SentryService.reportNetworkError(
        '/api/v1/orders',
        408,
        error,
        stackTrace,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Network error sent to Sentry'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testDatabaseError(BuildContext context) {
    try {
      throw Exception('Database connection lost');
    } catch (error, stackTrace) {
      SentryService.reportDatabaseError(
        'insert_order',
        error,
        stackTrace,
        query: 'INSERT INTO orders (id, customer_id, total) VALUES (?, ?, ?)',
        parameters: {'id': '12345', 'customer_id': '67890', 'total': 45.99},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Database error sent to Sentry'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _testMessage(BuildContext context) {
    SentryService.reportMessage(
      'Test message from OZPOS debug screen',
      level: SentryLevel.info,
      extra: {
        'test_type': 'custom_message',
        'timestamp': DateTime.now().toIso8601String(),
        'user_triggered': true,
      },
      tags: {
        'component': 'debug_screen',
        'action': 'test_message',
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Custom message sent to Sentry'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testBreadcrumb(BuildContext context) {
    SentryService.addBreadcrumb(
      message: 'User tested breadcrumb functionality',
      category: 'debug',
      level: SentryLevel.info,
      data: {
        'screen': 'sentry_test',
        'action': 'test_breadcrumb',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Test breadcrumb added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testUserContext(BuildContext context) {
    SentryService.setUser(
      id: 'test_user_123',
      email: 'testuser@ozpos.com',
      username: 'Test User',
      extras: {
        'role': 'admin',
        'restaurant_id': 'rest_456',
        'test_session': true,
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Test user context set in Sentry'),
        backgroundColor: Colors.green,
      ),
    );
  }
}