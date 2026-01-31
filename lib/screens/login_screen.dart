import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  Offset _cursorPos = const Offset(200, 200);

  // 🔑 INTRO SCAN CONTROL
  bool _introScanActive = true;

  late AnimationController _pulseController;
  static ui.Image? _campusImage;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadCampusImage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if it's a mobile platform
      final isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;

      // On Web, browsers can mimic mobile, so we double-check width
      final isSmallScreen = MediaQuery.of(context).size.width < 600;

      if (isMobile || isSmallScreen) {
        // Give the UI a frame to settle so MediaQuery is accurate
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _startIntroScan();
        });
      } else {
        _introScanActive = false;
      }
    });
  }

  // ------------------------------------------------------------
  // LOAD IMAGE
  // ------------------------------------------------------------
  Future<void> _loadCampusImage() async {
    final data = await rootBundle.load('assets/images/campus.jpg');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _campusImage = frame.image;
    if (mounted) setState(() {});
  }

  // ------------------------------------------------------------
  // INTRO SCAN (AUTO STOPS ON USER INTERACTION)
  // ------------------------------------------------------------
  Future<void> _startIntroScan() async {
    if (!mounted) return;

    // FIX: Replaced deprecated 'window' with MediaQuery
    final size = MediaQuery.of(context).size;

    final points = [
      const Offset(60, 120),
      Offset(size.width - 60, 120),
      Offset(60, size.height * 0.45),
      Offset(size.width - 60, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.5),
    ];

    const stepsPerSegment = 30;
    const stepDelay = Duration(milliseconds: 16);

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      for (int step = 0; step <= stepsPerSegment; step++) {
        if (!mounted || !_introScanActive) return;

        final t = step / stepsPerSegment;
        setState(() {
          _cursorPos = Offset.lerp(start, end, t)!;
        });

        await Future.delayed(stepDelay);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------
  // Inside _LoginScreenState class in login_screen.dart
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final response = await api.post(loginEndpoint, request.toJson());

      // FIX: Match the backend key 'access_token' from your screenshot
      if (response.containsKey('access_token')) {
        await api.saveToken(response['access_token']);

        if (!mounted) return;
        // Navigate to home (ensure this route is defined in main.dart)
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception("Token not found in response");
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F10),
      body: Listener(
        onPointerMove: (e) {
          if (_introScanActive) {
            _introScanActive = false; // 🛑 STOP INTRO SCAN
          }
          setState(() => _cursorPos = e.localPosition);
        },
        onPointerHover: (e) {
          if (_introScanActive) {
            _introScanActive = false; // 🛑 STOP INTRO SCAN
          }
          setState(() => _cursorPos = e.localPosition);
        },
        child: Stack(
          children: [
            // IMAGE REVEAL
            CustomPaint(
              size: Size.infinite,
              painter: ImageRevealPainter(_cursorPos, _campusImage),
            ),

            // CURSOR CORE (NO GLOW)
            CustomPaint(
              size: Size.infinite,
              painter: TorchCursorPainter(_cursorPos, _pulseController),
            ),

            // UI CARD
            Material(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withValues(alpha: 0.4), // FIX: withValues
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF9CFF00)
                            .withValues(alpha: 0.2), // FIX: withValues
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/unifound_logo.png',
                            height: 100,
                          ),
                          const SizedBox(height: 32),
                          _field(_emailController, 'University Email',
                              Icons.email_outlined, false),
                          const SizedBox(height: 24),
                          _field(_passwordController, 'Password',
                              Icons.lock_outline, true),
                          const SizedBox(height: 32),
                          _loginButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, bool o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08), // FIX: withValues
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.1)), // FIX: withValues
          ),
          child: TextFormField(
            controller: c,
            obscureText: o,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(i, color: const Color(0xFF9CFF00), size: 20),
              border: InputBorder.none,
              hintText: 'Enter $l',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9CFF00),
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

// ================================================================
// IMAGE REVEAL PAINTER
// ================================================================
class ImageRevealPainter extends CustomPainter {
  final Offset pos;
  final ui.Image? image;

  ImageRevealPainter(this.pos, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = const Color(0xFF0E0F10));

    if (image == null) return;

    canvas.saveLayer(rect, Paint());

    final maskPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    canvas.drawCircle(pos, 200, maskPaint);

    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
      rect,
      Paint()..blendMode = BlendMode.srcIn,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ImageRevealPainter old) =>
      old.pos != pos || old.image != image;
}

// ================================================================
// CURSOR CORE (INVISIBLE / NO GLOW)
// ================================================================
class TorchCursorPainter extends CustomPainter {
  final Offset pos;
  final Animation<double> anim;

  TorchCursorPainter(this.pos, this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally empty — cursor core disabled
  }

  @override
  bool shouldRepaint(covariant TorchCursorPainter old) => old.pos != pos;
}
