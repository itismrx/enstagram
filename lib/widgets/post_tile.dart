import 'package:cached_network_image/cached_network_image.dart';
import 'package:enstagram/models/activity_feed.dart';
import 'package:enstagram/models/comment.dart';
import 'package:enstagram/pages/post_screen.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../pages/home.dart';
import './custom_image.dart';
import '../services/helper_function.dart';

class PostTile extends StatefulWidget {
  Post post;
  bool isFullSized;
  Function commentAction = () {};
  PostTile({
    required this.post,
    required this.isFullSized,
    required this.commentAction,
  });

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  String ownerProfilePic =
      "https://firebasestorage.googleapis.com/v0/b/enstagram-aecbc.appspot.com/o/icons8-avatar-96.png?alt=media&token=2db81f24-6169-4335-8671-3254a677a996";
  bool isLiked = true;
  int likeCount = 0;
  int commentCount = 0;
  bool showHeart = false;
  User postOwnerUser = User.createDefault();
  @override
  void initState() {
    super.initState();

    usersRef.doc(widget.post.ownerId).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          postOwnerUser = User.fromDocument(snapshot);
          ownerProfilePic = postOwnerUser.photUrl;
          isLiked = widget.post.isLiked();
          likeCount = widget.post.getLikes();
        });
      }
    }, onError: (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error')));
      Navigator.pop(context);
    });
    getCommentCount();
  }

  void getCommentCount() {
    Comment.getCommentRef()
        .doc(widget.post.postId)
        .collection('comments')
        .get()
        .then((snapshot) {
      setState(() {
        commentCount = snapshot.docs.length;
      });
    });
  }

  like() {
    widget.post.like().then((value) {
      setState(() {
        isLiked = !isLiked;
        likeCount = widget.post.getLikes();
      });
      isLiked
          ? ActivityFeed.addLikeToActivityFeed(widget.post, timestamp)
          : ActivityFeed.removeLikeFromActivity(widget.post);
    });
  }

  comment() {
    if (widget.isFullSized) {
      widget.commentAction();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PostScreen(
          widget.post,
          postOwnerUser,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                minRadius: 35,
                backgroundImage: CachedNetworkImageProvider(ownerProfilePic),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.post.username}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.circle, size: 4),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                                '${calculateTimeDifferenceBetween(widget.post.timestamp, DateTime.now())}'),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${widget.post.location}',
                          style: TextStyle(fontSize: 14),
                        )
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => print('Setting'),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onDoubleTap: like,
              onTap: comment,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: cachedNetworkImage(widget.post.mediaUrl),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  likeCount == 0 ? Container() : Text('$likeCount'),
                  SizedBox(
                    width: 2,
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      color: Colors.red,
                    ),
                    onPressed: like,
                  ),
                ],
              ),
              Row(
                children: [
                  commentCount == 0
                      ? Container(
                          width: 2,
                        )
                      : Text('$commentCount'),
                  SizedBox(
                    width: 2,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.message,
                      color: Colors.blue,
                    ),
                    onPressed: comment,
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '${widget.post.description}',
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
