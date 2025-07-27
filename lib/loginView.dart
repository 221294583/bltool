import 'dart:collection';
import 'dart:io';

import 'package:bltool/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'util.dart';

class LoginView extends StatefulWidget {
  final String url;
  const LoginView({super.key, required this.url});

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginView> {
  InAppWebViewController? _controller;
  CookieManager cookieManager = CookieManager();

  InAppWebViewSettings getPlatformSpecificSettings() {
    if (Platform.isAndroid || Platform.isIOS) {
      return InAppWebViewSettings(javaScriptEnabled: true);
    } else if (Platform.isWindows) {
      return InAppWebViewSettings(javaScriptEnabled: true, cacheEnabled: true);
    } else {
      return InAppWebViewSettings(); // fallback
    }
  }

  Future<void> check(InAppWebViewController c, WebUri? url) async {
    print('loginView/check: $url');
    var temp = await c.evaluateJavascript(source: "navigator.userAgent");
    print("当前 WebView UA: $temp");
    temp = await c.evaluateJavascript(source: "navigator.webdriver");
    print("当前 WebView webdriver: $temp");
    temp = await c.evaluateJavascript(source: "window.chrome");
    print("当前 WebView chrome: $temp");
    temp = await c.evaluateJavascript(source: "navigator.platform");
    print("当前 WebView platform: $temp");
    if (url != null) {
      if (!url.toString().contains('passport')) {
        print('loginView/check/before/save');
        saveBiliLoginJSON(await cookieManager.getCookies(url: (await c.getUrl()) ?? WebUri(widget.url)));
        print('loginView/check/after/save');
        //cookieManager.deleteCookies(url: WebUri(widget.url));
        if (mounted) {
          //Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar([1, 0], context, controller: _controller),
      body: InAppWebView(
        initialSettings: getPlatformSpecificSettings(),
        initialUrlRequest: Platform.isWindows
            ? URLRequest(url: WebUri(widget.url))
            : URLRequest(url: WebUri('https://passport.bilibili.com/h5-app/passport/login')),
        initialUserScripts: Platform.isAndroid
            ? UnmodifiableListView([
                UserScript(
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  source: '''try { delete window.flutter_inappwebview; } catch (e) {}
                      Object.defineProperty(navigator, 'platform', {get: function () { return 'Linux armv8l'; }});
                      Object.defineProperty(navigator, 'webdriver', {get: function () { return null; }});
                      navigator.userAgentData = {brands: [{ brand: "Chromium", version: "138" },{ brand: "Not.A/Brand", version: "8" }],mobile: true,platform: "Android"};
                      ''',
                ),
              ])
            : null,
        onWebViewCreated: (controller) async {
          print("WebView 创建完成");
          setState(() {
            _controller = controller;
          });
        },
        onReceivedError: (controller, request, error) {
          print("加载失败: $request, error: $error");
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          print("加载失败: $request, error: $errorResponse");
        },
        onLoadStart: (controller, url) {
          print("load start");
        },
        onLoadStop: check,
      ),
    );
  }
}
