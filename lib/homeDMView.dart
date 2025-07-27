import 'package:bltool/DM.dart';
import 'package:bltool/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget getDMView(
  TextEditingController urlControllerDM,
  TextEditingController keyControllerDM,
  void Function() updateDMView,
  List<List<String>> items,
) {
  Config config = Config();
  DM dm = DM();

  Future<void> onPressedDM(String url, String keyword) async {
    print('DMview/onpressedDM/before/update');
    dm.update(url, keyword, updateDMView);
  }

  Future<void> crack(int index) async {
    print('DMview/crack/before/update');
    dm.crack(index, updateDMView);
  }

  return Expanded(
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: urlControllerDM,
            decoration: InputDecoration(labelText: config.getLang("DM_link_hint"), border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: keyControllerDM,
                  decoration: InputDecoration(
                    labelText: config.getLang("DM_keyword_hint"),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  onPressedDM(urlControllerDM.text, keyControllerDM.text);
                },
                child: Text(config.getLang("DM_button")),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(config.getLang("DM_empty")))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Divider(height: 1, thickness: 1, color: Colors.blueGrey),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VerticalDivider(width: 1, thickness: 1, color: Colors.black),
                                Expanded(
                                  flex: 2,
                                  child: Text(items[index][0], softWrap: false, overflow: TextOverflow.fade),
                                ),
                                VerticalDivider(width: 1, thickness: 1, color: Colors.black),
                                Expanded(
                                  flex: 1,
                                  child: Text(items[index][1], softWrap: false, overflow: TextOverflow.fade),
                                ),
                                VerticalDivider(width: 1, thickness: 1, color: Colors.black),
                                Expanded(
                                  flex: 1,
                                  child: items[index].length > 2
                                      ? GestureDetector(
                                          child: Text(
                                            items[index][2],
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          onTap: () async {
                                            if (await canLaunchUrl(
                                              Uri.parse('https://space.bilibili.com/${items[index][2]}'),
                                            )) {
                                              await launchUrl(
                                                Uri.parse('https://space.bilibili.com/${items[index][2]}'),
                                              );
                                            }
                                          },
                                        )
                                      : TextButton(
                                          onPressed: () {
                                            crack(index);
                                          },
                                          child: Text(config.getLang('DM_decode')),
                                        ),
                                ),
                                VerticalDivider(width: 1, thickness: 1, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
