import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SuggestionTile extends StatefulWidget {
  final double size;
  final String avatarUrl;
  final String username;
  final String userId;

  const SuggestionTile({
    super.key,
    this.size = 72,
    required this.avatarUrl,
    required this.username,
    required this.userId,
  });

  @override
  State<SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<SuggestionTile> {
  bool isFollowing = false;
  bool loading = false;

  void _toggleFollow() async {
    if (loading) return;
    setState(() => loading = true);

    // optimistic UI update
    setState(() => isFollowing = !isFollowing);

    try {
      //todo: gọi event để HomeBloc xử lý
      // if (isFollowing) {
      //   context.read<HomeBloc>().add(FollowUserEvent(targetUserId: widget.userId));
      // } else {
      //   context.read<HomeBloc>().add(UnfollowUserEvent(targetUserId: widget.userId));
      // }
    } catch (e) {
      // rollback nếu lỗi
      setState(() => isFollowing = !isFollowing);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double outer = widget.size;
    final double inner = outer - 4; // ring padding

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // todo: chuyển sang profile screen
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: outer,
                  height: outer,
                  child: Center(
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.avatarUrl,
                        width: inner,
                        height: inner,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[300]),
                        errorWidget: (_, __, ___) =>
                            Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 32)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: outer,
                  height: outer,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        _toggleFollow();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 1, color: Colors.white),
                        ),
                        child: loading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(isFollowing ? Icons.person : Icons.person_add, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: outer + 10,
              child: Text(
                widget.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
