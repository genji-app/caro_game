// CLI tool to export caxilo_config presets to JSON and base64 files.
//
// COMMANDS
//
// Generate from Dart presets (source of truth):
//   dart run packages/caxilo_config/tool/export_config.dart
//   dart run packages/caxilo_config/tool/export_config.dart dev
//   dart run packages/caxilo_config/tool/export_config.dart all conductor/config_exports
//
// Encode an already-edited JSON file → .b64 (without regenerating from preset):
//   dart run packages/caxilo_config/tool/export_config.dart --encode conductor/config_exports/caxilo_config_staging.json
//   dart run packages/caxilo_config/tool/export_config.dart --encode my_custom.json out/custom.b64
//
// ARGUMENTS (generate mode)
//   [env]        dev | staging | prod | all  (default: all)
//   [output_dir] destination directory       (default: conductor/config_exports)
//
// ARGUMENTS (--encode mode)
//   json_file    path to the .json file to encode
//   [b64_file]   output path (default: same name, .b64 extension)

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:caxilo_config/presets.dart';

void main(List<String> args) {
  if (args.firstOrNull == '--encode') {
    _runEncodeMode(args.skip(1).toList());
  } else {
    _runGenerateMode(args);
  }
}

// ---------------------------------------------------------------------------
// Generate mode — build from Dart presets
// ---------------------------------------------------------------------------

void _runGenerateMode(List<String> args) {
  final envArg = args.firstOrNull ?? 'all';
  final outputDir = args.elementAtOrNull(1) ?? 'packages/caxilo_config/config_exports';

  final List<CaxiloEnvironment> envs;
  if (envArg == 'all') {
    envs = CaxiloEnvironment.values;
  } else {
    try {
      envs = [CaxiloEnvironment.values.byName(envArg)];
    } catch (_) {
      stderr.writeln('❌ Unknown environment: "$envArg"');
      stderr.writeln('   Valid values: dev | staging | prod | all');
      exit(1);
    }
  }

  Directory(outputDir).createSync(recursive: true);

  for (final env in envs) {
    final name = env.name;

    final jsonPath = '$outputDir/caxilo_config_$name.json';
    final b64Path = '$outputDir/caxilo_config_$name.b64';

    File(jsonPath).writeAsStringSync(CaxiloConfigPresets.toJsonString(env));
    File(b64Path).writeAsStringSync(CaxiloConfigPresets.toBase64String(env));

    print('✅ [$name]  $jsonPath');
    print('           $b64Path');
  }

  print('');
  print('Done. Generated ${envs.length * 2} files in: $outputDir/');
  print('');
  print('Tip: Host *.b64 on GitHub raw → use as CASINO_CONFIG_URL.');
  print('Tip: Use *.b64 locally → make run-local-staging / run-local-prod.');
}

// ---------------------------------------------------------------------------
// Encode mode — re-encode an edited .json → .b64
// ---------------------------------------------------------------------------

void _runEncodeMode(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('❌ --encode requires at least one JSON file path.');
    stderr.writeln('   Usage: dart run tool/export_config.dart --encode <file.json> [out.b64]');
    exit(1);
  }

  // Support multiple input files when no explicit output is given
  final hasExplicitOutput = args.length == 2 && !args[1].endsWith('.json');

  final pairs = hasExplicitOutput
      ? [(input: args[0], output: args[1])]
      : args.map((f) => (input: f, output: f.replaceAll(RegExp(r'\.json$'), '.b64'))).toList();

  for (final pair in pairs) {
    final inputFile = File(pair.input);
    if (!inputFile.existsSync()) {
      stderr.writeln('❌ File not found: ${pair.input}');
      exit(1);
    }

    // Validate JSON before encoding
    final jsonString = inputFile.readAsStringSync();
    try {
      jsonDecode(jsonString);
    } catch (e) {
      stderr.writeln('❌ Invalid JSON in ${pair.input}: $e');
      exit(1);
    }

    final b64 = base64Encode(utf8.encode(jsonString));
    File(pair.output).writeAsStringSync(b64);
    print('✅ ${pair.input}  →  ${pair.output}');
  }
}
