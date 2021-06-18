import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/header.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({required this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            User user = User.fromOther(data);
            /*{
                'id': data['id'],
                'username': data['username'],
                'photUrl': data['photUrl'],
                'email': data['email'],
                'displayName': data['displayName'],
                'bio': data['bio'],
              }, */

            value = Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(user.photUrl),
                        minRadius: 35,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildCountColumn('posts', 0),
                                buildCountColumn('followers', 0),
                                buildCountColumn('following', 0),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              child: Container(
                                // width: 250,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.5, color: Colors.black),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text('Edit Profile'),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      '${user.username}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '${user.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '${user.bio}',
                    ),
                  )
                ],
              ),
            );
          }
          return value;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, titleText: 'Profile'),
      body: ListView(
        children: [buildProfileHeader()],
      ),
    );
  }
}
