import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/story.dart';

class StoryAvatar extends StatelessWidget {
  final double size;
  final String avatarUrl;
  final List<Story> stories;
  final bool isCurrentUser;
  final String? username;

  const StoryAvatar({super.key, this.size = 72, required this.avatarUrl, this.stories = const [], this.isCurrentUser = false, this.username});

  Gradient getPublicGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)]);

  Gradient getCloseFriendsGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7AE582), Color(0xFF3ED36B)]);

  @override
  Widget build(BuildContext context) {
    final hasStories = stories.isNotEmpty;
    final allWatched = hasStories ? stories.every((s) => (s.isViewed)) : false;
    final anyCloseFriends = hasStories ? stories.any((s) => (s.visibility ?? '') == 'close_friends') : false;
    final anyPublic = hasStories ? stories.any((s) => (s.visibility ?? '') == 'public') : false;

    final bool showGrey = hasStories && allWatched;
    final Gradient ringGradient =
        showGrey ? const LinearGradient(colors: [Colors.grey, Colors.grey]) : (anyCloseFriends && !anyPublic ? getCloseFriendsGradient() : getPublicGradient());

    const double ringWidth = 4.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: ringGradient),
          child: Padding(
            padding: const EdgeInsets.all(ringWidth),
            child: ClipOval(
              child: Container(
                color: Colors.transparent,
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: size - ringWidth * 2,
                  height: size - ringWidth * 2,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[300]),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 32)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 2),

        SizedBox(
          width: size + 10,
          child: Text(username ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ),

        if (isCurrentUser) const SizedBox.shrink() else const SizedBox(height: 0),
      ],
    );
  }
}
