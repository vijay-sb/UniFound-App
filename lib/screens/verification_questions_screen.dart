import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/item_api_service.dart';
import '../widgets/particle_background.dart';

class VerificationQuestionsScreen extends StatefulWidget {
  final String itemId;
  final ItemApiService apiService;

  const VerificationQuestionsScreen({
    super.key,
    required this.itemId,
    required this.apiService,
  });

  @override
  State<VerificationQuestionsScreen> createState() =>
      _VerificationQuestionsScreenState();
}

class _VerificationQuestionsScreenState
    extends State<VerificationQuestionsScreen> {
  static const Color _accent = Color(0xFF9CFF00);

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  String? _claimId;
  List<_ClaimQuestion> _questions = [];

  // Tracks the selected option index per question index
  final Map<int, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _initClaim();
  }

  /// Creates a claim and loads questions with IDs from the backend.
  /// If claim was already submitted, shows the previous result.
  Future<void> _initClaim() async {
    try {
      final result = await widget.apiService.claimItem(widget.itemId);

      final claimId = result['claim_id'] as String;
      final rawQuestions = result['questions'] as List;

      final questions = rawQuestions.map((q) {
        return _ClaimQuestion(
          id: q['id'] as String,
          model: QuestionModel(
            question: q['question'] as String,
            options: List<String>.from(q['options']),
          ),
        );
      }).toList();

      setState(() {
        _claimId = claimId;
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      // Check if this is an "already submitted" error
      if (errorMsg.contains('already submitted')) {
        setState(() => _isLoading = false);
        // Show a message that this item has already been claimed
        if (mounted) {
          _showAlreadyClaimedDialog();
        }
      } else {
        setState(() {
          _error = errorMsg;
          _isLoading = false;
        });
      }
    }
  }

  void _showAlreadyClaimedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Colors.orangeAccent, width: 2),
          ),
          title: const Column(
            children: [
              Icon(Icons.info_outline, color: Colors.orangeAccent, size: 56),
              SizedBox(height: 12),
              Text(
                'ALREADY CLAIMED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: const Text(
            'You have already submitted a claim for this item. Each user gets only one attempt per item.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'GO BACK',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _allAnswered => _selectedAnswers.length == _questions.length;

  Future<void> _submit() async {
    if (!_allAnswered || _claimId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final answers = _selectedAnswers.entries.map((entry) {
        final question = _questions[entry.key];
        // The backend expects answer as the option letter: A, B, C, D
        final optionLetter = String.fromCharCode(65 + entry.value); // 0→A, 1→B
        return {
          'question_id': question.id,
          'answer': optionLetter,
        };
      }).toList();

      final result =
          await widget.apiService.submitClaimAnswers(_claimId!, answers);

      if (!mounted) return;

      _showResultDialog(
        status: result['status'] as String,
        message: result['message'] as String,
        confidence: result['confidence_score'] as int,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showResultDialog({
    required String status,
    required String message,
    required int confidence,
  }) {
    IconData icon;
    Color iconColor;
    String title;

    switch (status) {
      case 'APPROVED':
        icon = Icons.check_circle_outline;
        iconColor = _accent;
        title = 'CLAIM APPROVED';
        break;
      case 'MANUAL_REVIEW':
        icon = Icons.hourglass_top_rounded;
        iconColor = Colors.orangeAccent;
        title = 'UNDER REVIEW';
        break;
      default:
        icon = Icons.cancel_outlined;
        iconColor = Colors.redAccent;
        title = 'CLAIM REJECTED';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: iconColor, width: 2),
          ),
          title: Column(
            children: [
              Icon(icon, color: iconColor, size: 56),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Confidence: $confidence%',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Back to BlindFeedScreen
                },
                child: Text(
                  'DONE',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildBody()),
                    if (!_isLoading && _error == null) _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ─────────── HEADER ─────────── */

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'VERIFY OWNERSHIP',
              style: TextStyle(
                color: _accent,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ─────────── BODY ─────────── */

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('GO BACK',
                    style:
                        TextStyle(color: _accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: _questions.length,
      itemBuilder: (context, index) => _QuestionCard(
        index: index,
        question: _questions[index].model,
        selectedOption: _selectedAnswers[index],
        onOptionSelected: (optionIndex) {
          setState(() => _selectedAnswers[index] = optionIndex);
        },
      ),
    );
  }

  /* ─────────── SUBMIT BUTTON ─────────── */

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (_allAnswered)
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _allAnswered && !_isSubmitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _allAnswered ? _accent : Colors.white10,
                disabledBackgroundColor: Colors.white10,
                foregroundColor: Colors.black,
                disabledForegroundColor: Colors.white24,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _allAnswered
                          ? 'SUBMIT ANSWERS'
                          : 'ANSWER ALL QUESTIONS (${_selectedAnswers.length}/${_questions.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────── DATA CLASS ───────────── */

class _ClaimQuestion {
  final String id;
  final QuestionModel model;

  _ClaimQuestion({required this.id, required this.model});
}

/* ───────────── GLASSMORPHIC QUESTION CARD ───────────── */

class _QuestionCard extends StatelessWidget {
  final int index;
  final QuestionModel question;
  final int? selectedOption;
  final ValueChanged<int> onOptionSelected;

  static const Color _accent = Color(0xFF9CFF00);

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                color: _accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Question text
                Text(
                  question.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                // Options
                ...List.generate(question.options.length, (optIdx) {
                  final isSelected = selectedOption == optIdx;
                  final letter = String.fromCharCode(65 + optIdx);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionButton(
                      letter: letter,
                      text: question.options[optIdx],
                      isSelected: isSelected,
                      onTap: () => onOptionSelected(optIdx),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────── GLASS OPTION BUTTON ───────────── */

class _OptionButton extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _isHovered = false;
  static const Color _accent = Color(0xFF9CFF00);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _accent.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? _accent
                  : _accent.withValues(alpha: _isHovered ? 0.4 : 0.15),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: _accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? _accent
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.letter,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.black : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Option text
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              // Selection indicator
              if (widget.isSelected)
                const Icon(Icons.check_circle, color: _accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
