import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState.init());
  void switchTheme() {
    emit(state.copyWith(isLightTheme: !state.isLightTheme));
  }
}
