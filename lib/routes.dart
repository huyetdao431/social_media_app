import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/widgets/video_trimmer_screen.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/cubit/reel_cubit/reel_cubit.dart';
import 'package:social_media_app/cubit/story_cubit/story_cubit.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
import 'package:social_media_app/screens/account_screen/edit_profile_screen.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
import 'package:social_media_app/commons/widgets/camera_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_image_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_video_screen.dart';
import 'package:social_media_app/screens/add_post_screen/preview_post_screen.dart';
import 'package:social_media_app/screens/add_reel_screen/add_reel_screen.dart';
import 'package:social_media_app/screens/add_reel_screen/edit_reel_screen.dart';
import 'package:social_media_app/screens/add_story_screen/add_story_screen.dart';
import 'package:social_media_app/screens/add_story_screen/edit_story_screen.dart';
import 'package:social_media_app/screens/create_media_screen/create_media_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/auth_screen/login_screen.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';
import 'package:social_media_app/screens/post_list_screen/post_list_screen.dart';
import 'package:social_media_app/screens/reels_screen/reels_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';
import 'package:social_media_app/screens/splash_screen/splash_screen.dart';
import 'package:social_media_app/screens/story_screen/story_screen.dart';

import 'cubit/profile_cubit/profile_cubit.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.route:
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case AccountScreen.route:
      return MaterialPageRoute(builder: (context) => AccountScreen());
    case EditProfileScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditProfileScreen()));
    case AccountSettingScreen.route:
      return _slideRightRoute(AccountSettingScreen());
    case MainScreen.route:
      return MaterialPageRoute(builder: (context) => MainScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case SearchScreen.route:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case CreateMediaScreen.route:
      // return _pushCurrentPageRight(CreateMediaScreen());
      return MaterialPageRoute(builder: (context) => CreateMediaScreen());
    case AddPostScreen.route:
      return _pushCurrentPageRight(AddPostScreen());
    case AddStoryScreen.route:
      return _pushCurrentPageRight(AddStoryScreen());
    case AddReelScreen.route:
      return _pushCurrentPageRight(AddReelScreen());
    case CameraScreen.route:
      return _pushCurrentPageRight(CameraScreen());
    case VideoTrimScreen.route:
      var file = (settings.arguments as Map<String, dynamic>)['file'] as File;
      return _pushCurrentPageRight(VideoTrimScreen(file: file));
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
    case PostListScreen.route:
      int initialIndex = (settings.arguments as Map<String, dynamic>)['initialIndex'] as int;
      return MaterialPageRoute(builder: (context) => PostListScreen(initialIndex: initialIndex));
    case EditStoryScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as StoryCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditStoryScreen()));
    case EditReelScreen.route:
      var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ReelCubit;
      return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: EditReelScreen()));
    case StoryScreen.route:
      return MaterialPageRoute(builder: (context) => StoryScreen());
    case ReelsScreen.route:
      return MaterialPageRoute(builder: (context) => ReelsScreen());
    default:
      return MaterialPageRoute(builder: (context) => Container());
  }
}

PageRouteBuilder _slideRightRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

PageRouteBuilder _pushCurrentPageRight(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;

      var tween = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: curve));

      return Stack(children: [SlideTransition(position: animation.drive(tween), child: page)]);
    },
  );
}
