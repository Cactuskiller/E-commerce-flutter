import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initOneSignal(); // Initialize OneSignal before running the app
  runApp(const MyApp());
}

/// Initialize OneSignal Push Notifications
Future<void> initOneSignal() async {
  // Enable detailed logging for debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // Initialize OneSignal (no await!)
  OneSignal.initialize("63e73727-9fa6-4814-a6dc-1f8c20e0858f");

  // Ask user for permission to show notifications
  await OneSignal.Notifications.requestPermission(true);

  // Show notification even when app is in foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault();
    event.notification.display();
  });

  // Handle when user taps a notification
  OneSignal.Notifications.addClickListener((event) {
    debugPrint(
      '🔔 Notification clicked: ${event.notification.jsonRepresentation()}',
    );
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
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          // Use iPhone user agent for better mobile layout
          ..setUserAgent(
            'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });

                // Apply layout fixes after page load
                Future.delayed(const Duration(milliseconds: 500), () {
                  controller.runJavaScript('''
                console.log('Fixing navbar position...');
                
                // Ensure proper mobile viewport
                let viewport = document.querySelector('meta[name="viewport"]');
                if (!viewport) {
                  viewport = document.createElement('meta');
                  viewport.name = 'viewport';
                  document.head.appendChild(viewport);
                }
                viewport.content = 'width=device-width, initial-scale=1.0, user-scalable=yes';
                
                const navbarFix = document.createElement('style');
                navbarFix.id = 'navbar-fix';
                navbarFix.innerHTML = \`
                  html, body {
                    width: 100% !important;
                    max-width: 100vw !important;
                    overflow-x: hidden !important;
                    margin: 0 !important;
                    padding: 0 !important;
                  }
                  .container, .wrapper, .main-content {
                    width: 100% !important;
                    max-width: 100% !important;
                    margin: 0 !important;
                    padding: 0 8px !important;
                  }
                  nav, .nav, .navbar, header, .header,
                  [class*="nav"], [class*="header"] {
                    width: 100% !important;
                    position: relative !important;
                    padding: 8px !important;
                    display: flex !important;
                    justify-content: space-between !important;
                    flex-wrap: wrap !important;
                    align-items: center !important;
                  }
                  .search, [class*="search"], input[type="search"] {
                    width: 100% !important;
                    margin: 8px 0 !important;
                  }
                  .categories, [class*="category"] {
                    display: flex !important;
                    justify-content: space-around !important;
                    flex-wrap: wrap !important;
                    width: 100% !important;
                    padding: 8px !important;
                  }
                  .products, .product-grid, [class*="product"] {
                    display: grid !important;
                    grid-template-columns: repeat(2, 1fr) !important;
                    gap: 8px !important;
                    padding: 8px !important;
                  }
                  img {
                    max-width: 100% !important;
                    height: auto !important;
                  }
                  .bottom-nav, [class*="bottom"], .footer {
                    position: fixed !important;
                    bottom: 0 !important;
                    left: 0 !important;
                    right: 0 !important;
                    width: 100% !important;
                    z-index: 1000 !important;
                  }
                  body {
                    padding-bottom: 60px !important;
                  }
                \`;
                const existingFix = document.getElementById('navbar-fix');
                if (existingFix) existingFix.remove();
                document.head.appendChild(navbarFix);
                setTimeout(() => {
                  const containers = document.querySelectorAll('div, section, main, article, nav, header');
                  containers.forEach(el => {
                    if (el.offsetWidth > window.innerWidth) {
                      el.style.width = '100%';
                      el.style.maxWidth = '100%';
                    }
                  });
                  window.dispatchEvent(new Event('resize'));
                  console.log('Navbar fix applied');
                }, 300);
              ''');
                });
              },
            ),
          )
          ..loadRequest(Uri.parse('https://danya.puretik.info/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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