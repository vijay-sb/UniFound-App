import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/item_dto.dart';
import '../services/item_api_service.dart';

class BlindFeedScreen extends StatefulWidget {
  final ItemApiService? apiService;
  final VoidCallback? onLogout;

  const BlindFeedScreen({super.key, this.apiService, this.onLogout});

  @override
  State<BlindFeedScreen> createState() => _BlindFeedScreenState();
}

class _BlindFeedScreenState extends State<BlindFeedScreen> {
  late Future<List<ItemDto>> _future;
  String _searchQuery = '';
  final Color accentColor = const Color(0xFF9CFF00);

  // Inside _BlindFeedScreenState class
  @override
  void initState() {
    super.initState();
    _loadData(); // Initial load
  }

  // Inside _BlindFeedScreenState class
  void _loadData() {
    if (widget.apiService != null) {
      _future = widget.apiService!.fetchDiscoverItems();
    } else {
      _future = Future.value(_mockItems);
      debugPrint("Warning: apiService was null, falling back to mock data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The glass blur effect
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/found-form'),
            // Using #0c4b75 with 0.7 opacity for a translucent feel
            backgroundColor: const Color(0xFF0C4B75).withValues(alpha: 0.7),
            elevation: 0, // Remove shadow to enhance the glass look
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: const Color(0xFF0C4B75).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Found an item",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _EnhancedParticleBackground()),
          SafeArea(
            child: Column(
              children: [
                // LOGO & PROFILE SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/unifound_logo.png',
                        height: 65,
                        fit: BoxFit.contain,
                      ),
                      // 2. PROFILE CIRCLE FOR LOGOUT (opens menu)
                      PopupMenuButton<String>(
                        tooltip: 'Profile',
                        color: const Color(
                            0xFF121212), // dark grey background for menu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: accentColor.withValues(alpha: 0.18),
                              width: 1.2),
                        ),
                        elevation: 8,
                        onSelected: (value) async {
                          if (value == 'logout') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF121212),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                title: Text('Logout',
                                    style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold)),
                                content: const Text(
                                    'Are you sure you want to logout?',
                                    style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              if (widget.onLogout != null) widget.onLogout!();
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(children: [
                              Icon(Icons.logout, color: accentColor),
                              const SizedBox(width: 8),
                              const Text('Logout',
                                  style: TextStyle(color: Colors.white))
                            ]),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white12,
                            child:
                                Icon(Icons.person_outline, color: accentColor),
                          ),
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

                      // 1. ERROR STATE
                      if (snapshot.hasError) {
                        return _ErrorState(
                          onRetry: () => setState(() => _loadData()),
                        );
                      }
                      // --- DATA PROCESSING START ---

                      // 1. Filter for status and search query
                      final rawItems = (snapshot.data ?? []).where((i) {
                        final matchesStatus =
                            i.status == 'VERIFIED' || i.status == 'AVAILABLE';
                        final matchesSearch = i.category
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            i.campusZone.toLowerCase().contains(_searchQuery);
                        return matchesStatus && matchesSearch;
                      }).toList();

                      // 2. Group items by [Category + Zone + Date]
                      final Map<String, List<ItemDto>> groupedMap = {};
                      for (var item in rawItems) {
                        // We use the date part only (YYYY-MM-DD) to group items found on the same day
                        final dateKey =
                            item.foundAt.toString().split(' ').first;
                        final groupingKey =
                            "${item.category.toLowerCase()}_${item.campusZone.toLowerCase()}_$dateKey";

                        groupedMap.putIfAbsent(groupingKey, () => []).add(item);
                      }

                      // 3. Transform groups into a list of display DTOs
                      final List<ItemDto> items =
                          groupedMap.values.map((group) {
                        final firstItem = group.first;
                        final count = group.length;

                        return ItemDto(
                          id: firstItem.id, // Keep the first ID for the key
                          // Requirement 4: Update text if multiple items exist
                          category: count > 1
                              ? "$count ${firstItem.category}s"
                              : firstItem.category,
                          campusZone: firstItem.campusZone,
                          foundAt: firstItem.foundAt,
                          status: group.any((i) => i.status == 'AVAILABLE')
                              ? 'AVAILABLE'
                              : 'VERIFIED', // If any item in group is available, show Available
                        );
                      }).toList();

                      // --- DATA PROCESSING END ---

                      // 2. EMPTY STATE
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
                          childAspectRatio: 1.3,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _BlindItemCard(
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

/* ───────────────── GLASS ITEM CARD ───────────────── */

class _BlindItemCard extends StatefulWidget {
  final ItemDto item;
  final Color accent;

  const _BlindItemCard({required this.item, required this.accent});

  @override
  State<_BlindItemCard> createState() => _BlindItemCardState();
}

class _BlindItemCardState extends State<_BlindItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine if the item can be claimed
    final bool isAvailable = widget.item.status == 'AVAILABLE';

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
                  // STATUS TAG SECTION
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isAvailable
                          ? 'AVAILABLE'
                          : 'VERIFIED (Wait for item to be available)',
                      style: TextStyle(
                        color: isAvailable
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // LOCATION SECTION
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
                  // DATE SECTION
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.white.withValues(alpha: 0.5), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Found: ${widget.item.foundAt.toString().split(' ').first}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // CLAIM BUTTON (Requirement 3: Disabled if Verified)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (_isHovered && isAvailable)
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.6),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () {
                              // Action for claiming
                            }
                          : null, // Disables button when null
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isAvailable ? widget.accent : Colors.grey[850],
                        disabledBackgroundColor: Colors.white10,
                        foregroundColor: Colors.black,
                        disabledForegroundColor: Colors.white24,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isAvailable ? 'I LOST THIS' : 'PROCESSING...',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────────── ENHANCED BACKGROUND ───────────────── */

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
  // 4. MORE PARTICLES
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
      builder: (context, child) {
        return CustomPaint(painter: _GridPainter(particles, _controller.value));
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _GridPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. HIGHER OPACITY GRIDS
    final gridPaint = Paint()
      ..color = const Color(0xFF9CFF00)
          .withValues(alpha: 0.15) // Increased visibility
      ..strokeWidth = 1.0;

    const double step = 50; // Larger grid size
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 4. MOVING PARTICLES
    for (var p in particles) {
      final double movingY =
          (p.y * size.height - (progress * size.height * p.speed)) %
              size.height;
      final double movingX =
          (p.x * size.width + (sin(progress * 10 * p.speed) * 20)) % size.width;

      final opacity = (sin(progress * 6.28 + p.randomSeed) + 1) / 2;
      final particlePaint = Paint()
        ..color = const Color(0xFF9CFF00).withValues(alpha: opacity * 0.4);

      canvas.drawCircle(Offset(movingX, movingY), p.size, particlePaint);
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

/* ───────────────── SEARCH BAR ───────────────── */

class _StyledSearchBar extends StatelessWidget {
  final Color accent;
  final ValueChanged<String> onChanged;

  const _StyledSearchBar({required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 25,
              spreadRadius: -5)
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search items or locations...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(Icons.search, color: accent),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent.withValues(alpha: 0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }
}

/* ───────────────── STATES ───────────────── */



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
          const Text('Failed to load items',
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

/* ───────────────── MOCK DATA ───────────────── */

final List<ItemDto> _mockItems = [
  ItemDto(
    id: '1',
    category: 'Wallet',
    campusZone: 'Main Canteen',
    foundAt: DateTime.now().subtract(const Duration(days: 1)),
    status: 'VERIFIED', // Added status for mock data
  ),
  ItemDto(
    id: '2',
    category: 'ID Card',
    campusZone: 'Library',
    foundAt: DateTime.now().subtract(const Duration(hours: 6)),
    status: 'VERIFIED',
  ),
  ItemDto(
    id: '3',
    category: 'Laptop',
    campusZone: 'AB 3',
    foundAt: DateTime.now().subtract(const Duration(days: 2)),
    status: 'VERIFIED',
  ),
];
