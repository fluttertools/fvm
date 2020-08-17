import 'dart:convert';
import 'dart:io';
import 'package:fvm/constants.dart';

import 'package:fvm/src/flutter_project/project_config.model.dart';
import 'package:fvm/src/utils/helpers.dart';
import 'package:fvm/src/flutter_tools/flutter_helpers.dart';

/// Check if it is the current version.
bool isCurrentVersion(String version) {
  final configVersion = readProjectConfig().flutterSdkVersion;
  return version == configVersion;
}

void setAsProjectVersion(String version) {
  if (kProjectFvmConfigJson.existsSync() == false) {
    kProjectFvmConfigJson.createSync(recursive: true);
  }
  saveProjectConfig(ProjectConfig(version));
  updateFlutterSdkBinLink();
}

void updateFlutterSdkBinLink() {
  final flutterSdk = getFlutterSdkPath();
  createLink(kProjectFvmSdkSymlink, File(flutterSdk));
}

ProjectConfig readProjectConfig({File projectConfig}) {
  try {
    projectConfig ??= kProjectFvmConfigJson;
    final jsonString = projectConfig.readAsStringSync();
    final projectConfigMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return ProjectConfig.fromJson(projectConfigMap);
  } on Exception {
    return ProjectConfig(null);
  }
}

void saveProjectConfig(ProjectConfig config) {
  kProjectFvmConfigJson.writeAsStringSync(jsonEncode(config));
}
