import 'package:args/command_runner.dart';
import 'package:fvm/constants.dart';
import 'package:fvm/flutter/flutter_tools.dart';
import 'package:fvm/utils/helpers.dart';
import 'package:args/args.dart';

/// Proxies Flutter Commands
class FlutterCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.

  @override
  final name = 'flutter';
  @override
  final description = 'Proxies Flutter Commands';
  @override
  final argParser = ArgParser.allowAnything();

  /// Constructor
  FlutterCommand();

  @override
  Future<void> run() async {
    final flutterExec = getFlutterSdkExec();

    await flutterCmd(flutterExec, argResults.arguments,
        workingDirectory: kWorkingDirectory.path);
  }
}
