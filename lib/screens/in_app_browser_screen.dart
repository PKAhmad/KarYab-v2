import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../ui/karyab_ui.dart';

class InAppBrowserScreen extends StatefulWidget {
  final String url;
  final String title;
  final String language;

  const InAppBrowserScreen({
    super.key,
    required this.url,
    required this.title,
    required this.language,
  });

  @override
  State<InAppBrowserScreen> createState() =>
      _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      backgroundColor: KColors.pageBase,
      appBar: AppBar(
        backgroundColor: KLiquid.navyTop,
        leading: IconButton(
          // In Pashto/Dari the way back points right (Phase 5 RTL pass).
          icon: Icon(
            (lang == 'ps' || lang == 'fa')
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'ps'
              ? 'د کار پاڼه'
              : lang == 'fa'
                  ? 'صفحه کار'
                  : widget.title,
          style: TextStyle(
            fontFamily: karyabFontFamily(lang),
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: double.infinity,
            color: KColors.green,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              lang == 'ps'
                  ? 'کوډ ولیکئ → Absenden کلیک کړئ → بریښنالیک کاپي کړئ → بیرته لاړ شئ'
                  : lang == 'fa'
                      ? 'کد را وارد کنید → Absenden → ایمیل را کپی کنید → برگردید'
                      : 'Enter code → Click Absenden → Copy email → Go back',
              style: TextStyle(
                fontFamily: karyabFontFamily(lang),
                color: KLiquid.navyTop,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: KColors.green,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        color: KLiquid.navyTop,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: KColors.green,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lang == 'ps'
                    ? 'بریښنالیک موندل شو؟ یې کاپي کړئ بیا شاته تڼۍ کلیک کړئ'
                    : lang == 'fa'
                        ? 'ایمیل پیدا شد؟ کپی کنید سپس دکمه برگشت را بزنید'
                        : 'Found the email? Copy it then tap the back button',
                style: TextStyle(
                  fontFamily: karyabFontFamily(lang),
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
