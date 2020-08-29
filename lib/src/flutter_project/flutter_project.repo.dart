import 'dart:io';

import 'package:fvm/fvm.dart';
import 'package:fvm/src/flutter_tools/git_tools.dart';
import 'package:path/path.dart';

class FlutterProjectRepo {
  final Directory rootDir;
  FlutterProjectRepo(this.rootDir);
  Future<FlutterProject> getOne(Directory directory) async {
    final pubspecFile = File(join(directory.path, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      return null;
    }
    final currentGitBranch = await getCurrentGitBranch(directory);
    return FlutterProject(directory, gitBranch: currentGitBranch);
    // Add only if its flutter project
  }

  /// Retrieves all Flutter projects in rootDir
  Future<List<FlutterProject>> getAll() async {
    final projects = <FlutterProject>[];
    // Find directories recursively
    await for (FileSystemEntity entity in rootDir.list(
      recursive: true,
      followLinks: false,
    )) {
      // Check if entity is directory
      if (entity is Directory) {
        final project = await getOne(entity);
        // Add only if its flutter project
        if (project != null && await project.isFlutterProject()) {
          projects.add(project);
        }
      }
    }
    return projects;
  }
}
