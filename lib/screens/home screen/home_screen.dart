import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/cubit/home_bloc/home_bloc.dart';
import 'package:social_media_app/screens/home%20screen/story_list.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/utils/loader/post_skeleton_loader.dart';

class HomeScreen extends StatelessWidget {
  static const String route = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => HomeBloc(context.read<Api>()), child: Page());
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
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
            StoryList(),
            PostWidgetSkeleton(),
          ],
        ),
      ),
    );
  }
}