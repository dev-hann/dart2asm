import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  final res = await Process.run(
    "dart",
    [
      "compile",
      "exe",
      "--verbose",
      "--extra-gen-snapshot-options=--print-flow-graph-optimized",
      "--extra-gen-snapshot-options=--disassemble",
      "--extra-gen-snapshot-options=--print-flow-graph-filter=main",
      "./example/example.dart",
    ],
    // runInShell: true,
  );
  final file = File("./a.text");
  if (!file.existsSync()) {
    file.createSync();
  }
  parseAssemblyFromStderr(res.stderr);
  // file.writeAsStringSync(parseAssemblyFromStderr(res.stderr));
  file.writeAsStringSync(res.stderr);
  // print(res.stdout);
}

String parseAssemblyFromStderr(String inputText) {
  List<String> errorLines = [];
  List<String> assemblyLines = [];

  bool inBlock = false;
  bool inAssembly = false;
  final RegExp blockStart = RegExp(r"^(.+)\{$");
  final RegExp assemblyStart =
      RegExp(r"^Code for (?:optimized )?function '(.+)' ", multiLine: true);
  final RegExp blockEnd = RegExp(r"}");
  final RegExp whitespace = RegExp(r"\s+");
  for (String line in LineSplitter.split(inputText)) {
    if (inBlock) {
      if (blockEnd.hasMatch(line)) {
        inBlock = false;
        inAssembly = false;
      } else if (inAssembly) {
        List<String> columns = line.split(whitespace);
        // Remove the first two columns if they're addresses, e.g.
        // 0x3279c94    e3500000               cmp r0, #0
        // And add extra indent to the ;; comment lines.
        // HACK: Unclear why this is columns[1] and columns.first is whitespace?
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
          print(line);
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
  return errorLines.join('\n') + assemblyLines.join('\n');
  // return AssemblyParserResult(errorLines.join('\n'), assemblyLines.join('\n'));
}
