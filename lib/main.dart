import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initOneSignal();
  runApp(const MyApp());
}

Future<void> initOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("63e73727-9fa6-4814-a6dc-1f8c20e0858f");
  await OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault();
    event.notification.display();
  });

  OneSignal.Notifications.addClickListener((event) {
    debugPrint('🔔 Notification clicked: ${event.notification.jsonRepresentation()}');
  });

  debugPrint("✅ OneSignal initialized successfully!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) async {
            setState(() => isLoading = false);

            // ✅ Fix navbar vertical alignment + width consistency
            await controller.runJavaScript('''
              const style = document.createElement('style');
              style.innerHTML = \`
                html, body {
                  margin: 0 !important;
                  padding: 0 !important;
                  overflow-x: hidden !important;
                  width: 100% !important;
                  background: #fff !important;
                }

                /* ✅ Reset all potential default margins from frameworks */
                nav, .navbar, header, .nav, [class*="header"] {
                  margin: 0 !important;
                  top: 0 !important;
                  bottom: auto !important;
                  position: relative !important;
                  display: flex !important;
                  flex-direction: row !important;
                  justify-content: space-between !important;
                  align-items: center !important;
                  box-sizing: border-box !important;
                  width: 100% !important;
                  background-color: #ffffff !important;
                  border: none !important;
                  height: auto !important;
                  min-height: 56px !important;
                  line-height: normal !important;
                }

                /* ✅ Make sure inner elements respect vertical center */
                nav * , .navbar * , header * {
                  vertical-align: middle !important;
                }

                /* ✅ Prevent compression due to display:inline-block parents */
                nav img, .navbar img {
                  display: inline-block !important;
                  max-height: 36px !important;
                  height: auto !important;
                }

                /* ✅ If framework uses sticky/fixed, normalize offset */
                nav[style*="fixed"], .navbar[style*="fixed"], header[style*="fixed"] {
                  position: sticky !important;
                  top: 0 !important;
                  z-index: 1000 !important;
                }

                /* ✅ Make sure body content starts below navbar naturally */
                main, .main-content, section:first-of-type {
                  margin-top: 0 !important;
                }

                /* ✅ Remove top margin or padding from global wrappers that cause shift */
                .wrapper, .container, body > div:first-child {
                  margin-top: 0 !important;
                  padding-top: 0 !important;
                }
              \`;

              const existing = document.getElementById('navbar-fix');
              if (existing) existing.remove();
              style.id = 'navbar-fix';
              document.head.appendChild(style);

      
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://danya.puretik.info/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // SafeArea keeps it inside display bounds, not padding hack
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
