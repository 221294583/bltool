import 'dart:io';

import 'package:bltool/appBarWidget.dart';
import 'package:bltool/config.dart';
import 'package:bltool/navigationWidget.dart';
import 'package:bltool/settingsGeneralView.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<SettingsView> {
  Config config = Config();

  int _settingsTabIndex = 0;
  late String _selectedLang;
  TextEditingController _controllerCACHE = TextEditingController();
  TextEditingController _controllerOUTPUT = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedLang = config.getAttr('lang');
    _controllerCACHE.text = config.getAttr('cache_${Platform.operatingSystem}');
    _controllerOUTPUT.text = config.getAttr('output_${Platform.operatingSystem}');
  }

  void updateSettingsTabIndex(int index) {
    setState(() {
      _settingsTabIndex = index;
    });
  }

  void updateSelectedLang(String selectedValue) {
    setState(() {
      _selectedLang = selectedValue;
    });
  }

  Widget getFuncView() {
    switch (_settingsTabIndex) {
      case 0:
        return getSettingsGeneralView(_controllerCACHE, _controllerOUTPUT, _selectedLang, updateSelectedLang);
      case 1:
        return SizedBox.shrink();
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar([1, 1], context),
      body: Column(
        children: [
          Expanded(
            child: Row(children: [getNavigationRail(1, _settingsTabIndex, updateSettingsTabIndex), getFuncView()]),
          ),
        ],
      ),
    );
  }
}
