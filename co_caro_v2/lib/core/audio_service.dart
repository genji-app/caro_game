import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'app_settings.dart';

class AudioService {
  static final AudioService _i = AudioService._();
  factory AudioService() => _i;
  AudioService._();

  final AudioPlayer _player = AudioPlayer();

  // Tạo âm thanh tổng hợp bằng cách dùng tone URL
  // Sử dụng Web Audio API URL để phát tone
  Future<void> playPlace() async {
    if (!AppSettings().soundEnabled) return;
    await _playTone(frequency: 440, durationMs: 80);
  }

  Future<void> playWin() async {
    if (!AppSettings().soundEnabled) return;
    // Phát một chuỗi nốt vui
    await _playTone(frequency: 523, durationMs: 150);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(frequency: 659, durationMs: 150);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(frequency: 784, durationMs: 300);
  }

  Future<void> playTimeout() async {
    if (!AppSettings().soundEnabled) return;
    await _playTone(frequency: 220, durationMs: 400);
  }

  Future<void> playUndo() async {
    if (!AppSettings().soundEnabled) return;
    await _playTone(frequency: 330, durationMs: 100);
  }

  Future<void> _playTone({required int frequency, required int durationMs}) async {
    try {
      // Sử dụng data URI với WAV format đơn giản
      final bytes = Uint8List.fromList(_generateToneWav(frequency, durationMs));
      await _player.play(BytesSource(bytes), volume: 0.5);
    } catch (_) {}
  }

  // Tạo WAV bytes cho một tone đơn giản
  List<int> _generateToneWav(int frequency, int durationMs) {
    const sampleRate = 22050;
    const channels = 1;
    const bitsPerSample = 16;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final dataSize = numSamples * channels * (bitsPerSample ~/ 8);

    final bytes = <int>[];

    // WAV Header
    bytes.addAll('RIFF'.codeUnits);
    bytes.addAll(_int32LE(36 + dataSize));
    bytes.addAll('WAVE'.codeUnits);
    bytes.addAll('fmt '.codeUnits);
    bytes.addAll(_int32LE(16)); // chunk size
    bytes.addAll(_int16LE(1));  // PCM
    bytes.addAll(_int16LE(channels));
    bytes.addAll(_int32LE(sampleRate));
    bytes.addAll(_int32LE(sampleRate * channels * bitsPerSample ~/ 8));
    bytes.addAll(_int16LE(channels * bitsPerSample ~/ 8));
    bytes.addAll(_int16LE(bitsPerSample));
    bytes.addAll('data'.codeUnits);
    bytes.addAll(_int32LE(dataSize));

    // PCM samples with fade out
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = (1.0 - i / numSamples) * (1.0 - (i / numSamples) * (i / numSamples));
      final sample = (envelope * 16000 * _sin(2 * 3.14159 * frequency * t)).round();
      bytes.addAll(_int16LE(sample.clamp(-32768, 32767)));
    }

    return bytes;
  }

  double _sin(double x) {
    // Taylor series approximation for sin
    x = x % (2 * 3.14159265);
    double result = x;
    double term = x;
    for (int i = 1; i < 8; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  List<int> _int32LE(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
  List<int> _int16LE(int v) => [v & 0xFF, (v >> 8) & 0xFF];
}
