/// Validator for authentication forms (Login/Register)
/// Based on Cocos Creator implementation specs
class AuthValidator {
  AuthValidator._();

  /// Vietnamese accent characters pattern
  static final _accentPattern = RegExp(
    r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]',
  );

  /// Special characters pattern
  static final _specialCharPattern = RegExp(
    r'[!@#$%^&*()\-,.?":{}|<>~`\[\]\\;+=_/]',
  );

  /// All digits pattern
  static final _allDigitsPattern = RegExp(r'^[0-9]+$');

  /// Check if string contains Vietnamese accents
  static bool hasVietnameseAccent(String text) {
    return _accentPattern.hasMatch(text);
  }

  /// Check if string does NOT have Vietnamese accents
  static bool isNonAccent(String text) {
    return !hasVietnameseAccent(text);
  }

  /// Check if string contains special characters
  static bool hasSpecialCharacter(String text) {
    return _specialCharPattern.hasMatch(text);
  }

  /// Check if string contains only digits
  static bool isAllDigits(String text) {
    return _allDigitsPattern.hasMatch(text);
  }

  /// Validate username for Register
  /// Rules:
  /// - Required (not empty)
  /// - 6-29 characters
  /// - No spaces
  /// - No Vietnamese accents
  /// - No special characters
  /// - Cannot be all digits
  /// - Will be converted to lowercase
  static String? validateRegisterUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.length < 6 || value.length > 29) {
      return 'Tên đăng nhập phải từ 6 đến 29 ký tự';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    return null;
  }

  /// Validate username for Register (realtime - while typing)
  /// Returns error only if user has started typing and there's an issue
  /// Does not return "required" error for empty field
  static String? validateRegisterUsernameRealtime(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Don't show error while field is empty
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    if (value.length < 6 || value.length > 29) {
      return 'Tên đăng nhập phải từ 6 đến 29 ký tự';
    }
    return null;
  }

  /// Validate username for Login
  /// Rules:
  /// - Required (not empty)
  /// - No spaces
  /// - No Vietnamese accents
  static String? validateLoginUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    return null;
  }

  /// Validate password
  /// Rules:
  /// - Required (not empty)
  /// - 6-30 characters
  /// - No spaces
  /// - No Vietnamese accents
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (value.length < 6 || value.length > 30) {
      return 'Mật khẩu phải từ 6 tới 30 ký tự';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    return null;
  }

  /// Validate password (realtime - while typing)
  static String? validatePasswordRealtime(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Don't show error while field is empty
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (value.length < 6 || value.length > 30) {
      return 'Mật khẩu phải từ 6 tới 30 ký tự';
    }
    return null;
  }

  /// Validate confirm password
  /// Rules:
  /// - Must match password
  /// - No spaces
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  /// Validate confirm password (realtime - while typing)
  static String? validateConfirmPasswordRealtime(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return null; // Don't show error while field is empty
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (password.isNotEmpty && value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  /// Validate display name for Register
  /// Rules:
  /// - Required (not empty)
  /// - 6-29 characters
  /// - No spaces
  /// - Cannot be same as username (case-insensitive)
  /// - No Vietnamese accents
  /// - No special characters
  /// - Cannot be all digits
  static String? validateDisplayName(String? value, String username) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên hiển thị';
    }
    if (value.length < 6 || value.length > 29) {
      return 'Tên hiển thị phải từ 6 đến 29 ký tự';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (value.toLowerCase() == username.toLowerCase()) {
      return 'Tên hiển thị không được trùng tên đăng nhập';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    return null;
  }

  /// Validate display name (realtime - while typing)
  static String? validateDisplayNameRealtime(String? value, String username) {
    if (value == null || value.isEmpty) {
      return null; // Don't show error while field is empty
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    if (username.isNotEmpty && value.toLowerCase() == username.toLowerCase()) {
      return 'Tên hiển thị không được trùng tên đăng nhập';
    }
    if (value.length < 6 || value.length > 29) {
      return 'Tên hiển thị phải từ 6 đến 29 ký tự';
    }
    return null;
  }

  /// Validate OTP code
  /// Rules:
  /// - Required (not empty)
  /// - Usually 6 digits
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 ký tự';
    }
    return null;
  }
}
