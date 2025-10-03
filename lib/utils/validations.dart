String? validateEmail(String? email) {
  if (email == null || email.trim().isEmpty) {
    return 'Vui lòng nhập email';
  }

  // Regex email cơ bản, phù hợp với hầu hết trường hợp
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(email.trim())) {
    return 'Email không hợp lệ';
  }
  return null; // hợp lệ
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Vui lòng nhập mật khẩu';
  }

  if (password.length < 8) {
    return 'Mật khẩu phải có ít nhất 8 kí tự';
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Mật khẩu phải chứa ít nhất 1 chữ cái thường';
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Mật khẩu phải chứa ít nhất 1 chữ cái hoa';
  }

  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Mật khẩu phải chứa ít nhất 1 chữ số';
  }

  // ký tự đặc biệt: bạn có thể mở rộng tập ký tự nếu cần
  if (!RegExp(r'[!@#\$%\^&\*\(\)\-_\+=\[\]\{\}\\|;:\",<\.>\/\?`~]').hasMatch(password)) {
  return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
  }
  return null; // hợp lệ
}

String? isPasswordMatch(String password, String reTypePassword) {
  if(password.compareTo(reTypePassword) != 0) {
    return 'Mật khẩu không khớp!';
  }
  return null;
}