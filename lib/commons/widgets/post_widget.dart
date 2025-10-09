import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/widgets/expandable_caption.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../materials/app_colors.dart';
import '../../materials/app_text_styles.dart';

import 'dart:async';

import '../../models/post.dart';
import '../../models/post_media.dart';
import '../../utils/time_ago.dart';
import 'display_video.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final bool initiallyLiked;
  final bool initiallySaved;

  // Callbacks để integrate với bloc/repo
  final Future<void> Function(Post post)? onLike;
  final Future<void> Function(Post post)? onSave;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final VoidCallback? onProfileTap;

  const PostWidget({
    super.key,
    required this.post,
    this.initiallyLiked = false,
    this.initiallySaved = false,
    this.onLike,
    this.onSave,
    this.onCommentTap,
    this.onShare,
    this.onMore,
    this.onProfileTap,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with TickerProviderStateMixin {
  late PageController _pageController;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  bool _isLiked = false;
  bool _isSaved = false;

  // Heart overlay state
  bool _showHeart = false;
  Alignment _heartAlignment = Alignment.center;
  late AnimationController _heartController;

  String? _visibleVideoId;

  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isLiked = widget.initiallyLiked;
    _isSaved = widget.initiallySaved;

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // <- 200ms
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.95).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_heartController);

    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _heartController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(Offset localPosition, Size boxSize) async {
    // compute fractional alignment
    final dx = (localPosition.dx / boxSize.width).clamp(0.0, 1.0);
    final dy = (localPosition.dy / boxSize.height).clamp(0.0, 1.0);

    setState(() {
      _heartAlignment = Alignment((dx - 0.5) * 2, (dy - 0.5) * 2); // -1..1
      _showHeart = true;
    });

    // play scale animation
    _heartController.reset();
    _heartController.forward();

    // toggle like locally
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
      });
      if (widget.onLike != null) {
        try {
          await widget.onLike!(widget.post);
        } catch (_) {
          // fallback: revert or handle error
        }
      }
    }

    // hide after timeout
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  Widget _buildMediaItem(BuildContext context, PostMedia media) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = w / (widget.post.aspectRatio == 0 ? 1 : widget.post.aspectRatio);

      // nếu kiểu video
      if (media.mediaType.startsWith('video')) {
        // giả sử media.mediaUrl là URL (network). Nếu bạn có local File, chuyển sang SmartVideo(file: ...)
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final local = renderBox.globalToLocal(details.globalPosition);
            _handleDoubleTap(local, renderBox.size);
          },
          child: SizedBox(
            width: w,
            height: h,
            child: VisibilityDetector(
              key: Key('video-${media.id}'),
              onVisibilityChanged: (info) {
                final visible = info.visibleFraction; // 0.0 -> 1.0
                final fullyVisible = visible >= 0.95;
                if (fullyVisible) {
                  // yêu cầu smartVideo init & play
                  setState(() {
                    _visibleVideoId = media.id; // theo id hoặc index
                  });
                } else {
                  if (_visibleVideoId == media.id) {
                    setState(() => _visibleVideoId = null);
                  }
                }
              },
              child: SmartVideo(
                url: media.mediaUrl,
                shouldPlay: _visibleVideoId == media.id,
                aspectRatio: widget.post.aspectRatio,
              ),
            )
          ),
        );
      }

      // image
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTapDown: (details) {
          final renderBox = context.findRenderObject() as RenderBox;
          final local = renderBox.globalToLocal(details.globalPosition);
          _handleDoubleTap(local, renderBox.size);
        },
        child: SizedBox(
          width: w,
          height: h,
          child: CachedNetworkImage(
            imageUrl: media.mediaUrl,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => Container(color: Colors.grey[300]),
            errorWidget: (ctx, url, error) => Container(color: Colors.grey, child: const Icon(Icons.error)),
          ),
        ),
      );
    });
  }

  Widget _buildIndicator(int itemCount) {
    const maxVisible = 7;
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, current, _) {
        final visibleDots = itemCount > maxVisible ? maxVisible : itemCount;
        final half = visibleDots ~/ 2;
        final start = (current - half).clamp(0, (itemCount - visibleDots).clamp(0, itemCount));
        final end = (start + visibleDots).clamp(0, itemCount);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(itemCount, (index) {
            if (index < start || index >= end) return const SizedBox.shrink();
            final isActive = index == current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : AppColors.subHeadlineDark,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget avatarWidget(BuildContext context) {
    final profile = context.read<MainCubit>().state.profile;
    final avatarUrl = profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 44, height: 44, fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey[300], width: 44, height: 44),
        ),
      );
    }
    return Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black));
  }


  @override
  Widget build(BuildContext context) {
    final media = widget.post.mediaList ?? [];
    final mediaCount = media.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onProfileTap,
                child: avatarWidget(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.read<MainCubit>().state.profile!.username, style: AppTextStyles.username(context)),
                      const SizedBox(height: 2),
                      Text(timeAgo(widget.post.createdAt), style: AppTextStyles.hashtag(context)),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onMore ?? () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(leading: const Icon(Icons.bookmark_border), title: const Text('Save'), onTap: widget.onSave != null ? () => widget.onSave!(widget.post) : null),
                        ListTile(leading: const Icon(Icons.person_remove_alt_1_outlined), title: const Text('Unfollow'), onTap: () => {}),
                        ListTile(leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error), title: Text('Report', style: TextStyle(color: Theme.of(context).colorScheme.error)), onTap: () {}),
                      ],
                    ),),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Media area with heart overlay & pageview
        AspectRatio(
          aspectRatio: widget.post.aspectRatio > 0 ? widget.post.aspectRatio : 1,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: mediaCount == 0 ? 1 : mediaCount,
                onPageChanged: (index) => _currentIndex.value = index,
                itemBuilder: (context, index) {
                  if (mediaCount == 0) {
                    // placeholder
                    return GestureDetector(
                      onDoubleTapDown: (details) {
                        final renderBox = context.findRenderObject() as RenderBox;
                        final local = renderBox.globalToLocal(details.globalPosition);
                        _handleDoubleTap(local, renderBox.size);
                      },
                      onDoubleTap: () {
                        if (!_isLiked && widget.onLike != null) widget.onLike!(widget.post);
                        setState(() => _isLiked = true);
                      },
                      child: Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text('No media', style: AppTextStyles.badge(context)),
                      ),
                    );
                  }
                  final mediaItem = media[index];
                  return _buildMediaItem(context, mediaItem);
                },
              ),

// trong Stack (media area):
              if (_showHeart)
                IgnorePointer(
                  ignoring: true,
                  child: AnimatedBuilder(
                    animation: _heartController,
                    builder: (context, child) {
                      return Align(
                        alignment: _heartAlignment,
                        child: Opacity(
                          opacity: _opacityAnim.value,
                          child: Transform.scale(
                            scale: _scaleAnim.value,
                            child: const Icon(
                              Icons.favorite,
                              size: 120,
                              color: Colors.red,
                              shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // top-right counter badge
              if (mediaCount > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(178),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('${_currentIndex.value + 1}/$mediaCount', style: AppTextStyles.badge(context).copyWith(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // indicator
        if (mediaCount > 1)
          Center(child: _buildIndicator(mediaCount)),

        const SizedBox(height: 8),

        // Action row (like/comment/share/save)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              // Like button
              GestureDetector(
                onTap: () async {
                  setState(() => _isLiked = !_isLiked);
                  if (widget.onLike != null) await widget.onLike!(widget.post);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: _isLiked
                      ? const Icon(Icons.favorite, key: ValueKey('liked'), color: Colors.red, size: 32)
                      : const Icon(Icons.favorite_border, key: ValueKey('unliked'), size: 32),
                ),
              ),
              const SizedBox(width: 12),

              // Comment
              GestureDetector(
                onTap: widget.onCommentTap,
                child: const Icon(Icons.mode_comment_outlined, size: 32),
              ),
              const SizedBox(width: 12),

              // Share
              GestureDetector(onTap: widget.onShare, child: const Icon(Icons.send_outlined, size: 32)),
              const Spacer(),

              // Save
              GestureDetector(
                onTap: () async {
                  setState(() => _isSaved = !_isSaved);
                  if (widget.onSave != null) await widget.onSave!(widget.post);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: _isSaved ? const Icon(Icons.bookmark, key: ValueKey('saved'), size: 28) : const Icon(Icons.bookmark_border, key: ValueKey('unsaved'), size: 28),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Likes count + caption + comments count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.post.likesCount + (_isLiked ? 1 : 0)} lượt thích', style: AppTextStyles.username(context)),
              const SizedBox(height: 6),
              if ((widget.post.caption ?? '').isNotEmpty)
                ExpandableCaption(username: context.read<MainCubit>().state.profile!.username, caption: widget.post.caption ?? ''),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: widget.onCommentTap,
                child: Text('Xem tất cả ${widget.post.commentsCount} bình luận', style: AppTextStyles.hashtag(context)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}


class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _focusNode = FocusNode();
  final _commentController = TextEditingController(text: '');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Comments', style: AppTextStyles.subHeadline(context)),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Comment(onClick: () {
                    _focusNode.requestFocus();
                  },);
                },
              ),
            ),
            SizedBox(height: 72,),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary.withAlpha(51),
              child: Icon(Icons.person, color: colorScheme.onPrimary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _commentController,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Thêm bình luận...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest, // phù hợp với dark/light mode
                ),
                style: TextStyle(color: colorScheme.onSurface), // màu chữ
                cursorColor: colorScheme.primary,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                print('Gửi bình luận');
              },
              child: Icon(
                Icons.send,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Comment extends StatefulWidget {
  final VoidCallback? onClick;
  const Comment({super.key, this.onClick});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isLiked = false;
  bool haveReplies = true;
  bool showReplies = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                print('go to Account Screen');
              },
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ExpandableCaption(
                              username: 'username',
                              caption:
                                  'Technology continues to reshape our world, driving innovation in communication, healthcare, and education. From artificial intelligence to renewable energy, advancements offer both opportunities and challenges. Embracing change while addressing ethical concerns is crucial. As we adapt, staying informed and responsible ensures progress benefits society, creating a more connected and sustainable future.',
                            ),
                          ),
                          Row(
                            children: [
                              Text('100 liked', style: AppTextStyles.caption(context)),
                              SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  widget.onClick!();
                                },
                                child: Text('reply', style: AppTextStyles.caption(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                          child:
                          isLiked
                              ? TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.3, end: 1.0),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: 1.0,
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          )
                              : Icon(Icons.favorite_border, size: 24),
                        ),
                        SizedBox(height: 4,),
                        Text('data', style: AppTextStyles.hashtag(context),),
                      ],
                    ),
                  ],
                ),
                if(showReplies)
                  for(int i = 0; i< 2; i++)
                    Comment(),
                if(haveReplies)
                  Align(alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: () {
                      setState(() {
                        showReplies = !showReplies;
                      });
                    }, child: showReplies ? Text('hide') : Text('show xxx replies')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
