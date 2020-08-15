import 'dart:io';
import 'package:fvm/src/cli/commands/flutter_command.dart';
import 'package:fvm/src/cli/commands/install_command.dart';
import 'package:fvm/src/cli/commands/list_command.dart';
import 'package:fvm/src/cli/commands/releases_command.dart';
import 'package:fvm/src/cli/commands/remove_command.dart';
import 'package:fvm/src/cli/runner.dart';
import 'package:fvm/src/cli/commands/use_command.dart';
import 'package:fvm/src/cli/commands/version_command.dart';
import 'package:fvm/src/utils/logger.dart';
import 'package:fvm/src/utils/logger.dart' show logger;
import 'package:io/ansi.dart';

/// Runs FVM
Future<void> fvmRunner(List<String> args) async {
  final runner = buildRunner();

  runner..addCommand(InstallCommand());
  runner..addCommand(ListCommand());
  runner..addCommand(FlutterCommand());
  runner..addCommand(RemoveCommand());
  runner..addCommand(UseCommand());
  runner..addCommand(VersionCommand());
  runner..addCommand(ReleasesCommand());

  return await runner.run(args).catchError((exc, st) {
    if (exc is String) {
      logger.stdout(exc);
    } else {
      logger.stderr('⚠️  ${yellow.wrap(exc.toString())}');
      if (args.contains('--verbose')) {
        print(st);
        throw exc;
      }
    }
    exitCode = 1;
  }).whenComplete(() {});
}
