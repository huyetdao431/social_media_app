
import 'package:supabase_flutter/supabase_flutter.dart';

String mapAuthExceptionMessage(AuthException e, {String? provider}) {
  final code = e.code ?? '';
  final p = provider != null ? ' ($provider)' : '';

  switch (code) {
  // chung với email/password
    case 'email_not_confirmed':
      return 'Email chưa được xác nhận!';
    case 'invalid_login_credentials':
    case 'invalid_credentials':
      return 'Email hoặc mật khẩu không đúng.';
    case 'too_many_requests':
    case 'over_request_rate_limit':
      return 'Gửi quá nhiều yêu cầu. Vui lòng thử lại sau.';
    case 'access_denied':
      return 'Quyền bị từ chối bởi nhà cung cấp$p.';
    case 'null':
      return 'Bạn đã hủy quá trình đăng nhập$p.';
    case 'oauth_error':
      return 'Lỗi OAuth khi đăng nhập$p.';
    default:
      final detail = (e.message.isNotEmpty ?? false) ? e.message : code;
      return 'Lỗi đăng nhập$p: $detail';
  }
}
