import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/widgets/video_trimmer_screen.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/cubit/reel_bloc/reel_bloc.dart';
import 'package:social_media_app/cubit/story_bloc/story_bloc.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
import 'package:social_media_app/commons/widgets/camera_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_image_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_video_screen.dart';
import 'package:social_media_app/screens/add_post_screen/preview_post_screen.dart';
import 'package:social_media_app/screens/add_reel_screen/add_reel_screen.dart';
import 'package:social_media_app/screens/add_reel_screen/edit_reel_screen.dart';
import 'package:social_media_app/screens/add_reel_screen/preview_reel_screen.dart';
import 'package:social_media_app/screens/add_story_screen/add_story_screen.dart';
import 'package:social_media_app/screens/add_story_screen/edit_story_screen.dart';
import 'package:social_media_app/screens/create_media_screen/create_media_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/auth_screen/login_screen.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';
import 'package:social_media_app/screens/reels_screen/reels_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';
import 'package:social_media_app/screens/splash_screen/splash_screen.dart';
import 'package:social_media_app/screens/story_screen/story_screen.dart';
import 'package:social_media_app/utils/screen_trasition/slide_in_from_bottom.dart';
import 'package:social_media_app/utils/screen_trasition/slide_in_from_left.dart';

import 'models/story.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.route:
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case AccountScreen.route:
      return MaterialPageRoute(builder: (context) => AccountScreen());
    // case EditProfileScreen.route:
    //   var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
    //   return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditProfileScreen()));
    // case AccountSettingScreen.route:
    //   return slideInFromRight(AccountSettingScreen());
    case MainScreen.route:
      return MaterialPageRoute(builder: (context) => MainScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case SearchScreen.route:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case CreateMediaScreen.route:
      return slideInFromBottom(CreateMediaScreen());
    // return MaterialPageRoute(builder: (context) => CreateMediaScreen());
    case AddPostScreen.route:
      return slideInFromLeft(AddPostScreen());
    case AddStoryScreen.route:
      return slideInFromLeft(AddStoryScreen());
    // return MaterialPageRoute(builder: (context) => AddStoryScreen());
    case AddReelScreen.route:
      return slideInFromLeft(AddReelScreen());
    // return MaterialPageRoute(builder: (context) => AddReelScreen());
    case CameraScreen.route:
      return slideInFromLeft(CameraScreen());
    case VideoTrimScreen.route:
      var file = (settings.arguments as Map<String, dynamic>)['file'] as File;
      return slideInFromLeft(VideoTrimScreen(file: file));
    case EditImageScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditImageScreen()));
    case EditVideoScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditVideoScreen()));
    case EditMediaScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditMediaScreen()));
    case PreviewPostScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: PreviewPostScreen()));
    // case ListProfilePostScreen.route:
    //   var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
    //   return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: ListProfilePostScreen()));
    // case ListProfileReelScreen.route:
    //   var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
    //   var index = (settings.arguments as Map<String, dynamic>)['index'] as int;
    //   return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: ListProfileReelScreen(index: index)));
    case EditStoryScreen.route:
      var bloc = (settings.arguments as Map<String, dynamic>)['bloc'] as StoryBloc;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: bloc, child: EditStoryScreen()));
    case EditReelScreen.route:
      var bloc = (settings.arguments as Map<String, dynamic>)['bloc'] as ReelBloc;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: bloc, child: EditReelScreen()));
    case ReelPreviewScreen.route:
      var bloc = (settings.arguments as Map<String, dynamic>)['bloc'] as ReelBloc;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: bloc, child: ReelPreviewScreen()));
    case StoryScreen.route:
      var stories = (settings.arguments as Map<String, dynamic>)['stories'] as Map<String, List<Story>>;
      var startUserId = (settings.arguments as Map<String, dynamic>)['startUserId'] as String;
      var startStoryIndex = (settings.arguments as Map<String, dynamic>)['startStoryIndex'] as int;
      return MaterialPageRoute(builder: (context) => StoryScreen(stories: stories, startUserId: startUserId, startStoryIndex: startStoryIndex));
    case ReelsScreen.route:
      return MaterialPageRoute(builder: (context) => ReelsScreen());
    default:
      return MaterialPageRoute(builder: (context) => Container());
  }
}
