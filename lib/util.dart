import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:bltool/config.dart';
import 'package:flutter_ffmpeg_kit_full/ffmpeg_kit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:xml/xml.dart';
import 'package:archive/archive.dart' as ac;

Config config = Config();

Future<List<Map<String, String>>> parseJSON(String source) async {
  print("parseJSON");
  var temp = source.split(';').map((c) {
    var pair = c.trim().split('=');
    var name = pair[0];
    var value = pair[1];
    return {'name': name, 'value': value};
  }).toList();
  return temp;
}

Future<void> saveBiliLoginJSON(List<Cookie> cookies) async {
  print("saveJSON");
  final dir = config.getAttr('config_${Platform.operatingSystem}');
  checkDirectory(dir);
  var file = File('${dir}bili_login.json');
  print(file.path);
  print("saveJSON/file");
  var toSave = jsonEncode(cookies);
  print(toSave);
  await file.writeAsString(toSave);
}

Future<bool> checkFile(String filename) async {
  print("checkfile");
  print(filename);
  return await File(filename).exists();
}

Future<bool> checkDirectory(String directory) async {
  print("checkDIR: $directory");
  final dir = Directory(directory);
  if (await dir.exists()) {
    return true;
  } else {
    await dir.create(recursive: true);
    return true;
  }
}

Future<void> openDownloadDirectory() async {
  Process.run('explorer', [
    Uri.file(Directory(config.getAttr('cache_${Platform.operatingSystem}')).absolute.path).toFilePath(),
  ]);
  Process.run('explorer', [
    Uri.file(Directory(config.getAttr('output_${Platform.operatingSystem}')).absolute.path).toFilePath(),
  ]);
}

Future<bool> downloadBiliVideo(String url, Function(double, String) onProgress) async {
  onProgress(0, config.getLang('DL_pending'));
  print("doanloadBiliVideo");
  final pathCache = config.getAttr('cache_${Platform.operatingSystem}');
  final pathOutput = config.getAttr('output_${Platform.operatingSystem}');
  print("doanloadBiliVideo/check");
  checkDirectory(pathCache);
  checkDirectory(pathOutput);
  print("doanloadBiliVideo/before/headers");
  final headers = await generateHeaders();
  print(headers);
  print("doanloadBiliVideo/before/info");
  final videoInfo = await getBiliVideoInfo(headers, url);
  print(videoInfo);
  List<String> temp = [];
  if (videoInfo.isNotEmpty) {
    print("doanloadBiliVideo/before/JSON");
    temp = await getBiliVideoJson(videoInfo[0], videoInfo[1], videoInfo[2], videoInfo[3], headers);
    print(temp);
  } else {
    return false;
  }

  if (temp.isNotEmpty) {
    final videoPath = "$pathCache${temp[0]}_${temp[1]}.m4s";
    final audioPath = "$pathCache${temp[0]}_a.m4s";
    final outputPath = "$pathOutput${temp[0]}.mp4";
    print("doanloadBiliVideo/before/download");
    await Future.wait([downloadFile(temp[2], videoPath, onProgress), downloadFile(temp[3], audioPath, onProgress)]);
    print("doanloadBiliVideo/before/merge");
    await mergeAudioVideo(videoPath, audioPath, outputPath, onProgress);
  } else {
    return false;
  }
  return true;
}

///type = 'so'或者type = 'xml'
///return [[comment,crc32]]
Future<List<List<String>>> getDM(Map<String, String> headers, String type, String aid, String bid, String cid) async {
  print("getDM");
  List<List<String>> res = [];
  if (type == 'xml') {
    String url = 'https://comment.bilibili.com/$cid.xml';
    print("getDM/before/getXML");
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final xmlRaw = response.bodyBytes;
      print("getDM/before/decode");
      final xmlDecompressed = ac.ZLibDecoderWeb().decodeBytes(xmlRaw, raw: true);
      final xmlString = utf8.decode(xmlDecompressed);
      final doc = XmlDocument.parse(xmlString);
      final items = doc.findAllElements('d');
      for (var item in items) {
        final innerText = item.innerText;
        final attrALL = item.getAttribute('p');
        if (attrALL != null) {
          final attrS = attrALL.split(',');
          final crc32Value = attrS[6];
          final temp = [innerText, crc32Value];
          res.add(temp);
        }
      }
    } else {
      return [];
    }
  } else if (type == 'so') {
    //String url='https://api.bilibili.com/x/v1/dm/list.so?oid=$cid';
  }
  return res;
}

Future<List<int>> filterDM(List<List<String>>? all, String keyword) async {
  if (keyword == '') {
    return List.generate(all!.length, (index) => index);
  } else {
    final pattern = RegExp(keyword);
    List<int> res = [];
    if (all != null) {
      for (var i = 0; i < all.length; i++) {
        if (pattern.hasMatch(all[i][0])) {
          res.add(i);
        }
      }
    }
    return res;
  }
}

Future<Map<String, String>> generateHeaders() async {
  String cookieHeader = '';
  print('config_${Platform.operatingSystem}');
  final dir = config.getAttr('config_${Platform.operatingSystem}');
  if (await checkFile('${dir}bili_login.json')) {
    final cookieFile = File("${dir}bili_login.json");
    final cookieList = jsonDecode(await cookieFile.readAsString());
    for (var c in cookieList) {
      if (cookieHeader != '') {
        cookieHeader += '; ';
      }
      cookieHeader += c['name'];
      cookieHeader += '=';
      cookieHeader += c['value'];
    }
  }
  final headers = {
    "User-Agent": Platform.isAndroid
        ? 'Mozilla/5.0 (Linux; Android 13; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.7204.158 Mobile Safari/537.36'
        : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
    if (cookieHeader != '') "Cookie": cookieHeader,
  };
  print(headers);
  return headers;
}

///return [title,aid,bid,cid]
Future<List<String>> getBiliVideoInfo(Map<String, String> headers, String url) async {
  print('getBiliVideoInfo: $headers $url');
  final bidMatch = RegExp(r"(BV\w+)").firstMatch(url);
  if (bidMatch == null) {
    print("BV号未找到");
    return [];
  }
  final bid = bidMatch.group(1);
  print(bid);
  final viewUrl = "https://api.bilibili.com/x/web-interface/wbi/view/detail?platform=web&bvid=$bid";
  final viewRes = await http.get(Uri.parse(viewUrl), headers: headers);
  if (viewRes.statusCode != 200) {
    print("获取视频信息失败");
    return [];
  }
  print('getBiliVideoInfo/before/jsondecode');
  final viewJson = jsonDecode(viewRes.body);
  final view = viewJson["data"]["View"];
  final title = view["title"];
  final aid = view["aid"];
  final cid = view["cid"];
  print("aid: $aid, bid: $bid, cid: $cid");
  return [title, aid.toString(), bid ?? "", cid.toString()];
}

Future<List<String>> getBiliVideoJson(
  String title,
  String aid,
  String bid,
  String cid,
  Map<String, String> headers,
) async {
  print('getBiliVideoJSON');
  final qualityMapping = {126: "db", 116: "1080p60", 80: "1080", 64: "720", 32: "480", 16: "360"};

  final playUrl =
      "https://api.bilibili.com/x/player/wbi/playurl?"
      "qn=32&fnver=0&fnval=4048&fourk=1&voice_balance=1&gaia_source=pre-load&isGaiaAvoided=true&"
      "avid=$aid&bvid=$bid&cid=$cid";
  print('getBiliVideoJSON/before/http');
  final playRes = await http.get(Uri.parse(playUrl), headers: headers);
  print(playUrl);
  if (playRes.statusCode != 200) {
    print("获取播放地址失败");
    return [];
  }
  print('getBiliVideoJSON/before/jsonDecode');
  final playJson = jsonDecode(playRes.body);
  final dash = playJson["data"]["dash"];
  final videoList = dash["video"];
  final audioList = dash["audio"];

  String videoUrl = '';
  String audioUrl = '';
  String reso = '';
  bool validV = false;
  bool validA = false;

  for (var v in videoList) {
    reso = qualityMapping[v["id"]]!;
    videoUrl = v["baseUrl"] ?? v["base_url"];
    if (videoUrl.contains("hdnts")) {
      validV = true;
      break;
    }
  }

  for (var a in audioList) {
    audioUrl = a["baseUrl"] ?? a["base_url"];
    if (audioUrl.contains("hdnts")) {
      validA = true;
      break;
    }
  }

  if (videoUrl.isEmpty || audioUrl.isEmpty) {
    print("未找到可下载的视频或音频地址");
    return [];
  }
  if (validA && validV) {
    return [title, reso, videoUrl, audioUrl];
  }
  return [];
}

Future<void> downloadFile(String url, String filename, Function(double, String) onProgress) async {
  print("Downloading $filename...");
  final response = await http.Client().send(http.Request("GET", Uri.parse(url)));

  final file = File(filename);
  final sink = file.openWrite();

  final total = response.contentLength ?? 0;

  await response.stream.listen((chunk) {
    sink.add(chunk);
    final d = (chunk.length / total) * 0.45;
    onProgress(d, config.getLang('DL_downloading'));
  }).asFuture();

  await sink.flush();
  await sink.close();
}

Future<void> mergeAudioVideo(
  String videoPath,
  String audioPath,
  String outputPath,
  Function(double, String) onProgress,
) async {
  late int result;
  switch (Platform.operatingSystem) {
    case 'android':
      final command = '-i "$videoPath" -i "$audioPath" -c copy -map 0:v:0 -map 1:a:0 "$outputPath"';
      final session = await FFmpegKit.execute(command);
      result = (await session.getReturnCode())!.getValue();
      break;
    default:
      result = (await Process.run("ffmpeg", [
        "-i",
        videoPath,
        "-i",
        audioPath,
        "-c",
        "copy",
        "-map",
        "0:v:0",
        "-map",
        "1:a:0",
        outputPath,
      ])).exitCode;
  }

  if (result == 0) {
    print("合并完成: $outputPath");
    onProgress(1.0, config.getLang("DL_merge_success"));
  } else {
    print("合并失败:\n$result");
    onProgress(-1, config.getLang("DL_merge_fail"));
  }
}
