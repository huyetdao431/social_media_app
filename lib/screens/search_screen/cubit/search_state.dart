part of 'search_cubit.dart';

class SearchState {
  final bool isSearchPage;

  const SearchState.init({
    this.isSearchPage = false,
  });

  //<editor-fold desc="Data Methods">
  const SearchState({
    required this.isSearchPage,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is SearchState &&
              runtimeType == other.runtimeType &&
              isSearchPage == other.isSearchPage
          );


  @override
  int get hashCode =>
      isSearchPage.hashCode;


  @override
  String toString() {
    return 'SearchState{' ' isSearchPage: $isSearchPage,' '}';
  }


  SearchState copyWith({
    bool? isSearchPage,
  }) {
    return SearchState(
      isSearchPage: isSearchPage ?? this.isSearchPage,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'isSearchPage': isSearchPage,
    };
  }

  factory SearchState.fromMap(Map<String, dynamic> map) {
    return SearchState(
      isSearchPage: map['isSearchPage'] as bool,
    );
  }


//</editor-fold>
}
