import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/activity_feed.dart';
import 'package:enstagram/models/comment.dart';
import 'package:enstagram/models/post.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/comment_tile.dart';
import 'package:enstagram/widgets/post_tile.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  Post post;
  User user;

  PostScreen(this.post, this.user);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController _commentController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _commentController.dispose();
  }

  buildCommentSection() {
    return StreamBuilder(
      stream: Comment.featchAndSetComments(widget.post.postId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        if (snapshot.hasError) {
          return Text('Error');
        }
        if (snapshot.data!.docs.isEmpty) {
          return Container(
              height: 150,
              child: Center(child: Text('Be the first one to comment')));
        }
        List<Comment> comments = [];
        snapshot.data!.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return Container(
          // height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, idx) {
              return CommentTile(comments[idx], widget.user);
            },
            itemCount: comments.length,
          ),
        );
      },
    );
  }

  addComment() {
    Comment comment = Comment(
        ownerId: currentUser.id,
        content: _commentController.text,
        timestamp: timestamp);
    Comment.addComment(comment, widget.post.postId);

    ActivityFeed.addCommentActivity(
        widget.post, _commentController.text, timestamp);

    _commentController.clear();
  }

  buildCommentTextBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            focusNode: _focusNode,
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write your comment...',
            ),
          ),
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: addComment,
            child: Container(
              width: 105,
              alignment: Alignment.center,
              height: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Comment',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  foucusComment() {
    print('Focus');
    setState(() {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 100,
                child: SingleChildScrollView(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: PostTile(
                          post: widget.post,
                          isFullSized: true,
                          commentAction: foucusComment),
                    ),
                    buildCommentSection(),
                  ]),
                ),
              ),
              buildCommentTextBox(),
            ],
          ),
        ),
      ),
    );
  }
}
