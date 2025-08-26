import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
import 'package:social_media_app/screens/add_post_screen/camera_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_image_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';
import 'package:social_media_app/screens/add_post_screen/edit_video_screen.dart';
import 'package:social_media_app/screens/add_post_screen/preview_post_screen.dart';
import 'package:social_media_app/screens/add_story_screen/add_story_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/auth_screen/login_screen.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';
import 'package:social_media_app/screens/post_list_screen/post_list_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case AccountScreen.route:
      return MaterialPageRoute(builder: (context) => AccountScreen());
    case AccountSettingScreen.route:
      return _slideRightRoute(AccountSettingScreen());
    case MainScreen.route:
      return MaterialPageRoute(builder: (context) => MainScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case SearchScreen.route:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case AddPostScreen.route:
      return _pushCurrentPageRight(AddPostScreen());
    case AddStoryScreen.route:
      return _pushCurrentPageRight(AddStoryScreen());
    case CameraScreen.route:
      return _pushCurrentPageRight(CameraScreen());
    case EditImageScreen.route:
      var cubit =
      (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(
        builder:
            (context) =>
            BlocProvider.value(value: cubit, child: EditImageScreen()),
      );
    case EditVideoScreen.route:
      var cubit =
      (settings.arguments as Map<String, dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(
        builder:
            (context) =>
            BlocProvider.value(value: cubit, child: EditVideoScreen()),
      );
    case EditMediaScreen.route:
      var assets =
      (settings.arguments as Map<String, dynamic>)['assets']
      as List<AssetEntity>;
      return MaterialPageRoute(
        builder: (context) => EditMediaScreen(assets: assets),
      );
    case PreviewPostScreen.route:
      var cubit = (settings.arguments as Map<String,
          dynamic>)['cubit'] as PostCubit;
      return MaterialPageRoute(
        builder: (context) =>
            BlocProvider.value(
              value: cubit,
              child: PreviewPostScreen(),
            ),
      );
    case PostListScreen.route:
      int initialIndex =
      (settings.arguments as Map<String, dynamic>)['initialIndex'] as int;
      return MaterialPageRoute(
        builder: (context) => PostListScreen(initialIndex: initialIndex),
      );
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

      var tween = Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve));

      return Stack(
        children: [
          SlideTransition(position: animation.drive(tween), child: page),
        ],
      );
    },
  );
}
