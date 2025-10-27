import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only set immersive mode on mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  runApp(const VorApp());
}

class VorApp extends StatelessWidget {
  const VorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
      home: const SplashScreen(),
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
  late AnimationController _controller;
  late Animation<double> _truckAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Truck moves from left to right
    _truckAnimation = Tween<double>(
      begin: -0.3,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade in/out effect
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Road/background effect
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.4,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeAnimation.value * 0.3,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.pinkAccent.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Animated truck
              Positioned(
                left: screenWidth * _truckAnimation.value,
                top: MediaQuery.of(context).size.height * 0.35,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: 1.0 + (_truckAnimation.value * 0.2),
                    child: _buildTruck(),
                  ),
                ),
              ),

              // Company name or title
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 200),
                      Text(
                        'JBRC',
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: Colors.pinkAccent.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Transport Management',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTruck() {
    return Container(
      width: 120,
      height: 60,
      child: CustomPaint(painter: TruckPainter()),
    );
  }
}

// Custom painter for the truck
class TruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.pinkAccent
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Truck body (cargo area)
    final cargoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(cargoRect, paint);
    canvas.drawRRect(cargoRect, outlinePaint);

    // Truck cabin
    final cabinPath =
        Path()
          ..moveTo(size.width * 0.15, size.height * 0.7)
          ..lineTo(size.width * 0.15, size.height * 0.35)
          ..lineTo(size.width * 0.25, size.height * 0.2)
          ..lineTo(size.width * 0.35, size.height * 0.2)
          ..lineTo(size.width * 0.35, size.height * 0.7)
          ..close();
    canvas.drawPath(cabinPath, paint);
    canvas.drawPath(cabinPath, outlinePaint);

    // Windshield
    final windshieldPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;
    final windshield =
        Path()
          ..moveTo(size.width * 0.18, size.height * 0.35)
          ..lineTo(size.width * 0.23, size.height * 0.25)
          ..lineTo(size.width * 0.32, size.height * 0.25)
          ..lineTo(size.width * 0.32, size.height * 0.35)
          ..close();
    canvas.drawPath(windshield, windshieldPaint);
    canvas.drawPath(windshield, outlinePaint);

    // Wheels
    final wheelPaint =
        Paint()
          ..color = Colors.grey[900]!
          ..style = PaintingStyle.fill;

    final wheelOutlinePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Front wheel
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.8),
      size.width * 0.08,
      wheelPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.8),
      size.width * 0.08,
      wheelOutlinePaint,
    );

    // Back wheel
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.8),
      size.width * 0.08,
      wheelPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.8),
      size.width * 0.08,
      wheelOutlinePaint,
    );

    // Wheel details (rims)
    final rimPaint =
        Paint()
          ..color = Colors.pinkAccent
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.8),
      size.width * 0.04,
      rimPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.8),
      size.width * 0.04,
      rimPaint,
    );

    // Headlights
    final headlightPaint =
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.6),
      size.width * 0.025,
      headlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  InAppWebViewController? _webViewController;
  final GlobalKey webViewKey = GlobalKey();
  bool _isLoading = false;
  DateTime? _lastBackPressed;
  PullToRefreshController? _pullToRefreshController;

  final List<String> _urls = [
    "https://jodhpurbombay.vercel.app/",
    "https://jodhpurbombay.vercel.app/bilty/create",
    "https://jodhpurbombay.vercel.app/bilty/view",
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    // Only initialize pull-to-refresh for mobile platforms
    if (Platform.isAndroid || Platform.isIOS) {
      _pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: Colors.pinkAccent),
        onRefresh: () async {
          if (_webViewController != null) {
            if (Platform.isAndroid) {
              _webViewController?.reload();
            } else if (Platform.isIOS) {
              final currentUrl = await _webViewController?.getUrl();
              if (currentUrl != null) {
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: currentUrl),
                );
              }
            }
          }
        },
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Only request permissions on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      List<Permission> permissions = [
        Permission.camera,
        Permission.photos,
        Permission.contacts,
      ];

      if (Platform.isAndroid) {
        permissions.addAll([
          Permission.storage,
          Permission.manageExternalStorage,
        ]);
      }

      final statuses = await permissions.request();

      bool hasRequiredPermissions = true;
      statuses.forEach((permission, status) {
        if (status.isDenied || status.isPermanentlyDenied) {
          debugPrint('Permission denied: $permission - Status: $status');
          hasRequiredPermissions = false;
        }
      });

      if (!hasRequiredPermissions && mounted) {
        _showPermissionDialog();
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app requires camera, storage, and contacts permissions to function properly. '
            'Please grant these permissions in the app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _handleFilePicker() async {
    if (!mounted) return <String>[];

    try {
      final String? choice = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Choose Option',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Colors.pinkAccent,
                    ),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(ctx, 'camera'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Colors.pinkAccent,
                    ),
                    title: const Text('Gallery'),
                    onTap: () => Navigator.pop(ctx, 'gallery'),
                  ),
                  if (!Platform.isIOS)
                    ListTile(
                      leading: const Icon(
                        Icons.folder_open,
                        color: Colors.pinkAccent,
                      ),
                      title: const Text('Files'),
                      onTap: () => Navigator.pop(ctx, 'files'),
                    ),
                  ListTile(
                    leading: const Icon(
                      Icons.contacts,
                      color: Colors.pinkAccent,
                    ),
                    title: const Text('Contacts'),
                    onTap: () => Navigator.pop(ctx, 'contacts'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      );

      if (choice == 'camera') {
        if (await Permission.camera.request().isGranted) {
          final XFile? photo = await ImagePicker().pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          if (photo != null) return [Uri.file(photo.path).toString()];
        } else {
          _showError('Camera permission denied');
        }
      } else if (choice == 'gallery') {
        if (await Permission.photos.request().isGranted) {
          final List<XFile> images = await ImagePicker().pickMultiImage(
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          return images.map((f) => Uri.file(f.path).toString()).toList();
        } else {
          _showError('Photos permission denied');
        }
      } else if (choice == 'files' && !Platform.isIOS) {
        final bool storagePermission =
            Platform.isAndroid
                ? await Permission.storage.request().isGranted
                : true;

        if (storagePermission) {
          final List<XFile> files = await openFiles(
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'Images',
                extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
              ),
              const XTypeGroup(
                label: 'Documents',
                extensions: ['pdf', 'doc', 'docx', 'txt'],
              ),
            ],
          );
          return files.map((f) => Uri.file(f.path).toString()).toList();
        } else {
          _showError('Storage permission denied');
        }
      } else if (choice == 'contacts') {
        if (await Permission.contacts.request().isGranted) {
          _showError('Contact picker feature will be implemented here');
        } else {
          _showError('Contacts permission denied');
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      if (mounted) _showError('Error selecting files: ${e.toString()}');
    }

    return <String>[];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            final shouldPop = await _handleBack();
            if (shouldPop && mounted) Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri(_urls[0]),
                ), // start at home
                pullToRefreshController:
                    (Platform.isAndroid || Platform.isIOS)
                        ? _pullToRefreshController
                        : null,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportZoom: true,
                  useShouldOverrideUrlLoading: true,
                  allowFileAccess: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useHybridComposition: true,
                  minimumFontSize: 12,
                  initialScale: 1,
                  // Enhanced settings for better interaction
                  disableHorizontalScroll: false,
                  disableVerticalScroll: false,
                  verticalScrollBarEnabled: true,
                  horizontalScrollBarEnabled: true,
                  // Improve touch handling
                  supportMultipleWindows: true,
                  // Cache settings
                  cacheEnabled: true,
                  // Allow content access
                  allowContentAccess: true,
                  // Improve rendering
                  hardwareAcceleration: true,
                  // Better compatibility
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  // User agent
                  userAgent:
                      Platform.isAndroid
                          ? 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36'
                          : null,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;

                  // JS handler for date/time picker
                  controller.addJavaScriptHandler(
                    handlerName: 'showFlutterPicker',
                    callback: (args) async {
                      if (args.length < 2 || !mounted) return;
                      String inputId = args[0].toString();
                      String inputType = args[1].toString();
                      try {
                        if (inputType == 'time') {
                          await _handleTimePicker(controller, inputId);
                        } else if (inputType == 'date') {
                          await _handleDatePicker(controller, inputId);
                        }
                      } catch (e) {
                        debugPrint('Error handling picker: $e');
                      }
                    },
                  );

                  // JS handler for file picker
                  controller.addJavaScriptHandler(
                    handlerName: 'showFilePicker',
                    callback: (args) async {
                      if (!mounted) return <String>[];
                      try {
                        final files = await _handleFilePicker();
                        return files;
                      } catch (e) {
                        debugPrint('Error handling file picker: $e');
                        return <String>[];
                      }
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  if (mounted) setState(() => _isLoading = true);
                },
                onLoadStop: (controller, url) async {
                  if (mounted) setState(() => _isLoading = false);
                  if (Platform.isAndroid || Platform.isIOS) {
                    _pullToRefreshController?.endRefreshing();
                  }

                  // Inject JavaScript to improve button responsiveness
                  await controller.evaluateJavascript(
                    source: """
                    (function() {
                      // Remove any touch delay
                      document.addEventListener('touchstart', function(){}, {passive: true});
                      
                      // Ensure all buttons and clickable elements are accessible
                      var style = document.createElement('style');
                      style.innerHTML = `
                        * {
                          -webkit-tap-highlight-color: rgba(0,0,0,0);
                          -webkit-touch-callout: none;
                        }
                        button, a, [role="button"], [onclick] {
                          cursor: pointer !important;
                          pointer-events: auto !important;
                          touch-action: manipulation !important;
                        }
                      `;
                      document.head.appendChild(style);
                      
                      // Handle window.open() calls (for View Detail, View PDF buttons)
                      var originalWindowOpen = window.open;
                      window.open = function(url, name, specs) {
                        console.log('JBRC WebView: window.open intercepted - URL:', url);
                        
                        // If it's a same-origin URL, navigate in current window
                        if (url && url.indexOf('jodhpurbombay.vercel.app') !== -1) {
                          window.location.href = url;
                          return window;
                        }
                        
                        // Otherwise, call original window.open
                        return originalWindowOpen.call(this, url, name, specs);
                      };
                      
                      // Handle target="_blank" links
                      document.addEventListener('click', function(e) {
                        var target = e.target;
                        while (target && target.tagName !== 'A') {
                          target = target.parentElement;
                        }
                        
                        if (target && target.tagName === 'A' && target.target === '_blank') {
                          var href = target.href;
                          console.log('JBRC WebView: _blank link clicked:', href);
                          
                          // If it's a same-origin link, prevent default and navigate
                          if (href && href.indexOf('jodhpurbombay.vercel.app') !== -1) {
                            e.preventDefault();
                            window.location.href = href;
                          }
                        }
                      }, true);
                      
                      console.log('JBRC WebView: Enhanced touch handling loaded');
                    })();
                  """,
                  );
                },
                onConsoleMessage: (controller, consoleMessage) {
                  // Log console messages for debugging
                  debugPrint(
                    'WebView Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}',
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (uri == null) return NavigationActionPolicy.ALLOW;
                  final urlStr = uri.toString();

                  // tel:
                  if (uri.scheme == 'tel') {
                    try {
                      final telUri = Uri.parse('tel:${uri.path}');
                      if (await canLaunchUrl(telUri)) {
                        await launchUrl(
                          telUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        _showError('Phone call not supported on this device.');
                      }
                    } catch (e) {
                      _showError('Error making phone call: ${e.toString()}');
                    }
                    return NavigationActionPolicy.CANCEL;
                  }

                  // WhatsApp
                  if (urlStr.contains("wa.me") ||
                      urlStr.contains("api.whatsapp.com")) {
                    try {
                      final whatsAppUri = Uri.parse(urlStr);
                      if (await canLaunchUrl(whatsAppUri)) {
                        await launchUrl(
                          whatsAppUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        _showError('WhatsApp is not installed on this device.');
                      }
                    } catch (e) {
                      _showError('Error opening WhatsApp: ${e.toString()}');
                    }
                    return NavigationActionPolicy.CANCEL;
                  }

                  // mailto:
                  if (uri.scheme == 'mailto') {
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        _showError('No email app available.');
                      }
                    } catch (e) {
                      _showError('Error opening email: ${e.toString()}');
                    }
                    return NavigationActionPolicy.CANCEL;
                  }

                  // External links - allow jodhpurbombay.vercel.app to stay within the app
                  if (!urlStr.contains('jodhpurbombay.vercel.app') &&
                      (uri.scheme == 'http' || uri.scheme == 'https')) {
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } catch (e) {
                      _showError(
                        'Error opening external link: ${e.toString()}',
                      );
                    }
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                onDownloadStartRequest: (controller, downloadRequest) async {
                  final url = downloadRequest.url.toString();

                  // If it's a PDF, open it for viewing/printing instead of downloading
                  if (url.contains('.pdf') || url.contains('pdf')) {
                    await _openPdfForPrint(url);
                  } else {
                    // For non-PDF files, download as usual
                    await _handleDownload(downloadRequest);
                  }
                },
                onLoadError: (controller, url, code, message) {
                  debugPrint('WebView Load Error: $code - $message at $url');
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  debugPrint(
                    'WebView HTTP Error: $statusCode - $description at $url',
                  );
                },
                onReceivedHttpAuthRequest: (controller, challenge) async {
                  return HttpAuthResponse(
                    username: '',
                    password: '',
                    action: HttpAuthResponseAction.CANCEL,
                  );
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer(),
                  ),
                  Factory<HorizontalDragGestureRecognizer>(
                    () => HorizontalDragGestureRecognizer(),
                  ),
                  Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                  Factory<LongPressGestureRecognizer>(
                    () => LongPressGestureRecognizer(),
                  ),
                },
                onCreateWindow: (controller, createWindowAction) async {
                  // Handle popup windows (like View Detail, View PDF buttons)
                  final url = createWindowAction.request.url;

                  if (url != null) {
                    final urlString = url.toString();
                    debugPrint('Opening new window: $urlString');

                    // Check if it's a PDF - open it for viewing/printing instead of downloading
                    if (urlString.contains('.pdf') ||
                        urlString.contains('pdf')) {
                      // Open PDF in a viewer with print option
                      try {
                        await _openPdfForPrint(urlString);
                      } catch (e) {
                        debugPrint('PDF open error: $e');
                      }
                      return true;
                    }

                    // Check if it's a download (not PDF)
                    if (urlString.contains('download') &&
                        !urlString.contains('pdf')) {
                      // Trigger download for non-PDF files
                      try {
                        await _handleDownload(
                          DownloadStartRequest(
                            url: url,
                            suggestedFilename:
                                urlString.split('/').last.split('?').first,
                            contentLength: 0,
                          ),
                        );
                      } catch (e) {
                        debugPrint('Download error: $e');
                      }
                      return true;
                    }

                    // For other popups (View Detail, etc.), open in the same webview
                    if (urlString.contains('jodhpurbombay.vercel.app')) {
                      // Load in the same webview
                      await controller.loadUrl(
                        urlRequest: URLRequest(url: url),
                      );
                      return true;
                    } else {
                      // External links - open in browser
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        debugPrint('Error opening URL: $e');
                      }
                      return true;
                    }
                  }

                  return true;
                },
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.pinkAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar:
              (Platform.isAndroid || Platform.isIOS)
                  ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      selectedItemColor: Colors.pinkAccent,
                      unselectedItemColor: Colors.grey.shade600,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedFontSize: 12,
                      unselectedFontSize: 10,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      onTap: (index) {
                        if (mounted && index < _urls.length) {
                          setState(() => _currentIndex = index);
                          _webViewController?.loadUrl(
                            urlRequest: URLRequest(url: WebUri(_urls[index])),
                          );
                        }
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_rounded, size: 28),
                          activeIcon: Icon(Icons.home_rounded, size: 32),
                          label: "Home",
                          tooltip: "Go to Home",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.create_rounded, size: 28),
                          activeIcon: Icon(Icons.create_rounded, size: 32),
                          label: "Create Bilty",
                          tooltip: "Create New Bilty",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.view_list_rounded, size: 28),
                          activeIcon: Icon(Icons.view_list_rounded, size: 32),
                          label: "View Bilty",
                          tooltip: "View All Bilty",
                        ),
                      ],
                    ),
                  )
                  : null,
        ),
      ),
    );
  }

  Future<void> _handleTimePicker(
    InAppWebViewController controller,
    String inputId,
  ) async {
    if (!mounted) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final value =
          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
      await controller.evaluateJavascript(
        source: """
          (function() {
            var input = document.getElementById('$inputId');
            if (input) {
              input.value = '$value';
              input.dispatchEvent(new Event('input', { bubbles: true }));
              input.dispatchEvent(new Event('change', { bubbles: true }));
              return true;
            } else {
              console.error("Time input ID '$inputId' not found.");
              return false;
            }
          })();
        """,
      );
    }
  }

  Future<void> _handleDatePicker(
    InAppWebViewController controller,
    String inputId,
  ) async {
    if (!mounted) return;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final value =
          "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      await controller.evaluateJavascript(
        source: """
          (function() {
            var input = document.getElementById('$inputId');
            if (input) {
              input.value = '$value';
              input.dispatchEvent(new Event('input', { bubbles: true }));
              input.dispatchEvent(new Event('change', { bubbles: true }));
              return true;
            } else {
              console.error("Date input ID '$inputId' not found.");
              return false;
            }
          })();
        """,
      );
    }
  }

  Future<bool> _handleBack() async {
    try {
      if (_webViewController != null && await _webViewController!.canGoBack()) {
        _webViewController!.goBack();
        return false;
      }

      final DateTime now = DateTime.now();
      if (_lastBackPressed == null ||
          now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
        _lastBackPressed = now;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.pinkAccent,
            ),
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error handling back button: $e');
      return true;
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: Colors.white,
          onPressed: () async {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleDownload(DownloadStartRequest downloadRequest) async {
    try {
      final url = downloadRequest.url.toString();
      final suggestedFilename =
          downloadRequest.suggestedFilename ??
          url.split('/').last.split('?').first;

      debugPrint('Download started: $url');
      debugPrint('Suggested filename: $suggestedFilename');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Downloading file...'),
              ],
            ),
            backgroundColor: Colors.pinkAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // For mobile platforms (Android/iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        // Request storage permission
        if (Platform.isAndroid) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            final manageStatus =
                await Permission.manageExternalStorage.request();
            if (!manageStatus.isGranted) {
              _showError('Storage permission denied. Cannot download file.');
              return;
            }
          }
        }

        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          // Save to Downloads folder on Android
          final downloadsPath = '/storage/emulated/0/Download';
          directory = Directory(downloadsPath);
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final filePath = '${directory.path}/$suggestedFilename';
          final file = File(filePath);

          // Download the file
          final response = await http.get(Uri.parse(url));
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            _showSuccess('File downloaded successfully!');

            // Try to open the file
            try {
              await OpenFile.open(filePath);
            } catch (e) {
              debugPrint('Could not open file: $e');
            }
          }

          debugPrint('File saved to: $filePath');
        }
      }
      // For desktop platforms (Windows, macOS, Linux)
      else {
        // Use file selector to choose save location
        final fileName = suggestedFilename;
        final savePath = await getSavePath(suggestedName: fileName);

        if (savePath != null) {
          final file = File(savePath);

          // Download the file
          final response = await http.get(Uri.parse(url));
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            _showSuccess('File saved successfully!');

            // Try to open the file
            try {
              await OpenFile.open(savePath);
            } catch (e) {
              debugPrint('Could not open file: $e');
            }
          }

          debugPrint('File saved to: $savePath');
        } else {
          if (mounted) {
            _showError('Download cancelled');
          }
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        _showError('Download failed: ${e.toString()}');
      }
    }
  }

  Future<void> _openPdfForPrint(String pdfUrl) async {
    try {
      debugPrint('Opening PDF for print: $pdfUrl');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Opening PDF...'),
              ],
            ),
            backgroundColor: Colors.pinkAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // For mobile and desktop - open PDF in external viewer with print capability
      final pdfUri = Uri.parse(pdfUrl);

      if (await canLaunchUrl(pdfUri)) {
        // Launch in external application (default PDF viewer)
        // This allows users to print directly from the PDF viewer
        await launchUrl(pdfUri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF opened! Use your PDF viewer to print.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Fallback: Download and open
        debugPrint('Cannot launch URL, falling back to download');

        // Download the PDF first
        final response = await http.get(pdfUri);
        final bytes = response.bodyBytes;

        // Get temporary directory
        Directory? directory;
        if (Platform.isAndroid || Platform.isIOS) {
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory();
            final downloadsPath = '/storage/emulated/0/Download';
            directory = Directory(downloadsPath);
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getTemporaryDirectory();
        }

        if (directory != null) {
          final fileName = pdfUrl.split('/').last.split('?').first;
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(bytes);

          // Open the PDF file
          final result = await OpenFile.open(filePath);

          if (mounted) {
            if (result.type == ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'PDF opened! Use print option in your PDF viewer.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              _showError('Could not open PDF. File saved to: $filePath');
            }
          }

          debugPrint('PDF saved and opened: $filePath');
        }
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      if (mounted) {
        _showError('Failed to open PDF: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
