import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/post.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/edit_profile.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/post_tile.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({required this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int postCount = 0;
  List<Post> _posts = [];
  @override
  void initState() {
    super.initState();
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          Widget value = Container();
          if (!snapshot.hasData) {
            value = circularProgress(context);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            value = circularProgress(context);
          }
          if (snapshot.hasError) {
            value = Text('Error Happend');
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Container(child: Center(child: value))]);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            User user = User.fromOther(data);
            value = Padding(
              padding: const EdgeInsets.only(top: 26.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(user.photUrl),
                        radius: 50,
                      ),
                      buildProfileButton(),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
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
                  Container(
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
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${user.bio}',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildCountColumn('posts', postCount),
                      buildCountColumn('followers', 0),
                      buildCountColumn('following', 0),
                    ],
                  ),
                  Divider()
                ],
              ),
            );
          }
          return value;
        });
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

  Widget buildPost() {
    return FutureBuilder(
      future: Post.getUserPosts(currentUser.id),
      builder: (context, AsyncSnapshot<List<Post>> posts) {
        Widget response = Container();
        if (posts.hasError) {
          response = Center(
            child: Text('error'),
          );
        }
        if (posts.connectionState == ConnectionState.waiting) {
          SleekCircularSlider(
            appearance: CircularSliderAppearance(
                customWidths: CustomSliderWidths(progressBarWidth: 10)),
            min: 10,
            max: 28,
            initialValue: 14,
          );
        }
        if (posts.connectionState == ConnectionState.done) {
          List<PostTile> postTiles = [];
          postCount = posts.data!.length;
          posts.data!.forEach((post) {
            postTiles.add(PostTile(post));
          });

          response = ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: postTiles,
          );
        }
        return response;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: header(context, isAppTitle: false, titleText: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [buildProfileHeader(), buildPost()],
          ),
        ),
      ),
    );
  }
}
