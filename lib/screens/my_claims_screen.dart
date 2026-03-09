import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/item_api_service.dart';
import '../models/claim_dto.dart';

class MyClaimsScreen extends StatefulWidget {
  final ItemApiService apiService;
  final VoidCallback? onBack;

  const MyClaimsScreen({
    super.key,
    required this.apiService,
    this.onBack,
  });

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  List<ClaimDto> _claims = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final claims = await widget.apiService.fetchMyClaims();
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF4ADE80);
      case 'PENDING':
        return const Color(0xFFFBBF24);
      case 'MANUAL_REVIEW':
        return const Color(0xFFFB923C);
      case 'REJECTED':
        return const Color(0xFFF87171);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'PENDING':
        return Icons.hourglass_empty_rounded;
      case 'MANUAL_REVIEW':
        return Icons.visibility_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'MANUAL_REVIEW':
        return 'Under Review';
      default:
        return status[0] + status.substring(1).toLowerCase();
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Show the QR code below at the Lost & Found office to collect your item.';
      case 'PENDING':
        return 'Your answers are being evaluated. Please wait.';
      case 'MANUAL_REVIEW':
        return 'An admin is reviewing your claim. You will be notified.';
      case 'REJECTED':
        return 'Your answers did not match. Visit the Lost & Found office if you believe this is an error.';
      default:
        return '';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF9CFF00);
    const bg = Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text(
          'My Claims',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadClaims,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accent),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.red.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load claims',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadClaims,
                        child: const Text('Retry',
                            style: TextStyle(color: accent)),
                      ),
                    ],
                  ),
                )
              : _claims.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48, color: Colors.grey.shade700),
                          const SizedBox(height: 12),
                          Text(
                            'No claims yet',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "I LOST THIS" on an item to start a claim',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: accent,
                      backgroundColor: const Color(0xFF1A1A1A),
                      onRefresh: _loadClaims,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _claims.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildClaimCard(_claims[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildClaimCard(ClaimDto claim) {
    final statusColor = _statusColor(claim.status);
    final isApproved = claim.status == 'APPROVED';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? statusColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Top section - Claim info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge + time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(claim.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _statusLabel(claim.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(claim.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category + Zone
                Row(
                  children: [
                    Icon(Icons.category_rounded,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      claim.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_rounded,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      claim.campusZone,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Confidence score
                if (claim.confidenceScore != null) ...[
                  Row(
                    children: [
                      Text(
                        'Confidence: ',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${claim.confidenceScore}%',
                        style: TextStyle(
                          color: _statusColor(claim.status),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Confidence bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (claim.confidenceScore ?? 0) / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 3,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Status message
                Text(
                  _statusMessage(claim.status),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // QR Code section for approved claims with pickup token
          if (isApproved && claim.pickupTokenId != null) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.05),
                border: Border(
                  top: BorderSide(
                    color: statusColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (claim.shortCode != null) ...[
                    Text(
                      claim.shortCode!,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SHORT COLLECTION CODE',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Pickup QR Code',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: claim.pickupTokenId!,
                      version: QrVersions.auto,
                      size: 160,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Show this at the Lost & Found office',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Copy token button (OTP fallback)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: claim.pickupTokenId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pickup token copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            'Copy Token ID',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
