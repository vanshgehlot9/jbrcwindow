import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/modern_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear ALL cache and cookies when app starts - ensures fresh content
  try {
    await InAppWebViewController.clearAllCache();
    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  } catch (e) {
    debugPrint('Cache clear error: $e');
  }

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  runApp(const JBRCApp());
}

class JBRCApp extends StatelessWidget {
  const JBRCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  int _currentIndex = 0;

  final List<String> _urls = [
    "https://jodhpurbombay.vercel.app/",
    "https://jodhpurbombay.vercel.app/bilty/create",
    "https://jodhpurbombay.vercel.app/bilty/view",
  ];

  bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_urls[0])),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                // DISABLE cache to always get fresh content
                cacheEnabled: false,
                cacheMode: CacheMode.LOAD_NO_CACHE,
                clearCache: true,
                // Performance settings
                hardwareAcceleration: true,
                useHybridComposition: !_isDesktop,
                // Allow all access
                allowFileAccess: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                // Scrolling - important for keyboard scroll on Windows
                disableVerticalScroll: false,
                disableHorizontalScroll: false,
                verticalScrollBarEnabled: true,
                horizontalScrollBarEnabled: false,
                // Windows specific
                supportZoom: false,
                disableContextMenu: _isDesktop,
                // User agent
                userAgent:
                    _isDesktop
                        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
                        : null,
              ),
              onWebViewCreated: (controller) async {
                _webViewController = controller;
                // Clear ALL cache and cookies when WebView is created
                await InAppWebViewController.clearAllCache();
                await controller.clearHistory();
                final cookieManager = CookieManager.instance();
                await cookieManager.deleteAllCookies();
              },
              onLoadStart: (controller, url) {
                if (mounted) setState(() => _isLoading = true);
              },
              onLoadStop: (controller, url) async {
                if (mounted) setState(() => _isLoading = false);
                // Clear cache on every page load to ensure fresh content
                await InAppWebViewController.clearAllCache();
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri == null) return NavigationActionPolicy.ALLOW;
                final urlStr = uri.toString();

                // Handle tel: links
                if (uri.scheme == 'tel') {
                  _launchExternalUrl(uri);
                  return NavigationActionPolicy.CANCEL;
                }

                // Handle mailto: links
                if (uri.scheme == 'mailto') {
                  _launchExternalUrl(uri);
                  return NavigationActionPolicy.CANCEL;
                }

                // Handle WhatsApp links
                if (urlStr.contains("wa.me") ||
                    urlStr.contains("api.whatsapp.com")) {
                  _launchExternalUrl(uri);
                  return NavigationActionPolicy.CANCEL;
                }

                // External links - open in browser
                if (!urlStr.contains('jodhpurbombay.vercel.app') &&
                    (uri.scheme == 'http' || uri.scheme == 'https')) {
                  _launchExternalUrl(uri);
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onDownloadStartRequest: (controller, downloadRequest) async {
                _launchExternalUrl(downloadRequest.url);
              },
              onCreateWindow: (controller, createWindowAction) async {
                final url = createWindowAction.request.url;
                if (url != null) {
                  final urlString = url.toString();

                  // PDF files - open externally
                  if (urlString.contains('.pdf') || urlString.contains('pdf')) {
                    _launchExternalUrl(url);
                    return true;
                  }

                  // Same domain - navigate in webview
                  if (urlString.contains('jodhpurbombay.vercel.app')) {
                    await controller.loadUrl(urlRequest: URLRequest(url: url));
                    return true;
                  }

                  // External - open in browser
                  _launchExternalUrl(url);
                }
                return true;
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
              !_isDesktop
              ? ModernBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    _webViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(_urls[index])),
                    );
                  },
                  items: [
                    ModernNavBarItem(
                      icon: Icons.home,
                      label: "Home",
                    ),
                    ModernNavBarItem(
                      icon: Icons.create,
                      label: "Create",
                    ),
                    ModernNavBarItem(
                      icon: Icons.list,
                      label: "View",
                    ),
                  ],
                )
              : null,
    );
  }

  Future<void> _launchExternalUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
