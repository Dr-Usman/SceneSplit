enum MathEvaluatorError { divisionByZero, invalidExpression }

class MathEvaluatorResult {
  const MathEvaluatorResult.success(this.value) : error = null;
  const MathEvaluatorResult.failure(this.error) : value = null;

  final double? value;
  final MathEvaluatorError? error;

  bool get isSuccess => value != null;
  bool get isDivisionByZero => error == MathEvaluatorError.divisionByZero;
}

/// Evaluates arithmetic math expressions with +, -, × (*), ÷ (/), parentheses, and decimals.
class MathEvaluator {
  const MathEvaluator._();

  /// Evaluates [rawExpression]. If [sanitizeTrailing] is true, trims trailing
  /// dangling operators and unbalanced open parentheses for live preview typing.
  static MathEvaluatorResult evaluate(
    String rawExpression, {
    bool sanitizeTrailing = false,
  }) {
    var expr = rawExpression.trim();
    if (expr.isEmpty) {
      return const MathEvaluatorResult.success(0);
    }

    if (sanitizeTrailing) {
      expr = sanitizeForLivePreview(expr);
      if (expr.isEmpty) {
        return const MathEvaluatorResult.success(0);
      }
    }

    try {
      final tokens = _tokenize(expr);
      if (tokens.isEmpty) {
        return const MathEvaluatorResult.success(0);
      }
      final parser = _Parser(tokens);
      final result = parser.parseExpression();
      if (!parser.isAtEnd) {
        return const MathEvaluatorResult.failure(
          MathEvaluatorError.invalidExpression,
        );
      }
      if (result.isInfinite || result.isNaN) {
        return const MathEvaluatorResult.failure(
          MathEvaluatorError.divisionByZero,
        );
      }
      return MathEvaluatorResult.success(result);
    } on _MathEvaluationException catch (e) {
      return MathEvaluatorResult.failure(e.error);
    } on Object {
      return const MathEvaluatorResult.failure(
        MathEvaluatorError.invalidExpression,
      );
    }
  }

  /// Trims dangling operators and unclosed opening parentheses for live calculation.
  static String sanitizeForLivePreview(String input) {
    var s = input.trim();
    if (s.isEmpty) return '';

    // Replace operator symbols with standard ascii
    s = s.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');

    // Repeatedly strip trailing operators or whitespace
    while (s.isNotEmpty &&
        (s.endsWith('+') ||
            s.endsWith('-') ||
            s.endsWith('*') ||
            s.endsWith('/') ||
            s.endsWith('.'))) {
      s = s.substring(0, s.length - 1).trim();
    }

    // Balance unclosed open parentheses
    int openCount = 0;
    int closeCount = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '(') openCount++;
      if (s[i] == ')') closeCount++;
    }

    // Strip unclosed '(' if at the end or close them
    if (openCount > closeCount) {
      // Append missing closing parens
      s = s + (')' * (openCount - closeCount));
    }

    return s;
  }

  /// Formats the evaluated double to a clean string suitable for text input.
  static String formatAmount(double value, {bool showDecimals = true}) {
    if (!showDecimals) {
      return value.round().toString();
    }

    // Check if integer
    if (value.truncateToDouble() == value) {
      return value.toInt().toString();
    }

    // Round to 2 decimal places and strip unnecessary trailing zeroes
    final fixed = value.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    if (fixed.endsWith('0') && fixed.contains('.')) {
      return fixed.substring(0, fixed.length - 1);
    }
    return fixed;
  }

  static List<_Token> _tokenize(String text) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < text.length) {
      final char = text[i];

      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        i++;
        continue;
      }

      if (char == '+' ||
          char == '-' ||
          char == '−' ||
          char == '*' ||
          char == '×' ||
          char == '/' ||
          char == '÷' ||
          char == '(' ||
          char == ')') {
        tokens.add(_Token(_normalizeOperator(char), _TokenType.operator));
        i++;
        continue;
      }

      if (_isDigit(char) || char == '.') {
        final start = i;
        bool hasDot = char == '.';
        i++;
        while (i < text.length) {
          final c = text[i];
          if (_isDigit(c)) {
            i++;
          } else if (c == '.' && !hasDot) {
            hasDot = true;
            i++;
          } else {
            break;
          }
        }
        final numStr = text.substring(start, i);
        tokens.add(_Token(numStr, _TokenType.number));
        continue;
      }

      throw const _MathEvaluationException(
        MathEvaluatorError.invalidExpression,
      );
    }

    return tokens;
  }

  static String _normalizeOperator(String op) {
    return switch (op) {
      '×' => '*',
      '÷' => '/',
      '−' => '-',
      _ => op,
    };
  }

  static bool _isDigit(String s) {
    return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  }
}

enum _TokenType { number, operator }

class _Token {
  const _Token(this.value, this.type);
  final String value;
  final _TokenType type;
}

class _Parser {
  _Parser(this.tokens);
  final List<_Token> tokens;
  int _current = 0;

  bool get isAtEnd => _current >= tokens.length;

  _Token get _peek => tokens[_current];

  _Token _advance() => tokens[_current++];

  bool _match(String op) {
    if (isAtEnd) return false;
    if (_peek.type == _TokenType.operator && _peek.value == op) {
      _advance();
      return true;
    }
    return false;
  }

  double parseExpression() {
    double value = _parseTerm();

    while (!isAtEnd) {
      if (_match('+')) {
        value += _parseTerm();
      } else if (_match('-')) {
        value -= _parseTerm();
      } else {
        break;
      }
    }

    return value;
  }

  double _parseTerm() {
    double value = _parseFactor();

    while (!isAtEnd) {
      if (_match('*')) {
        value *= _parseFactor();
      } else if (_match('/')) {
        final divisor = _parseFactor();
        if (divisor == 0) {
          throw const _MathEvaluationException(
            MathEvaluatorError.divisionByZero,
          );
        }
        value /= divisor;
      } else {
        break;
      }
    }

    return value;
  }

  double _parseFactor() {
    if (isAtEnd) {
      throw const _MathEvaluationException(
        MathEvaluatorError.invalidExpression,
      );
    }

    // Unary plus or minus
    if (_match('+')) {
      return _parseFactor();
    }
    if (_match('-')) {
      return -_parseFactor();
    }

    if (_match('(')) {
      final value = parseExpression();
      if (!_match(')')) {
        throw const _MathEvaluationException(
          MathEvaluatorError.invalidExpression,
        );
      }
      return value;
    }

    final token = _advance();
    if (token.type == _TokenType.number) {
      final numValue = double.tryParse(token.value);
      if (numValue != null) {
        return numValue;
      }
    }

    throw const _MathEvaluationException(MathEvaluatorError.invalidExpression);
  }
}

class _MathEvaluationException implements Exception {
  const _MathEvaluationException(this.error);
  final MathEvaluatorError error;
}
