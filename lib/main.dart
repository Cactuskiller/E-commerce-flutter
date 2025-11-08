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
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Navigate after 3 seconds regardless of WebView status
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WebViewApp()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF83758),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/splash_logo.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Color(0xFFF83758),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Stylish',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'E-commerce Made Simple',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
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

                nav *, .navbar *, header * {
                  vertical-align: middle !important;
                }

                nav img, .navbar img {
                  display: inline-block !important;
                  max-height: 36px !important;
                  height: auto !important;
                }

                .product-card, .card, [class*="card"], [class*="product"] {
                  border: none !important;
                  outline: none !important;
                  box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
                  border-radius: 12px !important;
                  background: white !important;
                }

                svg, .icon, i, .fa {
                  border: none !important;
                  outline: none !important;
                }
              \`;

              const existing = document.getElementById('navbar-fix');
              if (existing) existing.remove();
              style.id = 'navbar-fix';
              document.head.appendChild(style);
            ''');
              },
              onWebResourceError: (error) {
                debugPrint('WebView error: ${error.description}');
                setState(() => isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse('https://danya.puretik.info/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFF83758)),
              ),
          ],
        ),
      ),
    );
  }
}
