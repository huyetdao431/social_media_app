import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/commons/widgets/expandable_caption.dart';

import '../../materials/app_colors.dart';
import '../../materials/app_text_styles.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isLiked = false;
  bool isSaved = false;
  final items = [1, 2, 3, 4, 5, 6];
  int currentIndex = 0;

  Offset? tapPosition;
  bool showHeart = false;
  double heartScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print('go to account screen');
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('username', style: AppTextStyles.username(context)),
                    SizedBox(width: 4),
                    Text('time', style: AppTextStyles.hashtag(context)),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(width: 2),
                                        ),
                                        child: Icon(
                                          Icons.bookmark_border,
                                          size: 42,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Save'),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),
                              ListTile(
                                leading: Icon(Icons.star_border),
                                title: Text(
                                  'Add to favorite',
                                  style: AppTextStyles.button(context),
                                ),
                                onTap: () {
                                  print('add to favorite');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.person_remove_alt_1_outlined,
                                ),
                                title: Text(
                                  'Unfollow',
                                  style: AppTextStyles.button(context),
                                ),
                                onTap: () {
                                  print('unfollow');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                title: Text(
                                  'report',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                onTap: () {
                                  print('report');
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        SizedBox(height: 12),
        Stack(
          children: [
            Column(
              children: [
                CarouselSlider(
                  items:
                      items.map((item) {
                        return Builder(
                          builder: (context) {
                            return GestureDetector(
                              onDoubleTapDown: (details) {
                                setState(() {
                                  tapPosition = details.localPosition;
                                  showHeart = true;
                                  heartScale = 1.5;
                                  isLiked = true;
                                });

                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    setState(() {
                                      heartScale = 1.0;
                                    });
                                  },
                                );

                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    setState(() {
                                      showHeart = false;
                                    });
                                  },
                                );
                              },
                              onDoubleTap: () {
                                print('on double tap');
                              },
                              onTap: () {
                                print('go to post detail');
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    color:
                                        item % 2 == 0
                                            ? Colors.pink
                                            : Colors.black,
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.toString(),
                                      style: AppTextStyles.badge(context),
                                    ),
                                  ),
                                  if (showHeart && tapPosition != null)
                                    Positioned(
                                      left: tapPosition!.dx - 24,
                                      top: tapPosition!.dy - 24,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 1.5, end: 1.0),
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.bounceInOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Opacity(
                                              opacity: showHeart ? 0.8 : 0.0,
                                              child: Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 48,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                  options: CarouselOptions(
                    height: 500,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(items.length, (index) {
                    // Tính toán hiển thị từIndex đến toIndex để giới hạn chỉ 7 chấm
                    int visibleDots = 7 < items.length ? 7 : items.length;
                    int half = visibleDots ~/ 2;

                    int start = (currentIndex - half).clamp(
                      0,
                      items.length - visibleDots,
                    );
                    int end = (start + visibleDots).clamp(0, items.length);

                    // Nếu index nằm ngoài phạm vi hiển thị thì không render
                    if (index < start || index >= end) return const SizedBox();

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentIndex == index ? 12 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            currentIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : AppColors.subHeadlineDark,
                      ),
                    );
                  }),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentIndex + 1}/${items.length}',
                  style: AppTextStyles.badge(context),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Row(
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
                                          size: 32,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Icon(Icons.favorite_border, size: 32),
                      ),
                      SizedBox(width: 4),
                      Text('data', style: AppTextStyles.hashtag(context)),
                    ],
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return CommentScreen();
                            },
                          );
                        },
                        child: Icon(Icons.mode_comment_outlined, size: 32),
                      ),
                      SizedBox(width: 4),
                      Text('data', style: AppTextStyles.hashtag(context)),
                    ],
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 4,
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(Icons.share, size: 32),
                      ),
                      SizedBox(width: 4),
                      Text('data', style: AppTextStyles.hashtag(context)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isSaved = !isSaved;
                });
              },
              icon:
                  isSaved
                      ? Icon(Icons.bookmark, size: 32)
                      : Icon(Icons.bookmark_border, size: 32),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExpandableCaption(
              username: 'username',
              caption:
                  'Discover new possibilities every day — stay inspired, stay curious, and keep moving forward with purpose and passion.',
            ),
          ),
        ),
        SizedBox(height: 16),
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
