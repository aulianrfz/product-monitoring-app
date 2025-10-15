import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../repositories/sync_repository.dart';

class SyncManager {
  final List<SyncableRepository> repositories;
  StreamSubscription? _subscription;
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);

  SyncManager({required this.repositories});

  void startMonitoring(String token) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        isSyncing.value = true;
        await _syncAll(token);
        isSyncing.value = false;
      }
    });
  }

  Future<void> _syncAll(String token) async {
    for (final repo in repositories) {
      await repo.syncPending(token);
    }
  }

  void dispose() {
    _subscription?.cancel();
    isSyncing.dispose();
  }
}
