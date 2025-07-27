import 'package:bltool/config.dart';
import 'package:bltool/loginView.dart';
import 'package:bltool/settingsView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

///`type=[a,b]`
///
///`a=0`主页; `a=1`登陆页面或设置页面
AppBar getAppBar(List<int> type, BuildContext context, {InAppWebViewController? controller}) {
  Config config = Config();

  void navLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginView(url: 'https://passport.bilibili.com/login')),
    );
  }

  void navSettings(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsView()));
  }

  void loginRefresh() {
    print(identityHashCode(controller));
    if (controller != null) {
      controller.reload();
      print("reload");
    }
  }

  Future<void> backward() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(config.getLang("settings_back_title")),
        content: Text(config.getLang("settings_back_content")),
        actions: [
          TextButton(
            onPressed: () {
              config.confirm();
              Navigator.of(context).pop(true);
            }, // 确认
            child: Text(config.getLang("settings_confirm")),
          ),
          TextButton(
            onPressed: () {
              config.cancel();
              Navigator.of(context).pop(false);
            }, // 撤销
            child: Text(config.getLang("settings_cancel")),
          ),
        ],
      ),
    );
    Navigator.pop(context);
  }

  List<Widget> getActions(int type) {
    if (type == 0) {
      return [IconButton(onPressed: loginRefresh, icon: Icon(Icons.refresh))];
    } else {
      return [];
    }
  }

  if (type[0] == 0) {
    return AppBar(
      title: Text(type[1] == 0 ? config.getLang('DM') : config.getLang('download')),
      actions: [
        PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'login':
                navLogin(context);
                break;
              case 'settings':
                navSettings(context);
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'login', child: Text(config.getLang('login'))),
            PopupMenuItem(value: 'settings', child: Text(config.getLang('settings'))),
          ],
        ),
      ],
    );
  } else {
    if (type[1] == 1) {
      return AppBar(
        leading: IconButton(onPressed: backward, icon: Icon(Icons.arrow_back)),
        title: Text(config.getLang('settings')),
        actions: getActions(type[1]),
      );
    } else {
      return AppBar(title: Text(config.getLang('login')), actions: getActions(type[1]));
    }
  }
}
