import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';

void deepLinks({required BuildContext context}) {
  final appLinks = AppLinks();
  final sub = appLinks.uriLinkStream.listen((uri) {
    if (uri.host == 'auth-callback') {
      Navigator.pushReplacementNamed(context,MainScreen.route);
    }
  });
}
