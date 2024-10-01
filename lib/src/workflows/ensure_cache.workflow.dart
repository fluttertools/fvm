import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

import '../models/cache_flutter_version_model.dart';
import '../models/flutter_version_model.dart';
import '../services/cache_service.dart';
import '../services/config_repository.dart';
import '../services/flutter_service.dart';
import '../services/logger_service.dart';
import '../services/releases_service/releases_client.dart';
import '../utils/context.dart';
import '../utils/exceptions.dart';
import '../utils/helpers.dart';

/// Ensures that the specified Flutter SDK version is cached locally.
///
/// Returns a [CacheFlutterVersion] which represents the locally cached version.
Future<CacheFlutterVersion> ensureCacheWorkflow(
  String version, {
  bool shouldInstall = false,
  bool force = false,
}) async {
  _validateContext();
  _validateGit();
  // Get valid flutter version
  final validVersion = await validateFlutterVersion(version, force: force);
  try {
    final cacheVersion = CacheService.fromContext.getVersion(validVersion);

    if (cacheVersion != null) {
      final integrity =
          await CacheService.fromContext.verifyCacheIntegrity(cacheVersion);

      if (integrity == CacheIntegrity.invalid) {
        return await _handleNonExecutable(
          cacheVersion,
          shouldInstall: shouldInstall,
        );
      }

      if (integrity == CacheIntegrity.versionMismatch &&
          !force &&
          !validVersion.isCustom) {
        return await _handleVersionMismatch(cacheVersion);
      } else if (force) {
        logger
            .warn('Not checking for version mismatch as --force flag is set.');
      } else if (validVersion.isCustom) {
        logger.warn(
          'Not checking for version mismatch as custom version is being used.',
        );
      }

      // If should install notify the user that is already installed
      if (shouldInstall) {
        logger.success(
          'Flutter SDK: ${cyan.wrap(cacheVersion.printFriendlyName)} is already installed.',
        );
      }

      return cacheVersion;
    }

    if (validVersion.isCustom) {
      throw AppException('Custom Flutter SDKs must be installed manually.');
    }

    if (!shouldInstall) {
      logger.info(
        'Flutter SDK: ${cyan.wrap(validVersion.printFriendlyName)} is not installed.',
      );

      if (!force) {
        final shouldInstallConfirmed = logger.confirm(
          'Would you like to install it now?',
          defaultValue: true,
        );

        if (!shouldInstallConfirmed) {
          exit(ExitCode.unavailable.code);
        }
      }
    }

    bool useGitCache = ctx.gitCache;

    if (useGitCache) {
      try {
        await FlutterService.fromContext.updateLocalMirror();
      } on Exception {
        useGitCache = false;
        logger.warn(
          'Failed to setup local cache. Falling back to git clone.',
        );
        logger.info('Git cache will be disabled.');
        try {
          final config = ConfigRepository.loadAppConfig();
          final updatedConfig = config.copyWith(useGitCache: false);
          ConfigRepository.save(updatedConfig);
          logger.success('Git cache has been disabled.');
        } on Exception {
          logger.warn('Failed to update config file');
        }
      }
    }

    final progress = logger.progress(
      'Installing Flutter SDK: ${cyan.wrap(validVersion.printFriendlyName)}',
    );
    try {
      await FlutterService.fromContext.install(
        validVersion,
        useGitCache: useGitCache,
      );

      progress.complete(
        'Flutter SDK: ${cyan.wrap(validVersion.printFriendlyName)} installed!',
      );
    } on Exception {
      progress.fail('Failed to install ${validVersion.name}');
      rethrow;
    }

    final newCacheVersion = CacheService.fromContext.getVersion(validVersion);
    if (newCacheVersion == null) {
      throw AppException('Could not verify cache version $validVersion');
    }

    return newCacheVersion;
  } on Exception {
    logger.fail('Failed to ensure $validVersion is cached.');
    rethrow;
  }
}

// More user-friendly explanation of what went wrong and what will happen next
Future<CacheFlutterVersion> _handleNonExecutable(
  CacheFlutterVersion version, {
  required bool shouldInstall,
}) async {
  logger
    ..notice(
      'Flutter SDK version: ${version.name} isn\'t executable, indicating the cache is corrupted.',
    )
    ..spacer;

  final shouldReinstall = logger.confirm(
    'Would you like to reinstall this version to resolve the issue?',
    defaultValue: true,
  );

  if (shouldReinstall) {
    CacheService.fromContext.remove(version);
    logger.info(
      'The corrupted SDK version is now being removed and a reinstallation will follow...',
    );

    return ensureCacheWorkflow(version.name, shouldInstall: shouldInstall);
  }

  throw AppException('Flutter SDK: ${version.name} is not executable.');
}

// Clarity on why the version mismatch happened and how it can be fixed
Future<CacheFlutterVersion> _handleVersionMismatch(
  CacheFlutterVersion version,
) {
  logger
    ..notice(
      'Version mismatch detected: cache version is ${version.flutterSdkVersion}, but expected ${version.name}.',
    )
    ..info(
      'This can occur if you manually run "flutter upgrade" on a cached SDK.',
    )
    ..spacer;

  final firstOption =
      'Move ${version.flutterSdkVersion} to the correct cache directory and reinstall ${version.name}';

  final secondOption = 'Remove incorrect version and reinstall ${version.name}';

  final selectedOption = logger.select(
    'How would you like to resolve this?',
    options: [firstOption, secondOption],
  );

  if (selectedOption == firstOption) {
    logger.info('Moving SDK to the correct cache directory...');
    CacheService.fromContext.moveToSdkVersionDiretory(version);
  }

  logger.info('Removing incorrect SDK version...');
  CacheService.fromContext.remove(version);

  return ensureCacheWorkflow(version.name, shouldInstall: true);
}

Future<FlutterVersion> validateFlutterVersion(
  String version, {
  bool force = false,
}) async {
  final flutterVersion = FlutterVersion.parse(version);

  if (force) {
    return flutterVersion;
  }

  // If its channel or commit no need for further validation
  if (flutterVersion.isChannel || flutterVersion.isCustom) {
    return flutterVersion;
  }

  if (flutterVersion.isRelease) {
    // Check version incase it as a releaseChannel i.e. 2.2.2@beta
    final isTag =
        await FlutterService.fromContext.isTag(flutterVersion.version);
    if (isTag) {
      return flutterVersion;
    }

    final isVersion =
        await FlutterReleasesClient.isVersionValid(flutterVersion.version);

    if (isVersion) {
      return flutterVersion;
    }
  }

  if (flutterVersion.isCommit) {
    final commitSha = await FlutterService.fromContext.getReference(version);
    if (commitSha != null) {
      if (commitSha != flutterVersion.name) {
        return FlutterVersion.commit(commitSha);
      }

      return flutterVersion;
    }
  }

  logger.notice('Flutter SDK: ($version) is not valid Flutter version');

  final askConfirmation = logger.confirm(
    'Do you want to continue?',
    defaultValue: false,
  );
  if (askConfirmation) {
    // Jump a line after confirmation
    logger.spacer;

    return flutterVersion;
  }

  throw AppException('$version is not a valid Flutter version');
}

void _validateContext() {
  final isValid = isValidGitUrl(ctx.flutterUrl);
  if (!isValid) {
    throw AppException(
      'Invalid Flutter URL: "${ctx.flutterUrl}". Please change config to a valid git url',
    );
  }
}

void _validateGit() {
  final isGitInstalled = Process.runSync('git', ['--version']).exitCode == 0;
  if (!isGitInstalled) {
    throw AppException('Git is not installed');
  }
}
