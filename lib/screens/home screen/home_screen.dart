import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media_app/main.dart';
import 'package:social_media_app/screens/add_story_screen/add_story_screen.dart';
import 'package:social_media_app/screens/story_screen/story_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../commons/widgets/post.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none)),
              Positioned(top: 8, right: 12, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            //dang tin
            Story(),
            Post(),
            GestureDetector(
              onTap: () async {
                final supabase = Supabase.instance.client;
                const webClientId = '193704256783-obenl9l7r5bbg19l5jb7ltdk9g019ouv.apps.googleusercontent.com';
                // const iosClientId = '193704256783-qevd2nv3vv1u37aa33ine17j5qgrt85m.apps.googleusercontent.com';
                final GoogleSignIn googleSignIn = GoogleSignIn(
                  // clientId: iosClientId,
                  serverClientId: webClientId,
                );
                final googleUser = await googleSignIn.signIn();
                final googleAuth = await googleUser!.authentication;
                final accessToken = googleAuth.accessToken;
                final idToken = googleAuth.idToken;

                if (accessToken == null) {
                  throw 'No Access Token found.';
                }
                if (idToken == null) {
                  throw 'No ID Token found.';
                }

                await supabase.auth.signInWithIdToken(
                  provider: OAuthProvider.google,
                  idToken: idToken,
                  accessToken: accessToken,
                );
              },
              child: Container(width: double.infinity, height: 50, child: Text('login with google')),
            ),
            GestureDetector(
              onTap: () async {
                final supabase = Supabase.instance.client;
                try {
                  final LoginResult result = await FacebookAuth.instance.login();

                  if (result.status == LoginStatus.success) {
                    final accessToken = result.accessToken!.tokenString;
                    print('Facebook token: $accessToken');

                    // Đăng nhập Supabase bằng access token này
                    final response = await supabase.auth.signInWithIdToken(
                      provider: OAuthProvider.facebook,
                      idToken: accessToken,
                    );

                    if (response.user != null) {
                      print('Supabase login thành công: ${response.user!.email}');
                    } else {
                      print('Supabase login thất bại');
                    }
                  } else {
                    print('Facebook login thất bại: ${result.status}');
                  }
                } catch (e) {
                  print('Lỗi đăng nhập Facebook: $e');
                }
              },
              child: Container(width: double.infinity, height: 50, child: Text('login with facebook')),
            ),
          ],
        ),
      ),
    );
  }
}

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  List<bool> isWatched = List<bool>.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AddStoryScreen.route);
              },
              child: Stack(
                children: [
                  CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/avt_01.png'), backgroundColor: Colors.transparent),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(width: 1.5, color: Colors.black)),
                      child: const Icon(Icons.add, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isWatched[i] = true;
                      Navigator.of(context).pushNamed(StoryScreen.route);
                    });
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: Center(child: Container(width: 64, height: 64, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black))),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(width: 3, color: isWatched[i] ? Colors.grey : Colors.pink),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Center(child: Container(height: 64, width: 64, decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle))),
                  ),
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                          // border: Border.all(
                          //   width: 1,
                          //   color: Colors.white,
                          // ),
                        ),
                        child: Icon(Icons.person_add, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
