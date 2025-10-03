part of 'reel_cubit.dart';

class ReelState {
  final LoadStatus loadStatus;
  final File? reelMedia;
  final String mediaType;

  const ReelState.init({
    this.loadStatus = LoadStatus.init,
    this.reelMedia,
    this.mediaType = '',
  });

//<editor-fold desc="Data Methods">


  const ReelState({
    required this.loadStatus,
    this.reelMedia,
    required this.mediaType,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ReelState &&
              runtimeType == other.runtimeType &&
              loadStatus == other.loadStatus &&
              reelMedia == other.reelMedia &&
              mediaType == other.mediaType
          );


  @override
  int get hashCode =>
      loadStatus.hashCode ^
      reelMedia.hashCode ^
      mediaType.hashCode;


  @override
  String toString() {
    return 'ReelState{' +
        ' loadStatus: $loadStatus,' +
        ' reelMedia: $reelMedia,' +
        ' mediaType: $mediaType,' +
        '}';
  }


  ReelState copyWith({
    LoadStatus? loadStatus,
    File? reelMedia,
    String? mediaType,
  }) {
    return ReelState(
      loadStatus: loadStatus ?? this.loadStatus,
      reelMedia: reelMedia ?? this.reelMedia,
      mediaType: mediaType ?? this.mediaType,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'reelMedia': this.reelMedia,
      'mediaType': this.mediaType,
    };
  }

  factory ReelState.fromMap(Map<String, dynamic> map) {
    return ReelState(
      loadStatus: map['loadStatus'] as LoadStatus,
      reelMedia: map['reelMedia'] as File,
      mediaType: map['mediaType'] as String,
    );
  }


//</editor-fold>
}
