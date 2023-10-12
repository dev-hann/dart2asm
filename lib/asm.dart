import 'dart:convert';
import 'dart:io';

class Assemble {
  Assemble(this.path);
  final String path;

  ProcessResult _runSync() {
    return Process.runSync(
      "dart",
      [
        "compile",
        "exe",
        "--verbose",
        "--extra-gen-snapshot-options=--print-flow-graph-optimized",
        "--extra-gen-snapshot-options=--disassemble",
        "--extra-gen-snapshot-options=--print-flow-graph-filter=main",
        path,
      ],
    );
  }

  String runSync() {
    final inputText = _runSync().stderr;
    final errorLines = [];
    final assemblyLines = [];

    bool inBlock = false;
    bool inAssembly = false;
    final blockStart = RegExp(r"^(.+)\{$");
    final assemblyStart = RegExp(
      r"^Code for (?:optimized )?function '(.+)' ",
      multiLine: true,
    );
    final blockEnd = RegExp(r"}");
    final whitespace = RegExp(r"\s+");
    for (String line in LineSplitter.split(inputText)) {
      if (inBlock) {
        if (blockEnd.hasMatch(line)) {
          inBlock = false;
          inAssembly = false;
        } else if (inAssembly) {
          final columns = line.split(whitespace);
          if (columns[1] == ";;") {
            line = "    $line";
          } else if (int.tryParse(columns.first) != null) {
            line = "        ${columns.sublist(2).join(' ')}";
          }
          assemblyLines.add(line);
        }
      } else {
        if (blockStart.hasMatch(line)) {
          inBlock = true;
          Match? match = assemblyStart.matchAsPrefix(line);
          if (match != null) {
            inAssembly = true;
            // Add fake label:
            String functionPath = match.group(1)!;
            String functionName = functionPath.split('::').last;
            // Remove the leading _ to avoid auto-hiding them.
            // functionName = functionName.substring(1);
            assemblyLines.add('$functionName:');
          }
        } else {
          errorLines.add(line);
        }
      }
    }
    return "${assemblyLines.join("\n")}\n\n${errorLines.join("\n")}";
  }
}
