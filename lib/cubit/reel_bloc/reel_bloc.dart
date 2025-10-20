import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/models/reel.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

part 'reel_event.dart';
part 'reel_state.dart';

class ReelBloc extends Bloc<ReelEvent, ReelState> {
  Api api;
  ReelBloc(this.api) : super(ReelState.init()) {
    on<CreateReelEvent>(_onCreateReel);
    on<GetFeedReelsEvent>(_onGetFeedReels);
    on<GetReelsByUserEvent>(_onGetReelsByUser);
    on<LoadDataEvent>(_onLoadData);
    on<SaveChangeEvent>(_onSaveChange);
  }

  Future<void> _onCreateReel(CreateReelEvent event, Emitter<ReelState> emit) async {
    emit(state.copyWith(loadReelStatus: LoadStatus.loading));
    try {
      await api.createReel(file: event.file, caption: event.content ?? '', isPublic: event.isPublic ?? true, thumbImage: event.thumbImage);
      emit(state.copyWith(loadReelStatus: LoadStatus.done));
    } catch(e) {
      emit(state.copyWith(loadReelStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _onGetReelsByUser(GetReelsByUserEvent event, Emitter<ReelState> emit) async {
    emit(state.copyWith(loadReelStatus: LoadStatus.loading));
    try {
      final userReels = await api.getReelsByUser(userId: event.userId);
      emit(state.copyWith(loadReelStatus: LoadStatus.done, userReels: userReels));
    } catch(e) {
      emit(state.copyWith(loadReelStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _onGetFeedReels(GetFeedReelsEvent event, Emitter<ReelState> emit) async {
    emit(state.copyWith(loadReelStatus: LoadStatus.loading));
    try {
      final currentReels = await api.getFeedReels();
      emit(state.copyWith(loadReelStatus: LoadStatus.done, currentReels: currentReels));
    } catch(e) {
      emit(state.copyWith(loadReelStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _onLoadData(LoadDataEvent event, Emitter<ReelState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = await event.asset.file;
      emit(state.copyWith(reelMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void _onSaveChange(SaveChangeEvent event, Emitter<ReelState> emit) {
    emit(state.copyWith(reelMedia: event.file));
  }
}
