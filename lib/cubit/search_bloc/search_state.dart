part of 'search_bloc.dart';

class SearchState {
  final LoadStatus loadStatus;
  final LoadStatus loadProfileStatus;
  final LoadStatus loadPostStatus;
  final LoadStatus loadReelStatus;
  final bool isSearchPage;
  final Map<String, dynamic> searchProfileInfo;
  final Map<String, dynamic> searchPostInfo;
  final Map<String, dynamic> searchReelInfo;
  final String errorMessage;

  const SearchState.init({
    this.loadStatus = LoadStatus.init,
    this.loadProfileStatus = LoadStatus.init,
    this.loadPostStatus = LoadStatus.init,
    this.loadReelStatus = LoadStatus.init,
    this.isSearchPage = false,
    this.searchProfileInfo = const {},
    this.searchPostInfo = const {},
    this.searchReelInfo = const {},
    this.errorMessage = '',
  });

  //<editor-fold desc="Data Methods">
  const SearchState({
    required this.loadStatus,
    required this.loadProfileStatus,
    required this.loadPostStatus,
    required this.loadReelStatus,
    required this.isSearchPage,
    required this.searchProfileInfo,
    required this.searchPostInfo,
    required this.searchReelInfo,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          loadProfileStatus == other.loadProfileStatus &&
          loadPostStatus == other.loadPostStatus &&
          loadReelStatus == other.loadReelStatus &&
          isSearchPage == other.isSearchPage &&
          searchProfileInfo == other.searchProfileInfo &&
          searchPostInfo == other.searchPostInfo &&
          searchReelInfo == other.searchReelInfo &&
          errorMessage == other.errorMessage);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      loadProfileStatus.hashCode ^
      loadPostStatus.hashCode ^
      loadReelStatus.hashCode ^
      isSearchPage.hashCode ^
      searchProfileInfo.hashCode ^
      searchPostInfo.hashCode ^
      searchReelInfo.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'SearchState{' +
        ' loadStatus: $loadStatus,' +
        ' loadProfileStatus: $loadProfileStatus,' +
        ' loadPostStatus: $loadPostStatus,' +
        ' loadReelStatus: $loadReelStatus,' +
        ' isSearchPage: $isSearchPage,' +
        ' searchProfileInfo: $searchProfileInfo,' +
        ' searchPostInfo: $searchPostInfo,' +
        ' searchReelInfo: $searchReelInfo,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }

  SearchState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadProfileStatus,
    LoadStatus? loadPostStatus,
    LoadStatus? loadReelStatus,
    bool? isSearchPage,
    Map<String, dynamic>? searchProfileInfo,
    Map<String, dynamic>? searchPostInfo,
    Map<String, dynamic>? searchReelInfo,
    String? errorMessage,
  }) {
    return SearchState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadProfileStatus: loadProfileStatus ?? this.loadProfileStatus,
      loadPostStatus: loadPostStatus ?? this.loadPostStatus,
      loadReelStatus: loadReelStatus ?? this.loadReelStatus,
      isSearchPage: isSearchPage ?? this.isSearchPage,
      searchProfileInfo: searchProfileInfo ?? this.searchProfileInfo,
      searchPostInfo: searchPostInfo ?? this.searchPostInfo,
      searchReelInfo: searchReelInfo ?? this.searchReelInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'loadProfileStatus': this.loadProfileStatus,
      'loadPostStatus': this.loadPostStatus,
      'loadReelStatus': this.loadReelStatus,
      'isSearchPage': this.isSearchPage,
      'searchProfileInfo': this.searchProfileInfo,
      'searchPostInfo': this.searchPostInfo,
      'searchReelInfo': this.searchReelInfo,
      'errorMessage': this.errorMessage,
    };
  }

  factory SearchState.fromMap(Map<String, dynamic> map) {
    return SearchState(
      loadStatus: map['loadStatus'] as LoadStatus,
      loadProfileStatus: map['loadProfileStatus'] as LoadStatus,
      loadPostStatus: map['loadPostStatus'] as LoadStatus,
      loadReelStatus: map['loadReelStatus'] as LoadStatus,
      isSearchPage: map['isSearchPage'] as bool,
      searchProfileInfo: map['searchProfileInfo'] as Map<String, dynamic>,
      searchPostInfo: map['searchPostInfo'] as Map<String, dynamic>,
      searchReelInfo: map['searchReelInfo'] as Map<String, dynamic>,
      errorMessage: map['errorMessage'] as String,
    );
  }

  //</editor-fold>
}
