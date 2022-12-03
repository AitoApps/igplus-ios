import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:igshark/data/constants.dart';
import 'package:igshark/data/models/account_info_model.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/usecases/get_account_info_use_case.dart';
import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/blocs/login/cubit/instagram_auth_cubit.dart';

import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class InstagramLoginPage extends StatefulWidget {
  const InstagramLoginPage({
    Key? key,
    this.updateInstagramAccount = false,
  }) : super(key: key);

  final bool updateInstagramAccount;

  @override
  State<InstagramLoginPage> createState() => _InstagramLoginPageState();
}

class _InstagramLoginPageState extends State<InstagramLoginPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  final WebviewCookieManager _cookieManager = WebviewCookieManager();
  late GetAccountInfoUseCase getAccountInfoUseCase;
  Cookie? findCookie({required String name, required List<Cookie> cookies}) {
    for (final cookie in cookies) {
      if (cookie.name == name) {
        return cookie;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebView(
          initialUrl: "https://www.instagram.com/accounts/login",
          javascriptMode: JavascriptMode.unrestricted,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            if (widget.updateInstagramAccount == true) {
              webViewController.clearCache();
              final cookieManager = CookieManager();
              cookieManager.clearCookies();
              // _cookieManager.clearCookies();
            }
          },
          onProgress: (int progress) {},
          navigationDelegate: (NavigationRequest request) async {
            final controller = await _controller.future;
            final userAgent = await controller.runJavascriptReturningResult('navigator.userAgent');
            final cookies = await _cookieManager.getCookies('https://www.instagram.com/');

            final Cookie? sessionidCookies = findCookie(name: "sessionid", cookies: cookies);
            final useridCookies = findCookie(name: "ds_user_id", cookies: cookies);
            final Cookie? csrftokenCookies = findCookie(name: "csrftoken", cookies: cookies);

            if (sessionidCookies != null && useridCookies != null && mounted) {
              //"23689336944%3A7RknvrX3SdUpYB%3A7%3AAYfosXmPcAl9__jTr47HqVTK2gjTrqh5sa8rnvoY5g"

              // GoRouter.of(context).pop();

              // 1 https://www.instagram.com/accounts/login"
              // 2 https://www.instagram.com/challenge/?
              // 3 https://www.instagram.com/accounts/onetap/?next=%2F
              // 4 https://www.instagram.com/accounts/login/?__d=dis

              Map<String, String> headers = {
                'User-Agent': userAgent.replaceAll('"', '').trim(),
                'Cookie': 'sessionid=${sessionidCookies.value}',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Encoding': 'gzip, deflate, br',
                'Accept-Language': 'en-US,en;q=0.5',
                'Upgrade-Insecure-Requests': '1',
                'X-IG-App-ID': '936619743392459',
                'X-CSRFToken': csrftokenCookies?.value ?? ""
              };

              // test if the session is valid
              if (request.url.contains("instagram.com/accounts/onetap/") ||
                  request.url == "https://www.instagram.com/accounts/login/?__d=dis" ||
                  request.url == "https://www.instagram.com/") {
                final rs =
                    await http.get(Uri.parse(InstagramUrls.getAccountInfoById(useridCookies.value)), headers: headers);

                if (rs.statusCode == 200 && mounted) {
                  AccountInfo accountInfo = AccountInfoModel.fromJsonById(json.decode(rs.body)).toEntity();
                  await context.read<InstagramAuthCubit>().createOrUpdateInstagramInfo(
                        headers: headers,
                        igUserId: useridCookies.value,
                      );
                  if (mounted) {
                    if (widget.updateInstagramAccount == true) {
                      BlocProvider.of<ReportCubit>(context).userChanged(accountInfo: accountInfo);
                    }

                    GoRouter.of(context).goNamed('home');
                  }
                  return NavigationDecision.prevent;
                }
              }

              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {},
        ),
      ),
    );
  }
}
