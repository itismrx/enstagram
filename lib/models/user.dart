import 'package:cloud_firestore/cloud_firestore.dart';

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
}
