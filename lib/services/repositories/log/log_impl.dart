import 'package:social_media_app/services/repositories/log/log.dart';

class LogImpl implements Log {
  @override
  void d(String tag, String message) {
    print('[$tag]: $message');
  }

  @override
  void e(String tag, String message) {
    print('[$tag]: $message');
  }

  @override
  void i(String tag, String message) {
    print('[$tag]: $message');
  }

}