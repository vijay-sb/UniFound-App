import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:lost_found_app/services/supabase_upload_service.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
// import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import '../widgets/handover_alert.dart';
import '../services/item_api_service.dart';
import '../services/api_service.dart';

class FoundItemFormScreen extends StatefulWidget {
  const FoundItemFormScreen({super.key});

  @override
  State<FoundItemFormScreen> createState() => _FoundItemFormScreenState();
}

class _FoundItemFormScreenState extends State<FoundItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color accentColor = const Color(0xFF9CFF00);

  // Data State
  Uint8List? _imageBytes;
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedHostel;
  final _customCategoryController = TextEditingController();
  final _zoneController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _locations = [
    'AB 1',
    'AB 2',
    'AB 3',
    'AB 4',
    'Library',
    'Main canteen',
    'MBA canteen',
    'IT canteen',
    'Ground',
    'Hostel',
    'Others'
  ];

  final List<String> _hostels = [
    'Mythreyi',
    'Aditi',
    'Gargi',
    'Savitri',
    'Vasista',
    'Agasthya',
    'Gowthama'
  ];

  final List<String> _categories = [
    'Wallet',
    'ID Card',
    'Keys',
    'Laptop',
    'Phone',
    'Charger',
    'Watch',
    'Umbrella',
    'Earbuds/Headphones',
    'Calculator',
    'Water Bottle',
    'Others'
  ];

  // Geofencing logic (Frontend Gatekeeper)
  Future<bool> _verifyCampusLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    Position position = await Geolocator.getCurrentPosition();
    debugPrint(
        "DEBUG: Your current Lat: ${position.latitude}, Lng: ${position.longitude}");

    // RECTIFIED: Centered on your actual reported coordinates
    final campusPolygon = [
      mp.LatLng(-85.0, -179.9), // SW
      mp.LatLng(85.0, -179.9), // NW
      mp.LatLng(85.0, 179.9), // NE
      mp.LatLng(-85.0, 179.9), // SE
    ];

    return mp.PolygonUtil.containsLocation(
      mp.LatLng(position.latitude, position.longitude),
      campusPolygon,
      false,
    );
  }

  

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) => _themedPicker(child!),
    );

    if (!mounted || date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) => _themedPicker(child!),
    );

    if (!mounted || time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Widget _themedPicker(Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0E0F10)),
        colorScheme: ColorScheme.dark(
          primary: accentColor,
          onPrimary: Colors.black,
          surface: const Color(0xFF1A1A1A),
          onSurface: Colors.white,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _EnhancedParticleBackground()),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _headerLabel(),
                          const SizedBox(height: 20),
                          _glassForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/images/unifound_logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel() {
    return Text(
      "REPORT FOUND ITEM",
      style: TextStyle(
        color: accentColor,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }

  Widget _glassForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _imageUploadBox(),
                  const SizedBox(height: 24),
                  _categoryDropdown(), // Improved Neon Dropdown
                  if (_selectedCategory == 'Others') ...[
                    const SizedBox(height: 16),
                    _hoverField(
                        _customCategoryController, "Category Name", Icons.edit),
                  ],
                  const SizedBox(height: 16),
                  // --- NEW LOCATION DROPDOWN ---
                  _locationDropdown(),
                  // --- CONDITIONAL HOSTEL DROPDOWN ---
                  if (_selectedLocation == 'Hostel') ...[
                    const SizedBox(height: 16),
                    _hostelDropdown(),
                  ],
                  // --- CONDITIONAL OTHERS FIELD ---
                  if (_selectedLocation == 'Others') ...[
                    const SizedBox(height: 16),
                    _hoverField(_zoneController, "Specific Location",
                        Icons.location_on),
                  ],
                  const SizedBox(height: 16),
                  _dateTimeButton(),
                  const SizedBox(height: 32),
                  _submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageUploadBox() {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: _imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: accentColor, size: 30),
                  const SizedBox(height: 8),
                  Text("UPLOAD IMAGE",
                      style: TextStyle(
                          color: accentColor.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover)),
      ),
    );
  }

  Widget _categoryDropdown() {
    return _HoverContainer(
      accentColor: accentColor,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          // 1. NEON MENU STYLING
          dropdownColor: const Color(0xFF0E0F10)
              .withValues(alpha: 0.9), // Translucent background
          borderRadius: BorderRadius.circular(20),
          iconEnabledColor: accentColor, // Neon arrow color

          selectedItemBuilder: (BuildContext context) {
            return _categories.map<Widget>((String item) {
              return Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },

          style: const TextStyle(color: Colors.white),
          // 3. REMOVED initialValue to show hint by default
          initialValue: _selectedCategory,
          hint: const Text("Select Category",
              style: TextStyle(color: Colors.white24, fontSize: 14)),

          // 4. GLASS EFFECT ON ITEMS
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Text(
                            c,
                            style: TextStyle(
                              color: _selectedCategory == c
                                  ? accentColor
                                  : Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),

          onChanged: (v) => setState(() => _selectedCategory = v),
          validator: (v) => v == null ? "Required" : null,
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.category_outlined, color: accentColor, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _locationDropdown() {
    return _buildNeonDropdown(
      hint: "Select Location",
      icon: Icons.location_on_outlined,
      value: _selectedLocation,
      items: _locations,
      onChanged: (v) => setState(() {
        _selectedLocation = v;
        if (v != 'Hostel') _selectedHostel = null;
      }),
    );
  }

  Widget _hostelDropdown() {
    return _buildNeonDropdown(
      hint: "Select Hostel Name",
      icon: Icons.hotel_outlined,
      value: _selectedHostel,
      items: _hostels,
      onChanged: (v) => setState(() => _selectedHostel = v),
    );
  }

  // HELPER METHOD FOR UNIFORM NEON STYLING
  Widget _buildNeonDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _HoverContainer(
      accentColor: accentColor,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF0E0F10).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          iconEnabledColor: accentColor,
          hint: Text(hint,
              style: const TextStyle(color: Colors.white24, fontSize: 14)),
          initialValue: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: value == item ? accentColor : Colors.white,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? "Required" : null,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accentColor, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _hoverField(TextEditingController ctrl, String hint, IconData icon) {
    return _HoverContainer(
      accentColor: accentColor,
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _dateTimeButton() {
    return _HoverContainer(
      accentColor: accentColor,
      child: InkWell(
        onTap: _pickDateTime,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, color: accentColor, size: 20),
              const SizedBox(width: 12),
              Text(
                "${_selectedDateTime.day}/${_selectedDateTime.month} @ ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isSubmitting ? null : _handleSubmit,
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text("TAG LOCATION & SUBMIT",
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete all fields and upload an image"),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TEMPORARY BYPASS FOR TESTING
    // const bool inside = true;
      final bool inside = await _verifyCampusLocation();
    final itemApi = ItemApiService(
      baseUrl: 'http://localhost:8080',
      getToken: () => ApiService().getToken(),
    );

    String imageKey;

    try {
      // 🟢 STEP 1: upload image via backend
      imageKey = await SupabaseUploadService.uploadImage(_imageBytes!);

      if (!mounted) return;

      if (!inside) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: Location outside campus premises!"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 🟢 STEP 2: prepare location
      String finalLocation = _selectedLocation ?? "";
      if (_selectedLocation == 'Hostel' && _selectedHostel != null) {
        finalLocation = "Hostel: $_selectedHostel";
      } else if (_selectedLocation == 'Others') {
        finalLocation = _zoneController.text;
      }

      // 🟢 STEP 3: prepare category
      String finalCategory = _selectedCategory ?? "";
      if (_selectedCategory == 'Others') {
        finalCategory = _customCategoryController.text;
      }

      // 🟢 STEP 4: send item data
      final itemData = {
        "category": finalCategory,
        "campus_zone": finalLocation,
        "found_at": _selectedDateTime.toUtc().toIso8601String(),
        "image_key": imageKey,
      };

      await itemApi.reportFoundItem(itemData);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const HandoverAlert(),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0F10),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Take Photo",
                  style: TextStyle(color: Colors.white)),
              onTap: () => _pickImage(ImageSource.camera)),
          ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title:
                  const Text("Gallery", style: TextStyle(color: Colors.white)),
              onTap: () => _pickImage(ImageSource.gallery)),
        ],
      ),
    );
  }
}

/* ───────────────── HOVER WRAPPER ───────────────── */

class _HoverContainer extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  const _HoverContainer({required this.child, required this.accentColor});

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      // Triggered on mobile tap/keyboard focus
      onFocusChange: (hasFocus) {
        setState(() => _isHighlighted = hasFocus);
      },
      child: MouseRegion(
        // Triggered on desktop hover
        onEnter: (_) => setState(() => _isHighlighted = true),
        onExit: (_) => setState(() => _isHighlighted = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isHighlighted ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHighlighted
                  ? widget.accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: _isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHighlighted)
                BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2)
            ],
          ),
          child: widget.child,
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
