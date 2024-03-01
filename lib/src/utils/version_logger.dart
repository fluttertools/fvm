import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

/// Tracks application version and build history using a JSON file for storage.
///
/// This class provides functionality to track the history of app versions and builds,
/// identifying first launches for both the overall app, specific versions, and specific builds.
/// It uses a JSON file to persist this information across sessions.
class VersionLogger {
  final String _filePath;
  final String _currentVersion;

  /// Constructs a [VersionLogger] with paths to the JSON storage file,
  /// and the current app version and build.
  ///
  /// - `filePath`: The path to the JSON file used for storage.
  /// - `currentVersion`: The current version of the app.
  /// - `currentBuild`: The current build number of the app.
  VersionLogger({
    required String filePath,
    required String currentVersion,
    required String currentBuild,
  })  : _filePath = filePath,
        _currentVersion = currentVersion;

  /// Initializes the file for JSON storage if it does not already exist.
  Future<void> _initFile() async {
    final file = File(_filePath);
    if (!await file.exists()) {
      await file.create();
      await file.writeAsString(jsonEncode({}));
    }
  }

  /// Reads the JSON storage file and returns its contents as a Map.
  ///
  /// If the file cannot be read, returns an empty Map.
  Future<Map<String, dynamic>> _readJson() async {
    try {
      final file = File(_filePath);
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      return {};
    }
  }

  /// Writes the given Map to the JSON storage file.
  ///
  /// - `data`: The Map containing version and build histories to be written.
  Future<void> _writeJson(Map<String, dynamic> data) async {
    final file = File(_filePath);
    await file.writeAsString(jsonEncode(data));
  }

  /// Retrieves the history list for a given key from the JSON storage.
  ///
  /// - `key`: The key for which to retrieve history.
  /// Returns a list of strings representing the history, or an empty list if none.
  Future<List<String>> _getHistory(String key) async {
    final data = await _readJson();

    return List<String>.from(data[key] ?? []);
  }

  /// Updates the history for a given key in the JSON storage.
  ///
  /// - `key`: The key whose history is to be updated.
  /// - `history`: The list of strings representing the new history.
  Future<void> _updateHistory(String key, List<String> history) async {
    final data = await _readJson();
    data[key] = history;
    await _writeJson(data);
  }

  /// Applies a limit to the history list, truncating it to the specified size.
  ///
  /// - `list`: The list to be limited.
  /// - `limit`: The maximum number of items to retain in the list.
  /// Returns the truncated list.
  List<String> _applyLimit(List<String> list, int? limit) {
    if (limit != null && list.length > limit) {
      return list.sublist(list.length - limit);
    }

    return list;
  }

  Version get currentVersion => Version.parse(_currentVersion);

  String get buildNumber => currentVersion.build.toString();

  String get versionNumber => Version(
        currentVersion.major,
        currentVersion.minor,
        currentVersion.patch,
      ).toString();

  /// Tracks the current session's version and build, updating the history.
  ///
  /// Call this method at the start of your application to ensure the current
  /// version and build are tracked. Optionally, limits the history size.
  ///
  /// - `versionHistoryLimit`: The maximum number of version entries to keep.
  /// - `buildHistoryLimit`: The maximum number of build entries to keep.
  Future<void> track({
    int? versionHistoryLimit,
    int? buildHistoryLimit,
  }) async {
    // Ensure the storage file is initialized.
    await _initFile();

    var versions = await _getHistory('versions');
    var builds = await _getHistory('builds');

    // Update version history
    if (!versions.contains(versionNumber)) {
      versions.add(versionNumber);
    }

    // Update build history
    if (!builds.contains(buildNumber)) {
      builds.add(buildNumber);
    }

    // Apply history limits
    versions = _applyLimit(versions, versionHistoryLimit);
    builds = _applyLimit(builds, buildHistoryLimit);

    await _updateHistory('versions', versions);
    await _updateHistory('builds', builds);
  }
}
