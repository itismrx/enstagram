import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../pages/home.dart';
import './custom_image.dart';
import '../widgets/progress.dart';

class PostTile extends StatefulWidget {
  Post post;
  PostTile(this.post);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  String ownerProfilePic =
      "https://firebasestorage.googleapis.com/v0/b/enstagram-aecbc.appspot.com/o/icons8-avatar-96.png?alt=media&token=2db81f24-6169-4335-8671-3254a677a996";
  bool isLiked = true;
  int likeCount = 0;
  bool showHeart = false;
  @override
  void initState() {
    super.initState();

    usersRef.doc(widget.post.ownerId).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          ownerProfilePic = User.fromDocument(snapshot).photUrl;
          isLiked = widget.post.isLiked();
          likeCount = widget.post.getLikes();
        });
      }
    }, onError: (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error')));
      Navigator.pop(context);
    });
  }

  static String calculateTimeDifferenceBetween(
      DateTime startDate, DateTime endDate) {
    int seconds = endDate.difference(startDate).inSeconds;
    if (seconds < 60)
      return '${seconds}s';
    else if (seconds >= 60 && seconds < 3600)
      return '${startDate.difference(endDate).inMinutes.abs()}m';
    else if (seconds >= 3600 && seconds < 86400)
      return '${startDate.difference(endDate).inHours.abs()}h';
    else {
      int days = startDate.difference(endDate).inDays.abs();
      if (days > 7) {
        return '${DateFormat('MMMd').format(startDate)}';
      } else {
        return '${days}d';
      }
    }
  }

  like() {
    widget.post.like().then((value) {
      setState(() {
        isLiked = !isLiked;
        likeCount = widget.post.getLikes();
      });
    });
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
              IconButton(
                  icon: Icon(
                    Icons.message,
                    color: Colors.blue,
                  ),
                  onPressed: () => print('comment')),
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
