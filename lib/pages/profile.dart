import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/post.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/edit_profile.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/post_tile.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({required this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int postCount = 0;
  List<Post> _posts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    final posts = await Post.getUserPosts(widget.profileId);
    setState(() {
      _posts = posts;
      isLoading = false;
      postCount = _posts.length;
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          Widget value = Container();
          if (!snapshot.hasData) {
            // value = circularProgress(context);
            value = buildProfileHeaderTile(currentUser, true);
          }
          if (snapshot.hasError) {
            value = value = buildProfileHeaderTile(currentUser, true);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            User user = User.fromOther(data);
            value = buildProfileHeaderTile(user, false);
          }
          return value;
        });
  }

  Padding buildProfileHeaderTile(User user, bool isNotLoaded) {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isNotLoaded
              ? CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.photUrl),
                      radius: 50,
                    ),
                    buildProfileButton(),
                  ],
                ),
          SizedBox(
            height: 15,
          ),
          isNotLoaded
              ? Container(
                  color: Colors.grey,
                  width: 150,
                  height: 15,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${user.displayName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // buildProfileButton(),
                  ],
                ),
          SizedBox(
            height: 15,
          ),
          isNotLoaded
              ? Container(
                  color: Colors.grey,
                  width: 70,
                  height: 15,
                )
              : Container(
                  alignment: Alignment.centerLeft,
                  // padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          SizedBox(
            height: 15,
          ),
          isNotLoaded
              ? Container(
                  color: Colors.grey,
                  width: 150,
                  height: 15,
                )
              : Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${user.bio}',
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildCountColumn('posts', isNotLoaded ? 0 : postCount),
              buildCountColumn('followers', 0),
              buildCountColumn('following', 0),
            ],
          ),
          Divider()
        ],
      ),
    );
  }

  handleFollower() {}

  Widget buildProfileButton() {
    return currentUser.id == widget.profileId
        ? GestureDetector(
            onTap: () async {
              User updatedCurrentUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return EditProfile(currentUser);
                  },
                ),
              );
              setState(() {
                currentUser = updatedCurrentUser;
              });
            },
            child: Container(
              width: 150,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                // border: Border.all(width: 1.5, color: Colors.black),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : GestureDetector(
            onTap: handleFollower,
            child: Container(
              width: 100,
              height: 35,
              margin: const EdgeInsets.only(right: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,

                  // border: Border.all(width: 1.5, color: Colors.black),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Follow',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            )),
      ],
    );
  }

  buildPost() {
    if (isLoading) {
      return circularProgress(context);
    } else if (_posts.isNotEmpty) {
      List<PostTile> postTiles = [];
      _posts.forEach((post) {
        postTiles.add(
            PostTile(post: post, isFullSized: false, commentAction: () {}));
      });

      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, idx) {
          return postTiles[idx];
        },
        itemCount: postTiles.length,
      );
    } else {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: header(context, isAppTitle: false, titleText: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildProfileHeader(),
              buildPost(),
            ],
          ),
        ),
      ),
    );
  }
}
