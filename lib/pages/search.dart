import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _editingController = TextEditingController();
  Widget body = Container();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    body = buildNoContent();
  }

  handleSearch(query) {
    setState(() {
      body = FutureBuilder(
        future:
            usersRef.where('displayName', isGreaterThanOrEqualTo: query).get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Oops, something has gone wrong.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return circularProgress(context);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/search-not-found.png'),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: 'i couldn\'t find ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: '$query',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ])),
                  ],
                ),
              );
            }
            if (!snapshot.data!.docs.isEmpty) {
              List<UserTile> listText = [];
              snapshot.data!.docs.forEach((doc) {
                listText.add(
                  UserTile(
                    user: User.fromDocument(doc),
                  ),
                );
                listText.add(
                  UserTile(
                    user: User.fromDocument(doc),
                  ),
                );
                listText.add(
                  UserTile(
                    user: User.fromDocument(doc),
                  ),
                );
              });
              return Container(
                child: ListView(
                  children: listText,
                ),
              );
            }
          }
          return Text('Loading');
        },
      );
    });
  }

  void clearSearch() {
    _editingController.clear();
    setState(() {
      body = buildNoContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearcBar(),
      body: body,
    );
  }

  AppBar buildSearcBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        onFieldSubmitted: handleSearch,
        controller: _editingController,
        decoration: InputDecoration(
          hintText: 'search for a user...',
          filled: true,
          prefixIcon: Icon(Icons.account_box),
          suffix: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => clearSearch(),
          ),
        ),
      ),
    );
  }

  Container buildNoContent() {
    // final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(shrinkWrap: true, children: [
          SvgPicture.asset('assets/images/search.svg',
              height: 300 // orientation == Orientation.portrait ? 300 : 200,
              ),
          Text(
            "find users..",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
              fontSize: 54,
            ),
          )
        ]),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    String displayName = user.displayName;
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      onTap: () => print(user.username),
      child: Container(
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.photUrl,
                  ),
                ),
                title: Text(displayName[0].toUpperCase() +
                    displayName.substring(1).toLowerCase()),
                subtitle: Text(
                  user.username,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
