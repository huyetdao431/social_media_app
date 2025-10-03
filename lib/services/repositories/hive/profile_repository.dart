import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/profile/profiles.dart';

class ProfileRepository {
  static const String boxName = 'profiles';

  Box<Profile> get _box => Hive.box<Profile>(boxName);

  Future<void> saveProfile(Profile profile) async {
    await _box.put('profile', profile);
  }

  Profile? getProfile(String id) {
    return _box.get(id);
  }

  List<Profile> getAllProfiles() => _box.values.toList();

  Future<void> deleteProfile(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async => await _box.clear();

  ValueListenable<Box<Profile>> listenable() => _box.listenable();

  ValueListenable<Box<Profile>> listenableForKey(String key) => _box.listenable(keys: [key]);
}
