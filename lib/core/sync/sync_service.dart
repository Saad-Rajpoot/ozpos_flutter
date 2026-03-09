import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../db/sync_outbox_dao.dart';
import '../db/pos_database.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../network/connectivity_state.dart';
import '../network/network_info.dart';

/// Sync service that replays pending outbox entries when connectivity is online.
class SyncService {
  SyncService({
    required SyncOutboxDao outboxDao,
    required ConnectivityService connectivityService,
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
  })  : _outboxDao = outboxDao,
        _connectivityService = connectivityService,
        _apiClient = apiClient,
        _networkInfo = networkInfo {
    _subscription = _connectivityService.stream.listen(_onConnectivityChanged);
  }

  final SyncOutboxDao _outboxDao;
  final ConnectivityService _connectivityService;
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  StreamSubscription<ConnectivitySnapshot>? _subscription;
  bool _isProcessing = false;

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onConnectivityChanged(ConnectivitySnapshot snapshot) {
    if (snapshot.status == ConnectivityStatus.online) {
      _processOutbox();
    }
  }

  Future<void> _processOutbox() async {
    if (_isProcessing) return;

    // Respect the app's network override (debug offline button). Even if
    // the underlying transport and API health are online, we should not
    // sync while the app is "forced offline" for testing.
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return;

    _isProcessing = true;
    _connectivityService.setSyncing(true);

    try {
      while (true) {
        final now = DateTime.now();
        final entries = await _outboxDao.pendingEntries(now);
        if (entries.isEmpty) break;

        for (final entry in entries) {
          await _outboxDao.markInProgress(entry.id);
          try {
            await _replayEntry(entry);
            await _outboxDao.markCompleted(entry.id);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('SyncService: entry ${entry.id} failed: $e');
            }
            await _outboxDao.markFailedWithBackoff(
              id: entry.id,
              currentRetryCount: entry.retryCount,
              error: e.toString(),
            );
          }
        }
      }
    } finally {
      _isProcessing = false;
      _connectivityService.setSyncing(false);
    }
  }

  Future<void> _replayEntry(SyncOutboxEntry entry) async {
    final method = entry.method.toUpperCase();
    final path = entry.path;
    final body = entry.bodyJson;

    switch (method) {
      case 'POST':
        await _apiClient.post(
          path,
          data: body == null ? null : _decodeBody(body),
          options: _idempotencyOptions(entry.correlationId),
        );
        break;
      case 'PATCH':
        await _apiClient.patch(
          path,
          data: body == null ? null : _decodeBody(body),
          options: _idempotencyOptions(entry.correlationId),
        );
        break;
      default:
        // For simplicity, only POST/PATCH are supported for mutations.
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Unsupported outbox method: $method',
        );
    }
  }

  dynamic _decodeBody(String json) {
    try {
      return jsonDecode(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncService: failed to decode body: $e');
      }
      return null;
    }
  }

  Options _idempotencyOptions(String? correlationId) {
    if (correlationId == null || correlationId.isEmpty) {
      return Options();
    }
    return Options(
      headers: {
        'Idempotency-Key': correlationId,
      },
    );
  }
}

