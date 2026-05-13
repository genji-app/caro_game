import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'update_event.dart';
import 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc({
    required ShorebirdUpdater updater,
    UpdateTrack track = UpdateTrack.stable,
    bool autoUpdateEnabled = false,
    bool skipInitialCheck = false,
  }) : _updater = updater,
       _track = track,
       _autoUpdateEnabled = autoUpdateEnabled,
       super(const UpdateState()) {
    on<UpdateCheckRequested>(_onCheckRequested);
    on<UpdateDownloadRequested>(_onDownloadRequested);
    if (!_autoUpdateEnabled && !skipInitialCheck) {
      add(const UpdateCheckRequested());
    }
  }

  final ShorebirdUpdater _updater;
  final UpdateTrack _track;
  final bool _autoUpdateEnabled;

  Future<void> _onCheckRequested(
    UpdateCheckRequested event,
    Emitter<UpdateState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UpdateFlowStatus.checking,
        message: _autoUpdateEnabled
            ? 'Auto checking for updates...'
            : 'Checking for updates...',
      ),
    );
    try {
      final status = await _updater.checkForUpdate(track: _track);
      switch (status) {
        case UpdateStatus.restartRequired:
          emit(
            state.copyWith(
              status: UpdateFlowStatus.restartRequired,
              message: 'Patch ready. Restart to apply.',
            ),
          );
          break;
        case UpdateStatus.outdated:
          add(const UpdateDownloadRequested());
          break;
        default:
          if (!_autoUpdateEnabled) {
            emit(
              state.copyWith(
                status: UpdateFlowStatus.upToDate,
                message: 'Status: $status',
              ),
            );
          } else {
            emit(state.copyWith(status: UpdateFlowStatus.upToDate));
          }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateFlowStatus.error,
          message: 'Error checking for update: $e',
        ),
      );
    }
  }

  Future<void> _onDownloadRequested(
    UpdateDownloadRequested event,
    Emitter<UpdateState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UpdateFlowStatus.downloading,
        message: _autoUpdateEnabled ? null : 'Downloading patch...',
      ),
    );
    try {
      await _updater.update(track: _track);
      emit(
        state.copyWith(
          status: UpdateFlowStatus.restartRequired,
          message: 'Update downloaded. Tap restart to apply.',
        ),
      );
    } on UpdateException catch (error) {
      emit(
        state.copyWith(status: UpdateFlowStatus.error, message: error.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateFlowStatus.error,
          message: 'Error downloading update: $e',
        ),
      );
    }
  }

  /// Patch pending restart (download) or current; null if unavailable / read error.
  Future<int?> executeReadPendingPatchNumber() async {
    if (!_updater.isAvailable) {
      return null;
    }
    try {
      final Patch? nextPatch = await _updater.readNextPatch();
      if (nextPatch != null) {
        return nextPatch.number;
      }
      final Patch? currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number;
    } on ReadPatchException {
      return null;
    }
  }
}
