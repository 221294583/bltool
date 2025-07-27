import 'dart:io';

import 'package:bltool/config.dart';
import 'package:flutter/material.dart';

Widget getSettingsGeneralView(
  TextEditingController controllerCACHE,
  TextEditingController controllerOUTPUT,
  String selectedLang,
  void Function(String) updateSelectedLang,
) {
  Config config = Config();
  final items = ["settings_general_lang", "settings_general_dlcache", "settings_general_output"];

  void changeLang(String? value) {
    config.setAttr('lang', value!);
    updateSelectedLang(value);
  }

  void changeCACHEPATH() {
    print("changeCACHEPATH");
    config.setAttr('cache_${Platform.operatingSystem}', controllerCACHE.text);
  }

  void changeOUTPUTPATH() {
    print("changeOUTPUTPATH");
    config.setAttr('output_${Platform.operatingSystem}', controllerOUTPUT.text);
  }

  return Expanded(
    flex: 3,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(config.getLang(items[0])),
          DropdownButton(
            value: selectedLang,
            items: [
              DropdownMenuItem(value: "en", child: Text('English')),
              DropdownMenuItem(value: "cn_s", child: Text('简体中文')),
            ],
            onChanged: changeLang,
          ),
          Divider(height: 1, thickness: 0.1, indent: 0.2, endIndent: 0.2, color: Colors.blueGrey),
          Text(config.getLang(items[1])),
          TextField(
            controller: controllerCACHE,
            decoration: InputDecoration(labelText: config.getLang('${items[1]}_hint')),
            onEditingComplete: changeCACHEPATH,
            onTapOutside: (event) {
              changeCACHEPATH();
            },
          ),
          Divider(height: 1, thickness: 0.5, indent: 10, endIndent: 10, color: Colors.blueGrey),
          Text(config.getLang(items[2])),
          TextField(
            controller: controllerOUTPUT,
            decoration: InputDecoration(labelText: config.getLang('${items[2]}_hint')),
            onEditingComplete: changeOUTPUTPATH,
            onTapOutside: (event) {
              changeOUTPUTPATH();
            },
          ),
        ],
      ),
    ),
  );
}
