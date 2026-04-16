import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:co_caro_flame/s88/core/utils/styles/app_rive.dart';

/// Service để quản lý Rive animation cho vibrating odds (Kèo Rung).
///
/// Được khởi tạo một lần khi app start và giữ trong memory.
/// Tránh việc load Rive file nhiều lần gây giảm performance.
class RiveVibratingService {
  rive.File? _riveFile;
  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;

  /// Pre-load Rive file. Gọi một lần khi app khởi động hoặc vào Sport page.
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    try {
      _riveFile = await rive.File.url(
        AppRive.animCardNho,
        riveFactory: rive.Factory.rive,
      );
      _isInitialized = _riveFile != null;
    } catch (e) {
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Tạo controller mới từ Rive file đã load.
  /// Mỗi widget cần controller riêng để control animation độc lập.
  rive.RiveWidgetController? createController() {
    if (!_isInitialized || _riveFile == null) return null;
    return rive.RiveWidgetController(_riveFile!);
  }

  /// Dispose service (gọi khi app terminate)
  void dispose() {
    _riveFile = null;
    _isInitialized = false;
  }
}

/// Provider cho RiveVibratingService - singleton trong app
final riveVibratingServiceProvider = Provider<RiveVibratingService>((ref) {
  final service = RiveVibratingService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider để track trạng thái initialized
final riveVibratingInitializedProvider = StateProvider<bool>((ref) => false);

/// Future provider để initialize Rive service
/// Sử dụng khi cần đảm bảo Rive đã được load trước khi dùng
final riveVibratingInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(riveVibratingServiceProvider);
  await service.initialize();
  ref.read(riveVibratingInitializedProvider.notifier).state = true;
});
