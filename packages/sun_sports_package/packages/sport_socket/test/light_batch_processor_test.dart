import 'dart:async';

import 'package:test/test.dart';
import 'package:sport_socket/src/processor/light_batch_processor.dart';
import 'package:sport_socket/src/proto/proto.dart';

void main() {
  group('LightBatchProcessor', () {
    late LightBatchProcessor processor;

    setUp(() {
      processor = LightBatchProcessor(
        batchInterval: const Duration(milliseconds: 20),
        maxBatchSize: 10,
      );
    });

    tearDown(() {
      processor.dispose();
    });

    test('starts in not running state', () {
      expect(processor.isRunning, isFalse);
      expect(processor.bufferSize, equals(0));
    });

    test('auto-starts when payload is added', () {
      final payload = Payload()..channel = 'test:channel';
      processor.add(payload);

      expect(processor.isRunning, isTrue);
    });

    test('buffers payloads until flush', () {
      processor.start();

      final payload1 = Payload()..channel = 'test:1';
      final payload2 = Payload()..channel = 'test:2';

      processor.add(payload1);
      processor.add(payload2);

      expect(processor.bufferSize, equals(2));
    });

    test('flushes buffer on timer', () async {
      final batches = <List<Payload>>[];
      processor.onBatch = (batch) => batches.add(batch);

      processor.start();

      final payload1 = Payload()..channel = 'test:1';
      final payload2 = Payload()..channel = 'test:2';

      processor.add(payload1);
      processor.add(payload2);

      // Wait for timer to fire
      await Future.delayed(const Duration(milliseconds: 50));

      expect(batches.length, equals(1));
      expect(batches[0].length, equals(2));
      expect(processor.bufferSize, equals(0));
    });

    test('flushes immediately when maxBatchSize reached', () {
      final batches = <List<Payload>>[];
      processor.onBatch = (batch) => batches.add(batch);

      processor.start();

      // Add more than maxBatchSize (10)
      for (var i = 0; i < 15; i++) {
        processor.add(Payload()..channel = 'test:$i');
      }

      // First batch should have been flushed immediately
      expect(batches.length, greaterThanOrEqualTo(1));
      expect(batches[0].length, equals(10));

      // Remaining 5 in buffer
      expect(processor.bufferSize, equals(5));
    });

    test('manual flush works', () {
      final batches = <List<Payload>>[];
      processor.onBatch = (batch) => batches.add(batch);

      processor.start();

      processor.add(Payload()..channel = 'test:1');
      processor.add(Payload()..channel = 'test:2');

      processor.flush();

      expect(batches.length, equals(1));
      expect(batches[0].length, equals(2));
      expect(processor.bufferSize, equals(0));
    });

    test('stop flushes remaining buffer', () {
      final batches = <List<Payload>>[];
      processor.onBatch = (batch) => batches.add(batch);

      processor.start();

      processor.add(Payload()..channel = 'test:1');

      processor.stop();

      expect(batches.length, equals(1));
      expect(processor.isRunning, isFalse);
    });

    test('addAll adds multiple payloads', () {
      processor.start();

      final payloads = [
        Payload()..channel = 'test:1',
        Payload()..channel = 'test:2',
        Payload()..channel = 'test:3',
      ];

      processor.addAll(payloads);

      expect(processor.bufferSize, equals(3));
    });

    test('statistics track correctly', () {
      processor.start();

      for (var i = 0; i < 5; i++) {
        processor.add(Payload()..channel = 'test:$i');
      }

      processor.flush();

      final stats = processor.getStats();

      expect(stats.receivedTotal, equals(5));
      expect(stats.processedTotal, equals(5));
      expect(stats.batchesTotal, equals(1));
      expect(stats.avgBatchSize, equals(5));
      expect(stats.bufferSize, equals(0));
    });

    test('resetStats clears statistics', () {
      processor.start();

      for (var i = 0; i < 5; i++) {
        processor.add(Payload()..channel = 'test:$i');
      }
      processor.flush();

      processor.resetStats();

      final stats = processor.getStats();
      expect(stats.receivedTotal, equals(0));
      expect(stats.processedTotal, equals(0));
      expect(stats.batchesTotal, equals(0));
    });

    test('empty buffer does not emit batch', () {
      var batchCount = 0;
      processor.onBatch = (_) => batchCount++;

      processor.start();
      processor.flush();

      expect(batchCount, equals(0));
    });

    test('preserves payload data through batching', () async {
      List<Payload>? receivedBatch;
      processor.onBatch = (batch) => receivedBatch = batch;

      processor.start();

      final payload = Payload()
        ..channel = 'ln:vi:s:1:e'
        ..type = 'u'
        ..timeRange = 1;

      processor.add(payload);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedBatch, isNotNull);
      expect(receivedBatch!.length, equals(1));
      expect(receivedBatch![0].channel, equals('ln:vi:s:1:e'));
      expect(receivedBatch![0].type, equals('u'));
      expect(receivedBatch![0].timeRange, equals(1));
    });
  });
}
