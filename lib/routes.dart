import 'package:flutter/material.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/auth_screen/login_screen.dart';
import 'package:social_media_app/screens/search_screne/search_screen.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch(settings.name) {
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case AccountScreen.route:
      return MaterialPageRoute(builder: (context) => AccountScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case SearchScreen.route:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case AddPostScreen.route:
      return MaterialPageRoute(builder: (context) => AddPostScreen());
    default:
      return MaterialPageRoute(builder: (context) => Container());
  }
}