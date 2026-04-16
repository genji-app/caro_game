import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';

/// Change Sport Use Case
///
/// Single responsibility: Change the current sport type.
class ChangeSportUseCase {
  final SportRepository _repository;

  ChangeSportUseCase(this._repository);

  /// Execute the use case
  ///
  /// [sportId] - The sport type ID to switch to
  Future<void> call(int sportId) async {
    await _repository.changeSport(sportId);
  }

  /// Get current sport ID
  int get currentSportId => _repository.currentSportId;
}
