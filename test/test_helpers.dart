import 'package:fvm/fvm.dart';

import 'package:fvm/src/releases_api/releases_client.dart';

// git clone --mirror https://github.com/flutter/flutter.git ~/gitcaches/flutter.reference
// git clone --reference ~/gitcaches/flutter.reference https://github.com/flutter/flutter.git

String release = '1.17.4';
String channel = 'beta';
String channelVersion;

void cleanup() {
  //TODO: Move this to another directory for testing
  // final fvmHomeDir = Directory(fvmHome);
  // if (fvmHomeDir.existsSync()) {
  //   fvmHomeDir.deleteSync(recursive: true);
  // }
  final project = FlutterProject.find();
  if (project.pinnedVersion != null) {
    // Used just for testing
    // TODO: add this back
    // FlutterProject.findProjectDir().deleteSync(recursive: true);
  }
}

void fvmTearDownAll() {
  cleanup();
}

void fvmSetUpAll() async {
  // Looks just like Teardown rightnow bu
  // will probalby change. Just to guarantee a clean run
  cleanup();
  final releases = await fetchFlutterReleases();
  channelVersion = releases.channels[channel].version;
}
