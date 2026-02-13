import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/item_dto.dart';
import '../services/item_api_service.dart';

class MyReportsScreen extends StatefulWidget {
  final ItemApiService? apiService;

  const MyReportsScreen({super.key, this.apiService});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Future<List<ItemDto>> _future;
  String _searchQuery = '';
  final Color accentColor = const Color(0xFF9CFF00);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.apiService != null) {
      // NOTE: You'll need to add this method to your ItemApiService
      _future = widget.apiService!.fetchMyReportedItems();
    } else {
      _future = Future.value(_mockReports);
      debugPrint("Warning: apiService was null, falling back to mock reports.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Re-using the same Stack to keep the animated particle background
      body: Stack(
        children: [
          const Positioned.fill(child: _EnhancedParticleBackground()),
          SafeArea(
            child: Column(
              children: [
                // HEADER SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "MY REPORTS",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                _StyledSearchBar(
                  accent: accentColor,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                ),

                Expanded(
                  child: FutureBuilder<List<ItemDto>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: accentColor),
                        );
                      }

                      if (snapshot.hasError) {
                        return _ErrorState(
                          onRetry: () => setState(() => _loadData()),
                        );
                      }

                      final items = (snapshot.data ?? []).where((i) {
                        return i.category
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            i.campusZone.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (items.isEmpty) {
                        return const _EmptyState();
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _ReportItemCard(
                          item: items[index],
                          accent: accentColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── GLASS REPORT CARD ───────────────── */

class _ReportItemCard extends StatefulWidget {
  final ItemDto item;
  final Color accent;

  const _ReportItemCard({required this.item, required this.accent});

  @override
  State<_ReportItemCard> createState() => _ReportItemCardState();
}

class _ReportItemCardState extends State<_ReportItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isHovered
                      ? widget.accent
                      : widget.accent.withValues(alpha: 0.3),
                  width: _isHovered ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.category.toUpperCase(),
                    style: TextStyle(
                        color: widget.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),

                  // Status tag specifically for reported items
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: const Text(
                      'REPORTED',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: widget.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.campusZone,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.white.withValues(alpha: 0.5), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Reported on: ${widget.item.foundAt.toString().split(' ').first}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13),
                      ),
                    ],
                  ),
// Spacer and View Details button removed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────────── BACKGROUND & UI COMPONENTS ───────────────── */
// (Keep these exactly as they are in your BlindFeedScreen)

class _EnhancedParticleBackground extends StatefulWidget {
  const _EnhancedParticleBackground();
  @override
  State<_EnhancedParticleBackground> createState() =>
      _EnhancedParticleBackgroundState();
}

class _EnhancedParticleBackgroundState
    extends State<_EnhancedParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> particles = List.generate(65, (index) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          CustomPaint(painter: _GridPainter(particles, _controller.value)),
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _GridPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF9CFF00).withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    const double step = 50;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    for (var p in particles) {
      final double movingY =
          (p.y * size.height - (progress * size.height * p.speed)) %
              size.height;
      final double movingX =
          (p.x * size.width + (sin(progress * 10 * p.speed) * 20)) % size.width;
      final opacity = (sin(progress * 6.28 + p.randomSeed) + 1) / 2;
      canvas.drawCircle(
          Offset(movingX, movingY),
          p.size,
          Paint()
            ..color = const Color(0xFF9CFF00).withValues(alpha: opacity * 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 4 + 1.5;
  double speed = Random().nextDouble() * 0.4 + 0.2;
  double randomSeed = Random().nextDouble() * 100;
}

class _StyledSearchBar extends StatelessWidget {
  final Color accent;
  final ValueChanged<String> onChanged;
  const _StyledSearchBar({required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search my reports...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(Icons.search, color: accent),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.4))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accent, width: 2)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 80, color: const Color(0xFF9CFF00).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('You haven\'t reported any items yet.',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text('Failed to load reports',
              style: TextStyle(color: Colors.white70)),
          TextButton(
              onPressed: onRetry,
              child: const Text('RETRY',
                  style: TextStyle(color: Color(0xFF9CFF00)))),
        ],
      ),
    );
  }
}

final List<ItemDto> _mockReports = [
  ItemDto(
      id: '101',
      category: 'Keys',
      campusZone: 'Admin Block',
      foundAt: DateTime.now(),
      status: 'REPORTED'),
];
