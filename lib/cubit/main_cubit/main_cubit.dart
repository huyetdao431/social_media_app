import 'package:bloc/bloc.dart';
import 'package:social_media_app/models/profile/profiles.dart';
import 'package:social_media_app/services/repositories/hive/profile_repository.dart';

import '../../commons/enums/load_status.dart';
import '../../services/repositories/api/api.dart';
import '../../services/repositories/shared_preference_repository.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  Api api;
  MainCubit(this.api) : super(MainState.init());

  Future<void> getTheme() async{
    final isLightTheme = await SharedPreferenceRepository.getTheme();
    emit(state.copyWith(isLightTheme: isLightTheme));
  }
  Future<void> switchTheme() async{
    emit(state.copyWith(isLightTheme: !state.isLightTheme));
    await SharedPreferenceRepository.setTheme(state.isLightTheme);
  }

  Future<void> logout() async{
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      await api.logout();
      await SharedPreferenceRepository.logout();
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch(e) {
      throw Exception(e);
    }
  }

  void setUserProfile() {
    final repo = ProfileRepository();
    final userProfile = repo.getProfile('profile');
    emit(state.copyWith(profile: userProfile));
  }

  void switchSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
