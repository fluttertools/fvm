import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/cache_flutter_version_model.dart';
import '../models/flutter_version_model.dart';
import '../utils/context.dart';
import '../utils/extensions.dart';
import 'base_service.dart';
import 'cache_service.dart';

class GlobalVersionService extends ContextService {
  const GlobalVersionService(super.context);

  Link get _globalCacheLink => Link(context.globalCacheLink);

  static GlobalVersionService get fromContext => getProvider();

  /// Sets a [CacheFlutterVersion] as global
  void setGlobal(CacheFlutterVersion version) {
    context.globalCacheLink.link.createLink(version.directory);
  }

  /// Returns a global [CacheFlutterVersion] if exists
  CacheFlutterVersion? getGlobal() {
    if (!_globalCacheLink.existsSync()) return null;
    // Get directory name
    final version = path.basename(_globalCacheLink.targetSync());
    // Make sure its a valid version
    final validVersion = FlutterVersion.parse(version);

    // Verify version is cached
    return CacheService(context).getVersion(validVersion);
  }

  /// Checks if a cached [version] is configured as global
  bool isGlobal(CacheFlutterVersion version) {
    if (!_globalCacheLink.existsSync()) return false;

    return _globalCacheLink.targetSync() == version.directory;
  }

  /// Returns a global version name if exists
  String? getGlobalVersion() {
    if (!_globalCacheLink.existsSync()) return null;

    // Get directory name
    return path.basename(_globalCacheLink.targetSync());
  }
}
