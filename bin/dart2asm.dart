import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart2asm/asm.dart';

void main(List<String> arguments) async {
  var runner = CommandRunner('dart2asm', "dart code convert to assembly code.");
  runner.argParser.addOption(
    "output",
    abbr: "o",
    defaultsTo: "output.txt",
  );
  ArgResults result;
  try {
    result = runner.parse(arguments);
  } catch (e) {
    print("$e\n");
    exit(0);
  }
  final isHelp = result["help"];
  if (isHelp) {
    print([runner.usage]);
    exit(0);
  }
  final output = result["output"];
  final input = result.rest.last;
  final ext = input.split(".").last;
  if (ext != "dart") {
    print("dart2asm: Input file must be dart file!");
    exit(0);
  }

  final asm = Assemble(input);
  final asmText = asm.runSync();

  final file = File(output);
  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsStringSync(asmText);
}
