import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/login_request.dart';
import '../services/api_service.dart';

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
  bool _userInteracted = false;

  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<Offset> _scanAnimation;

  static ui.Image? _campusImage;

  @override
  void initState() {
    super.initState();

    // 🔵 Torch pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // 🔦 Auto scan animation (for mobile)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _scanAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.1, 0.2), end: const Offset(0.9, 0.2)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.9, 0.4), end: const Offset(0.1, 0.4)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.1, 0.6), end: const Offset(0.9, 0.6)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    )..addListener(() {
        if (!_userInteracted && mounted) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _cursorPos = Offset(
              _scanAnimation.value.dx * size.width,
              _scanAnimation.value.dy * size.height,
            );
          });
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shortestSide = MediaQuery.of(context).size.shortestSide;
      if (shortestSide < 900) {
        _scanController.repeat();
      }
    });

    _loadCampusImage();
  }

  // ------------------------------------------------------------
  // LOAD IMAGE
  // ------------------------------------------------------------
  Future<void> _loadCampusImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/campus.jpg');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _campusImage = fi.image;

      if (mounted) setState(() {});
    } catch (e) {
      print('Campus image load failed: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      await api.saveToken(response['token']);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
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
      body: Listener(
        onPointerDown: (_) {
          _userInteracted = true;
          _scanController.stop();
        },
        onPointerHover: (e) {
          _userInteracted = true;
          _scanController.stop();
          setState(() => _cursorPos = e.localPosition);
        },
        onPointerMove: (e) {
          _userInteracted = true;
          _scanController.stop();
          setState(() => _cursorPos = e.localPosition);
        },
        child: Stack(
          children: [
            // 🔦 TORCH REVEAL BACKGROUND
            CustomPaint(
              size: Size.infinite,
              painter: ImageRevealPainter(_cursorPos, _campusImage),
            ),

            // 🟢 TORCH CURSOR
            CustomPaint(
              size: Size.infinite,
              painter: TorchCursorPainter(_cursorPos, _pulseController),
            ),

            // --------------------------------------------------
            // 🔒 LOGIN UI (UNCHANGED)
            // --------------------------------------------------
            Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) => Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.08),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFF00FF88),
                                      Colors.transparent
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF88)
                                          .withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 56,
                                  color: Color(0xFF00FF88),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'CAMPUS LOST & FOUND',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00FF88),
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Center(
                          child: Container(
                            constraints:
                                const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _inputField(
                                      _emailController,
                                      'University Email',
                                      Icons.email_outlined,
                                      false),
                                  const SizedBox(height: 20),
                                  _inputField(
                                      _passwordController,
                                      'Password',
                                      Icons.lock_outlined,
                                      true),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscure,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: !_isLoading,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00FF88)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Sign In'),
    );
  }
}

// ================================================================
// 🔦 IMAGE REVEAL PAINTER
// ================================================================
class ImageRevealPainter extends CustomPainter {
  final Offset cursorPos;
  final ui.Image? image;

  ImageRevealPainter(this.cursorPos, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.black);

    if (image == null) return;

    canvas.saveLayer(rect, Paint());

    final torchPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(cursorPos, 180, torchPaint);

    final imagePaint = Paint()..blendMode = BlendMode.srcIn;

    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(
          0, 0, image!.width.toDouble(), image!.height.toDouble()),
      rect,
      imagePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ImageRevealPainter old) =>
      old.cursorPos != cursorPos || old.image != image;
}

// ================================================================
// 🟢 TORCH CURSOR PAINTER
// ================================================================
class TorchCursorPainter extends CustomPainter {
  final Offset cursorPos;
  final Animation<double> animation;

  TorchCursorPainter(this.cursorPos, this.animation)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = animation.value;

    final innerRadius = 20 + pulse * 6;
    final outerRadius = 60 + pulse * 15;

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.greenAccent.withOpacity(0.95),
          Colors.greenAccent.withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: cursorPos, radius: innerRadius),
      );

    canvas.drawCircle(cursorPos, innerRadius, corePaint);

    final glowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    canvas.drawCircle(cursorPos, outerRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant TorchCursorPainter old) =>
      old.cursorPos != cursorPos;
}
