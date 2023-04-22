import 'dart:math';

String generateNumericUuid() {
  final random = Random();
  final maxIntValue = pow(10, 9).toInt(); // Generate integers up to 1 billion
  final numericUuid = random.nextInt(maxIntValue);
  return numericUuid.toString();
}
