import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/pages/home.dart';

class User {
  final String id;
  final String username;
  final String photUrl;
  final String email;
  final String displayName;
  final String bio;

  User({
    required this.id,
    required this.username,
    required this.photUrl,
    required this.email,
    required this.displayName,
    required this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      username: doc['username'],
      photUrl: doc['photUrl'],
      email: doc['email'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
  factory User.fromOther(Map doc) {
    return User(
      id: doc['id'],
      username: doc['username'],
      photUrl: doc['photUrl'],
      email: doc['email'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
  factory User.createDefault() {
    return User(
      bio: "",
      displayName: "",
      id: "",
      photUrl:
          "https://firebasestorage.googleapis.com/v0/b/enstagram-aecbc.appspot.com/o/icons8-avatar-96.png?alt=media&token=2db81f24-6169-4335-8671-3254a677a996",
      email: "",
      username: "",
    );
  }
  static getUser(String id) {
    User user = User.createDefault();

    usersRef.doc(id).get().then((snapshot) {
      if (snapshot.exists) {
        return User.fromDocument(snapshot);
      } else {
        return user;
      }
    });
  }
}
