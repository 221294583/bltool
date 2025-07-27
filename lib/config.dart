import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'util.dart';

class Config {
  late var hasEX;
  late var initEX;

  late var config;
  late var lang;
  var buffer = {};
  static final Config instance = Config._c();

  Config._c();

  Future<void> init() async {
    print("construct");
    final initEXString = await rootBundle.loadString('assets/init.json');
    initEX = jsonDecode(initEXString);
    hasEX = await checkEX(initEX["config_${Platform.operatingSystem}_EX"]);
    print(hasEX);
    if (hasEX) {
      final configString = await File(initEX["config_${Platform.operatingSystem}_EX"] + "config.json").readAsString();
      config = jsonDecode(configString);
      print(config);
      final langString = await File(initEX["config_${Platform.operatingSystem}_EX"] + "lang.json").readAsString();
      final langList = jsonDecode(langString);
      lang = langList[config["lang"]];
      print(lang);
    } else {
      final configString = await rootBundle.loadString('assets/config.json');
      config = jsonDecode(configString);
      print(config);
      final langString = await rootBundle.loadString('assets/lang.json');
      final langList = jsonDecode(langString);
      lang = langList[config["lang"]];
      print(lang);
      copyConfig(initEX["config_${Platform.operatingSystem}_EX"], config, langList);
    }
  }

  factory Config() {
    return instance;
  }

  String getLang(String key) {
    return lang[key];
  }

  String getAttr(String key) {
    return config[key];
  }

  void setAttr(String key, String value) {
    buffer[key] = value;
  }

  Future<void> confirm() async {
    print("CONFIRM");
    print(buffer);
    buffer.keys.forEach((key) {
      config[key] = buffer[key];
    });
    print(config);
    changeConfig();
    final langString = await rootBundle.loadString('assets/lang.json');
    final langList = jsonDecode(langString);
    lang = langList[config["lang"]];
    buffer = {};
  }

  void cancel() {
    buffer = {};
  }

  Future<bool> checkEX(String path) async {
    final hasConfig = await checkFile("${path}config.json");
    final hasLang = await checkFile("${path}lang.json");
    if (hasConfig && hasLang) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> copyConfig(String path, dynamic jsonConfig, dynamic jsonLang) async {
    checkDirectory(path);
    var fileConfig = File("${path}config.json");
    var fileLang = File("${path}lang.json");
    await fileConfig.writeAsString(jsonEncode(jsonConfig));
    await fileLang.writeAsString(jsonEncode(jsonLang));
  }

  Future<void> changeConfig() async {
    if (hasEX) {
      var fileConfig = File(initEX['config_${Platform.operatingSystem}_EX'] + "config.json");
      await fileConfig.writeAsString(jsonEncode(config));
    }
  }
}
