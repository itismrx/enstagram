import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstagram/pages/home.dart';

class Post {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String mediaUrl;
  final String description;
  final Map likes;
  final DateTime timestamp;

  Post(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.mediaUrl,
      required this.description,
      required this.likes,
      required this.timestamp});
  static CollectionReference getPostRef() {
    return FirebaseFirestore.instance.collection('post');
  }

  static getPostById(postId, ownerId) async {
    await Post.getPostRef()
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      Post.fromDocument(doc);
    });
  }

  factory Post.fromDocument(DocumentSnapshot doc) {
    Timestamp time = doc['timestamp'];

    return Post(
        postId: doc['postId'],
        ownerId: doc['ownerId'],
        username: doc['username'],
        location: doc['location'],
        mediaUrl: doc['mediaUrl'],
        description: doc['description'],
        likes: doc['likes'],
        timestamp: time
            .toDate() //DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch)
        );
  }

  static Future<List<Post>> getUserPosts(ownerId) async {
    QuerySnapshot snapshot = await Post.getPostRef()
        .doc(ownerId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> posts = snapshot.docs.map((doc) {
      return Post.fromDocument(doc);
    }).toList();
    return posts;
  }

  bool isLiked() {
    return !this.likes.containsKey(currentUser.id)
        ? false
        : this.likes[currentUser.id];
  }

  like() async {
    getPostRef()
        .doc(this.ownerId)
        .collection('userPosts')
        .doc(this.postId)
        .update(
      {'likes.${currentUser.id}': !isLiked()},
    );
    this.likes[currentUser.id] = !isLiked();
  }

  int getLikes() {
    if (likes == null) {
      return 0;
    }
    int likeCount = 0;
    this.likes.values.forEach((value) {
      if (value) {
        likeCount++;
      }
    });
    return likeCount;
  }
}
