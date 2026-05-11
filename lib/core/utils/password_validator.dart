/// Password strength levels
enum PasswordStrength { weak, fair, good, strong }

/// Validates password strength and provides feedback
class PasswordValidator {
  static const int _minLength = 8;

  /// Check if password meets all requirements
  static bool isValid(String password) {
    return password.length >= _minLength &&
        _hasUppercase(password) &&
        _hasLowercase(password) &&
        _hasNumber(password) &&
        _hasSpecialChar(password);
  }

  /// Get password strength level
  static PasswordStrength getStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check (0-2 points)
    if (password.length >= _minLength) score++;
    if (password.length >= 12) score++;

    // Character variety (0-3 points)
    if (_hasLowercase(password)) score++;
    if (_hasUppercase(password)) score++;
    if (_hasNumber(password)) score++;
    if (_hasSpecialChar(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  /// Get strength percentage (0-100)
  static int getStrengthPercent(String password) {
    if (password.isEmpty) return 0;

    int score = 0;
    int maxScore = 6;

    if (password.length >= _minLength) score++;
    if (password.length >= 12) score++;
    if (_hasLowercase(password)) score++;
    if (_hasUppercase(password)) score++;
    if (_hasNumber(password)) score++;
    if (_hasSpecialChar(password)) score++;

    return ((score / maxScore) * 100).toInt();
  }

  /// Get validation error message
  static String? getValidationError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < _minLength) return 'At least 8 characters required';
    if (!_hasLowercase(password)) return 'Add lowercase letters';
    if (!_hasUppercase(password)) return 'Add uppercase letters';
    if (!_hasNumber(password)) return 'Add numbers';
    if (!_hasSpecialChar(password)) return 'Add special characters (!@#\$%^&*)';
    return null;
  }

  static bool _hasLowercase(String s) => s.contains(RegExp(r'[a-z]'));
  static bool _hasUppercase(String s) => s.contains(RegExp(r'[A-Z]'));
  static bool _hasNumber(String s) => s.contains(RegExp(r'\d'));
  static bool _hasSpecialChar(String s) =>
      s.contains(RegExp('[!@#\$%^&*()_+\\-=\\[\\]{};:\'",.<>?/\\\\|`~]'));
}
