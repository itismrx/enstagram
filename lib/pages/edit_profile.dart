import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/progress.dart';
import "package:flutter/material.dart";

class EditProfile extends StatefulWidget {
  User _currentUser;
  EditProfile(this._currentUser);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  bool _displayNameValid = false;
  bool _bioValid = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(widget._currentUser.id).get();

    setState(() {
      widget._currentUser = User.fromDocument(doc);
      _nameController.text = widget._currentUser.displayName;
      _bioController.text = widget._currentUser.bio;
      checkValidity();
      isLoading = false;
    });
  }

  checkValidity() {
    setState(() {
      _displayNameValid =
          _nameController.text.trim().length < 6 || _nameController.text.isEmpty
              ? false
              : true;
      _bioValid = _bioController.text.trim().length > 120 ? false : true;
    });
  }

  updateProfile() async {
    checkValidity();
    if (_displayNameValid && _bioValid) {
      bool areYouSure = false;
      await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () {
                    areYouSure = true;
                    Navigator.pop(ctx);
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    areYouSure = false;
                    Navigator.pop(ctx);
                  },
                  child: Text('No'),
                )
              ],
            );
          });
      if (areYouSure) {
        usersRef.doc(widget._currentUser.id).update(
          {
            'bio': _bioController.text,
            'displayName': _nameController.text,
          },
        ).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile Updated Successfully!'),
            ),
          );
        });
      }
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Home();
        },
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      // color: Colors.white,
      margin: const EdgeInsets.only(top: 15),
      height: 35,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context, widget._currentUser),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: isLoading
            ? circularProgress(context)
            : Column(
                children: [
                  buildAppBar(),
                  Container(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        widget._currentUser.photUrl,
                      ),
                      radius: 50,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Display Name',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            hintText: 'Update Name',
                            errorText: _displayNameValid
                                ? null
                                : 'Display Name too short'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bio',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextField(
                          controller: _bioController,
                          decoration: InputDecoration(
                              hintText: 'Update Bio',
                              errorText: _bioValid ? null : 'Bio too long'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: updateProfile,
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.power_settings_new),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ))
                ],
              ),
      ),
    ));
  }
}
