import 'package:bltool/config.dart';
import 'package:bltool/util.dart';
import 'package:flutter/material.dart';

Widget getDownloadView(
  TextEditingController urlControllerDL,
  double progress,
  String phase,
  void Function(double, String) updateDownloadView,
) {
  Config config = Config();

  void onPressedDL() {
    print('Downloadview/onpressedDL/before/downloadBiliVideo');
    downloadBiliVideo(urlControllerDL.text, updateDownloadView);
  }

  void openDirectory() {
    print('Downloadview/onopenDirectory/before/open');
    openDownloadDirectory();
  }

  return Expanded(
    child: Center(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlControllerDL,
              decoration: InputDecoration(labelText: config.getLang("DL_link_hint"), border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: onPressedDL, child: Text(config.getLang("DL_button"))),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 5),
            progress == 1 ? ElevatedButton(onPressed: openDirectory, child: Text(phase)) : Text(phase),
          ],
        ),
      ),
    ),
  );
}
