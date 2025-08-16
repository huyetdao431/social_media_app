import 'package:bloc/bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.init());

  void togglePage() {
    emit(state.copyWith(isSearchPage: !state.isSearchPage));
  }
}
