void main() {
  // final input = int.parse(stdin.readLineSync() ?? "0");
  // int c = add(1, 1000);
  // print(DateTime.now());
  int a = DateTime.now().second;
  int b = 5;
  int c = a + b + add();
  print(c);
}

int add() {
  return DateTime.now().minute;
}
