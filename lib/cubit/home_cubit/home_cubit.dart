import 'package:bloc/bloc.dart';

import '../../commons/enums/load_status.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.init());
}
