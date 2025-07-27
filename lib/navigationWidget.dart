import 'package:bltool/config.dart';
import 'package:flutter/material.dart';

Widget getNavigationRail(int type, int selectedIndex, void Function(int) update) {
  Config config = Config();

  final Settings = [config.getLang('settings_general'), config.getLang('settings_stream')];

  switch (type) {
    case 0: //主界面
      return NavigationRail(
        labelType: NavigationRailLabelType.all,
        selectedIndex: selectedIndex,
        onDestinationSelected: update,
        destinations: [
          NavigationRailDestination(icon: Icon(Icons.comment), label: Text(config.getLang('DM'))),
          NavigationRailDestination(icon: Icon(Icons.download), label: Text(config.getLang('download'))),
        ],
      );
    case 1: //设置界面
      return Expanded(
        flex: 1,
        child: IntrinsicWidth(
          child: ListView.builder(
            shrinkWrap: false,
            itemCount: Settings.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.blue, width: 1)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        update(index);
                      },
                      child: Text(Settings[index]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    /*return NavigationRail(
        labelType: NavigationRailLabelType.all,
        selectedIndex: selectedIndex,
        onDestinationSelected: update,
        destinations: [
          NavigationRailDestination(icon: SizedBox.shrink(), label: Text(config.getLang("settings_general"))),
        ],
      );*/
    default:
      return NavigationRail(destinations: [], selectedIndex: selectedIndex);
  }
}
