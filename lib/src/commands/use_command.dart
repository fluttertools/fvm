import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import '../models/valid_version_model.dart';
import '../services/flutter_tools.dart';
import '../services/git_tools.dart';
import '../services/ide_service.dart';
import '../services/project_service.dart';
import '../utils/console_utils.dart';
import '../utils/logger.dart';
import '../workflows/use_version.workflow.dart';
import 'base_command.dart';

/// Use an installed SDK version
class UseCommand extends BaseCommand {
  @override
  final name = 'use';

  @override
  String description =
      'Sets Flutter SDK Version you would like to use in a project';

  @override
  String get invocation => 'fvm use {version}';

  /// Constructor
  UseCommand() {
    argParser
      ..addFlag(
        'force',
        help: 'Skips command guards that does Flutter project checks.',
        abbr: 'f',
        negatable: false,
      )
      ..addFlag(
        'pin',
        help:
            '''If version provided is a channel. Will pin the latest release of the channel''',
        abbr: 'p',
        negatable: false,
      )
      ..addOption(
        'flavor',
        help: 'Sets version for a project flavor',
        defaultsTo: null,
      )
      ..addFlag(
        'config-vsc',
        help: 'Configures VSCode to use FVM',
        abbr: 'c',
        negatable: false,
      );
  }
  @override
  Future<int> run() async {
    final forceOption = boolArg('force');
    final pinOption = boolArg('pin');
    final flavorOption = stringArg('flavor');
    final configVSC = boolArg('config-vsc');

    String? version;

    // If no version was passed as argument check project config.
    if (argResults!.rest.isEmpty) {
      version = await ProjectService.findVersion();

      // If no config found, ask which version to select.
      version ??= await cacheVersionSelector();
    }

    // Get version from first arg
    version ??= argResults!.rest[0];

    // throw UsageException('Usage exception', usage.);

    // Get valid flutter version. Force version if is to be pinned.
    var validVersion = ValidVersion(version);

    /// Cannot pin master channel
    if (pinOption && validVersion.isMaster) {
      throw UsageException(
        'Cannot pin a version from "master" channel.',
        usage,
      );
    }

    /// Pin release to channel
    if (pinOption && validVersion.isChannel) {
      Logger.info(
        'Pinning version $validVersion fron "$version" release channel...',
      );
      validVersion = await FlutterTools.inferReleaseFromChannel(validVersion);
    }

    if (configVSC) {
      await IDEService.configureVsCodeSettings();
    }

    // Checks if should write gitignore file
    await GitTools.writeGitIgnore();

    /// Run use workflow
    await useVersionWorkflow(
      validVersion,
      force: forceOption,
      flavor: flavorOption,
    );

    return ExitCode.success.code;
  }
}
