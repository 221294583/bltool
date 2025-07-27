import 'package:bltool/cracker.dart';

Future<void> main() async {
  final cracker = Cracker();

  var result = cracker.crackL4('44be2582'); // 用16进制字符串替代
  print(result);

  // 手动释放内存（如你不再使用）
  cracker.destroy();
}
