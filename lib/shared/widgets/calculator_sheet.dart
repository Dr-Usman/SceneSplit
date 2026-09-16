import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/currencies.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/math_evaluator.dart';

/// Opens the calculator bottom sheet and returns the calculated amount as a string.
Future<String?> showCalculatorSheet(
  BuildContext context, {
  required String currencyCode,
  String? initialValue,
  bool showDecimals = true,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) => _CalculatorSheet(
      currencyCode: currencyCode,
      initialValue: initialValue,
      showDecimals: showDecimals,
    ),
  );
}

class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet({
    required this.currencyCode,
    this.initialValue,
    required this.showDecimals,
  });

  final String currencyCode;
  final String? initialValue;
  final bool showDecimals;

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  late String _expression;
  double? _liveResult;
  bool _isDivZero = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue?.trim();
    if (init != null && init.isNotEmpty && double.tryParse(init) != null) {
      _expression = init;
    } else {
      _expression = '';
    }
    _recalculate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _recalculate() {
    if (_expression.trim().isEmpty) {
      _liveResult = 0;
      _isDivZero = false;
      return;
    }

    final res = MathEvaluator.evaluate(_expression, sanitizeTrailing: true);
    if (res.isSuccess) {
      _liveResult = res.value;
      _isDivZero = false;
    } else {
      _isDivZero = res.isDivisionByZero;
      if (_isDivZero) {
        _liveResult = null;
      }
    }
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _liveResult = 0;
          _isDivZero = false;
        case '⌫':
          if (_expression.isNotEmpty) {
            if (_expression.endsWith(' ')) {
              _expression = _expression.trimRight();
            }
            if (_expression.isNotEmpty) {
              _expression = _expression.substring(0, _expression.length - 1);
              if (_expression.endsWith(' ')) {
                _expression = _expression.trimRight();
              }
            }
          }
          _recalculate();
        case '=':
          final res = MathEvaluator.evaluate(_expression);
          if (res.isSuccess && res.value != null) {
            _expression = MathEvaluator.formatAmount(
              res.value!,
              showDecimals: widget.showDecimals,
            );
            _liveResult = res.value;
            _isDivZero = false;
          } else if (res.isDivisionByZero) {
            _isDivZero = true;
            _liveResult = null;
          }
        case '+':
        case '−':
        case '×':
        case '÷':
          final trimmed = _expression.trimRight();
          if (trimmed.isEmpty) {
            if (key == '−') {
              _expression = '−';
            }
          } else if (trimmed.endsWith('+') ||
              trimmed.endsWith('−') ||
              trimmed.endsWith('×') ||
              trimmed.endsWith('÷')) {
            // Replace previous operator
            _expression = '${trimmed.substring(0, trimmed.length - 1)}$key ';
          } else {
            _expression = '$trimmed $key ';
          }
          _recalculate();
        case '.':
          final lastNumberSegment = _expression
              .split(RegExp(r'[ +−×÷()]'))
              .last;
          if (!lastNumberSegment.contains('.')) {
            if (lastNumberSegment.isEmpty) {
              _expression += '0.';
            } else {
              _expression += '.';
            }
          }
          _recalculate();
        case '(':
        case ')':
          _expression += key;
          _recalculate();
        default: // Digit 0-9
          _expression += key;
          _recalculate();
      }
    });
    _scrollToEnd();
  }

  void _applyResult() {
    if (_isDivZero) return;

    final targetVal = _liveResult ?? 0.0;
    final formatted = MathEvaluator.formatAmount(
      targetVal,
      showDecimals: widget.showDecimals,
    );
    Navigator.pop(context, formatted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final symbol = currencyByCode(widget.currencyCode).symbol.trim();

    final formattedPreview = _liveResult != null
        ? MathEvaluator.formatAmount(
            _liveResult!,
            showDecimals: widget.showDecimals,
          )
        : '0';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header: Title & Close
            Row(
              children: [
                Text(
                  l10n.expensesCalculator,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Display Screen Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expression Line
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Result Line
                  if (_isDivZero)
                    Text(
                      l10n.expensesCalculatorDivZero,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.negative,
                      ),
                    )
                  else
                    Text(
                      '= $symbol $formattedPreview',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Keypad Grid (5 rows x 4 cols)
            _buildKeypad(context, isDark),
            const SizedBox(height: 16),

            // Apply Button
            FilledButton(
              onPressed: _isDivZero ? null : _applyResult,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                l10n.expensesCalculatorApply('$symbol $formattedPreview'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, bool isDark) {
    const keys = [
      ['C', '(', ')', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '⌫', '='],
    ];

    return Column(
      children: [
        for (var r = 0; r < keys.length; r++) ...[
          Row(
            children: [
              for (var c = 0; c < keys[r].length; c++) ...[
                Expanded(
                  child: _CalculatorKey(
                    label: keys[r][c],
                    onTap: () => _onKeyPress(keys[r][c]),
                    isOperator: ['÷', '×', '−', '+', '='].contains(keys[r][c]),
                    isAction: ['C', '⌫', '(', ')'].contains(keys[r][c]),
                    isDark: isDark,
                  ),
                ),
                if (c < keys[r].length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          if (r < keys.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({
    required this.label,
    required this.onTap,
    required this.isOperator,
    required this.isAction,
    required this.isDark,
  });

  final String label;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isAction;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;

    if (isOperator) {
      bgColor = theme.colorScheme.primary.withValues(
        alpha: isDark ? 0.25 : 0.12,
      );
      textColor = theme.colorScheme.primary;
    } else if (isAction) {
      bgColor = isDark ? const Color(0xFF21262D) : const Color(0xFFF0EFEA);
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    } else {
      bgColor = isDark ? AppColors.surfaceDark : Colors.white;
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isOperator || isAction
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
