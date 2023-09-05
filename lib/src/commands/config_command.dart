import 'package:io/ansi.dart';
import 'package:io/io.dart';

import '../services/context.dart';
import '../services/settings_service.dart';
import '../utils/logger.dart';
import 'base_command.dart';

/// Fvm Config
class ConfigCommand extends BaseCommand {
  @override
  final name = 'config';

  @override
  final description = 'Set configuration for FVM';

  /// Constructor
  ConfigCommand() {
    argParser
      ..addOption(
        'cache-path',
        help: 'Set the path which FVM will cache the version.'
            ' Priority over FVM_HOME.',
        abbr: 'c',
      )
      ..addFlag(
        'git-cache',
        help: 'ADVANCED: Will cache a local version of'
            ' Flutter repo for faster version install.',
        abbr: 'g',
        negatable: true,
        defaultsTo: null,
      );
  }
  @override
  Future<int> run() async {
    // Flag if settings should be saved
    var shouldSave = false;

    // Cache path was set
    if (argResults!.wasParsed('cache-path')) {
      ctx.settings.cachePath = stringArg('cache-path');
      shouldSave = true;
    }

    // Git cache option has changed
    if (argResults!.wasParsed('git-cache')) {
      ctx.settings.gitCacheDisabled = !boolArg('git-cache');
      shouldSave = true;
    }

    // Save
    if (shouldSave) {
      // Update settings
      await ctx.settings.save();
      Logger.fine('Settings saved.');
    } else {
      Logger.spacer();
      Logger.fine('FVM Settings:');
      Logger.info('Located at ${SettingsService.settingsFile.path}\n');

      final options = ctx.settings.toMap();

      if (options.keys.isEmpty) {
        Logger.info('No settings have been configured.\n');
      } else {
        // Print options and it's values
        for (var key in options.keys) {
          final value = options[key];
          if (value != null) {
            final valuePrint = yellow.wrap(value.toString());
            Logger.info('$key: $valuePrint');
          }
        }
      }
    }

    return ExitCode.success.code;
  }
}
