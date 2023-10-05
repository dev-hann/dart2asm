import 'dart:io';

void main(List<String> arguments) async {
  final res = await Process.run(
    "dart",
    [
      "compile",
      "exe",
      "--verbose",
      "--extra-gen-snapshot-options=--print-flow-graph-optimizel",
      "--extra-gen-snapshot-options=--disassemble",
      "--extra-gen-snapshot-options=--print-flow-graph-filter=main",
      "./example/example.dart",
    ],
  );
  print(res.stdout);
}
