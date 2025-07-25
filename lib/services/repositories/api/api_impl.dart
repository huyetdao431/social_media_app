import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/services/repositories/log/log.dart';

class ApiImpl implements Api {
  Log log;
  ApiImpl(this.log);
}