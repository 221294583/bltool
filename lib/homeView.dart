import 'package:bltool/DM.dart';
import 'package:bltool/config.dart';
import 'package:bltool/homeDMView.dart';
import 'package:bltool/homeDownloadView.dart';
import 'package:bltool/navigationWidget.dart';
import 'package:flutter/material.dart';
import 'appBarWidget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomeView> {
  Config config = Config();

  int _funcIndex = 0; //左侧工具栏索引
  double _progress = 0.0;
  late String _progressPhase;

  TextEditingController urlControllerDM = TextEditingController();
  TextEditingController keyControllerDM = TextEditingController();
  TextEditingController urlControllerDL = TextEditingController();

  DM dm = DM();
  List<List<String>> _items = [];

  @override
  void initState() {
    super.initState();
    _progressPhase = config.getLang("DL_pending");
  }

  void updatefuncIndex(int index) {
    print('Home/setState/index');
    setState(() {
      _funcIndex = index;
      print('Home/setState/index: $_funcIndex');
    });
  }

  void updateDMView() {
    print('Home/setState/items');
    setState(() {
      _items = dm.get2render();
      print('Home/setState/_items: $_items');
    });
  }

  void updateDownloadView(double progress, String progressPhase) {
    print('Home/setState/progress');
    setState(() {
      if (progress < 1 && progress > 0) {
        _progress += progress;
        _progressPhase = "$progressPhase${(_progress * 100).toStringAsFixed(1)}%";
      } else {
        _progress = progress;
        _progressPhase = progressPhase;
      }
    });
  }

  getFuncView() {
    print('GETFUNCVIEW');
    switch (_funcIndex) {
      case 0:
        return getDMView(urlControllerDM, keyControllerDM, updateDMView, _items);
      case 1:
        return getDownloadView(urlControllerDL, _progress, _progressPhase, updateDownloadView);
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar([0, _funcIndex], context),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [getNavigationRail(0, _funcIndex, updatefuncIndex), VerticalDivider(width: 1), getFuncView()],
            ),
          ),
        ],
      ),
    );
  }
}
