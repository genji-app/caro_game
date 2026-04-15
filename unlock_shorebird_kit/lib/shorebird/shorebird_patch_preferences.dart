/// Keys for Shorebird patch UX persisted across launches.
abstract final class ShorebirdPatchPreferences {
  ShorebirdPatchPreferences._();

  /// After the first successful "patch ready → auto restart" flow, further
  /// [UpdateFlowStatus.restartRequired] events show the restart snackbar only.
  static const String firstPostPatchAutoRestartConsumedKey =
      'shorebird_first_post_patch_auto_restart_consumed';
}
