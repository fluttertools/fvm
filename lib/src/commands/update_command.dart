import 'dart:io';

import 'package:args/command_runner.dart';
import '../utils/constants.dart';
import '../services/logger_service.dart';
import '../version.g.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

import '../../constants.dart';
import '../services/logger_service.dart';
import '../version.g.dart';

class UpdateCommand extends Command<int> {
  static const String commandName = 'update';

  final PubUpdater _pubUpdater;

  UpdateCommand({PubUpdater? pubUpdater})
      : _pubUpdater = pubUpdater ?? PubUpdater();

  @override
  Future<int> run() async {
    final updateCheckProgress = logger.progress('Checking for updates');
    final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(kPackageName);
    } catch (error) {
      updateCheckProgress.fail();
      logger.err('$error');

      return ExitCode.software.code;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      logger.success('You are already using the latest version.');

      return ExitCode.success.code;
    }

    switch (deployType) {
      case 'brew':
        final upgradeCommand = cyan.wrap('brew upgrade $kPackageName');
        logger
          ..info('')
          ..info('This version was installed using brew.')
          ..notice('Please update using: $upgradeCommand');

        return ExitCode.success.code;
      case 'chocolatey':
        final upgradeCommand = cyan.wrap('choco upgrade $kPackageName');
        logger
          ..info('')
          ..info('This version was installed using chocolatey.')
          ..notice('Please update using: $upgradeCommand');

        return ExitCode.success.code;
      default:
        break;
    }

    final updateProgress = logger.progress('Updating to $latestVersion');

    late final ProcessResult result;
    try {
      result = await _pubUpdater.update(
        packageName: kPackageName,
        versionConstraint: latestVersion,
      );
    } catch (error) {
      updateProgress.fail();
      logger.err('$error');

      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      updateProgress.fail();
      logger.err('Error updating CLI: ${result.stderr}');

      return ExitCode.software.code;
    }

    updateProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }

  @override
  String get description => 'Update the CLI.';

  @override
  String get name => commandName;
}
