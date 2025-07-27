import 'dart:convert';

class Cracker {
  static Cracker? _instance = Cracker._c();

  final List<int> crc32Table = [];
  final List<int> ini5Table = [];

  factory Cracker() {
    return _instance ??= Cracker._c();
  }

  Cracker._c() {
    final polyRev = 0xedb88320;

    // 生成 CRC32 查找表
    for (int byte = 0; byte < 256; byte++) {
      int op = byte;
      for (int bit = 0; bit < 8; bit++) {
        if ((op & 1) != 0) {
          op = (op >> 1) ^ polyRev;
        } else {
          op >>= 1;
        }
      }
      crc32Table.add(op);
    }

    // 生成预计算表
    for (int i = 0; i < 1000000; i++) {
      ini5Table.add(crc32PolyRev(i.toString()));
    }
  }

  void destroy() {
    _instance = null;
  }

  int crc32PolyRev(String line) {
    int temp = 0xffffffff;
    for (var ch in utf8.encode(line)) {
      int op = (ch ^ temp) & 0xff;
      temp = crc32Table[op] ^ (temp >> 8);
    }
    return temp;
  }

  /// 查找符合某段 CRC 结果的 table 值和索引
  List<dynamic>? finder(int num) {
    for (int i = 0; i < 256; i++) {
      if (num == (crc32Table[i] >> 24)) {
        return [crc32Table[i], i];
      }
    }
    return null;
  }

  /// 查找前五位 CRC 匹配项，排除 exceptions 中的项
  List<dynamic>? matcher(int num, List<int> exceptions) {
    for (int i = 0; i < ini5Table.length; i++) {
      List<int> a = [
        (ini5Table[i] >> 28) & 0xf,
        (ini5Table[i] >> 20) & 0xf,
        (ini5Table[i] >> 12) & 0xf,
        (ini5Table[i] >> 4) & 0xf,
      ];
      List<int> b = [(num >> 28) & 0xf, (num >> 20) & 0xf, (num >> 12) & 0xf, (num >> 4) & 0xf];
      if (_listEqual(a, b) && !exceptions.contains(ini5Table[i])) {
        return [ini5Table[i], i.toString()];
      }
    }
    return null;
  }

  String? crcAny(int ini, List<int> l4set) {
    int temp = ini;
    List<String> numSet = [];
    for (int each in l4set) {
      int index = each;
      int order = index ^ (temp & 0xff);
      if (order > 0x39 || order < 0x30) return null;
      numSet.add(String.fromCharCode(order));
      temp = crc32Table[index] ^ (temp >> 8);
    }
    return numSet.join();
  }

  /// 主逻辑：通过 CRC 倒推编号
  List<dynamic> crackL4(String line) {
    int ori = int.parse(line, radix: 16) ^ 0xffffffff;
    int temp = ori;
    List<int> last4 = List.filled(4, 0);

    for (int i = 0; i < 4; i++) {
      int f2 = temp >> 24;
      var found = finder(f2);
      if (found == null) return ['', -1];
      int tableVar = found[0];
      int tableIndex = found[1];
      int var6 = temp ^ tableVar;
      temp = (var6 << 8);
      int adder = tableIndex ^ 0x30;
      temp ^= adder;
      temp = ((temp >> 4) << 4);
      last4[3 - i] = tableIndex;
    }

    List<int> exceptions = [];
    String? l4Index;
    int? f6;
    String? f6Str;

    while (l4Index == null) {
      var matched = matcher(temp, exceptions);
      if (matched == null) break;
      f6 = matched[0];
      f6Str = matched[1];
      l4Index = crcAny(f6!, last4);
      if (l4Index == null) {
        exceptions.add(f6);
      }
    }

    if (l4Index != null && f6Str != null) {
      return ['${f6Str}${l4Index}', 1];
    }

    return ['', -1];
  }

  bool _listEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
