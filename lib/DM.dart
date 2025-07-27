import 'package:bltool/cracker.dart';
import 'package:bltool/util.dart';

class DM {
  String _url = '';
  String _keyword = '';
  List<List<String>> _allDM = [];
  List<List<String>> _filteredDM = [];
  List<int> _filteredMapping = [];

  static final DM _instance = DM._c();
  DM._c();
  factory DM() => _instance;

  Future<void> update(String url, String keyword, void Function() updateDMView) async {
    if (url.isEmpty) {
      _url = '';
      _keyword = '';
      _allDM = [];
      _filteredDM = [];
      _filteredMapping = [];
    } else {
      if (_url != url || _keyword != keyword) {
        if (_url != url) {
          _url = url;
          print('DM/update/before/header');
          final headers = await generateHeaders();
          print('DM/update/after/header');
          final info = (await getBiliVideoInfo(headers, _url));
          print('DM/update/after/info');
          _allDM = (await getDM(headers, 'xml', info[1], info[2], info[3]));
          print('DM/update/after/DM');
        }
        _keyword = keyword;
        _filteredMapping = (await filterDM(_allDM, _keyword));
        print('DM/update/after/filter');
        _filteredDM = List.generate(_filteredMapping.length, (int index) {
          return _allDM[_filteredMapping[index]];
        });
      }
    }
    updateDMView();
  }

  List<List<String>> get2render() {
    return _keyword.isEmpty ? _allDM : _filteredDM;
  }

  void crack(int index, void Function() updateDMView) {
    Cracker cracker = Cracker();
    final temp = cracker.crackL4(_allDM[_filteredMapping[index]][1]);
    if (temp[1] == 1) {
      _allDM[_filteredMapping[index]].add(temp[0]);
      _filteredDM[index].add(temp[0]);
    }
    updateDMView();
  }

  void destroy() {
    _url = '';
    _keyword = '';
    _allDM.clear();
    _filteredDM.clear();
  }
}
