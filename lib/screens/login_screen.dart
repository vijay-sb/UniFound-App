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
  }

  // ------------------------------------------------------------
  // CREATE A FAKE "CAMPUS" IMAGE (NO ASSETS REQUIRED)
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
        onPointerHover: (e) => setState(() => _cursorPos = e.localPosition),
        onPointerMove: (e) => setState(() => _cursorPos = e.localPosition),
        child: Stack(
          children: [
            // 🔦 TORCH REVEAL BACKGROUND
            RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: ImageRevealPainter(_cursorPos, _campusImage),
              ),
            ),

            // 🟢 PULSING TORCH CURSOR
            RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: TorchCursorPainter(
                  _cursorPos,
                  _pulseController,
                ),
              ),
            ),

            // --------------------------------------------------
            // 🔒 YOUR LOGIN UI — UNCHANGED
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
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Secure • Private • AI-Powered',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.w500,
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
                            margin:
                                const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.2)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF00FF88)
                                    .withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00FF88)
                                      .withOpacity(0.15),
                                  blurRadius: 40,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _inputField(
                                    _emailController,
                                    'University Email',
                                    Icons.email_outlined,
                                    false,
                                  ),
                                  const SizedBox(height: 20),
                                  _inputField(
                                    _passwordController,
                                    'Password',
                                    Icons.lock_outlined,
                                    true,
                                  ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        enabled: !_isLoading,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: const Color(0xFF00FF88)),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00FF88), Color(0xFF00CC6A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

// ================================================================
// 🔦 IMAGE REVEAL PAINTER (CORRECT & WORKING)
// ================================================================
class ImageRevealPainter extends CustomPainter {
  final Offset cursorPos;
  final ui.Image? image;

  ImageRevealPainter(this.cursorPos, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1️⃣ Draw the solid black background first
    canvas.drawRect(rect, Paint()..color = Colors.black);

    if (image == null) return;

    // 2️⃣ Create a new layer for the reveal effect
    canvas.saveLayer(rect, Paint());

    // 3️⃣ Draw the "Light Beam" (This defines WHERE the image will appear)
    final torchPaint = Paint()
      ..color = Colors.white // Color doesn't matter for masking
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60); // Soft edges
    
    canvas.drawCircle(cursorPos, 180, torchPaint); // Adjust radius as needed

    // 4️⃣ Use BlendMode.srcIn to draw the image ONLY inside the circle above
    final imagePaint = Paint()..blendMode = ui.BlendMode.srcIn;
    
    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
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

    // 🌟 INNER BRIGHT CORE
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

    // 🌫 OUTER GLOW (torch spread)
    final glowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    canvas.drawCircle(cursorPos, outerRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant TorchCursorPainter old) =>
      old.cursorPos != cursorPos;
}
