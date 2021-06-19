import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enstagram/models/user.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class UploadForm extends StatefulWidget {
  final User currentUser;
  File file;
  UploadForm({required this.currentUser, required this.file});

  @override
  _UploadFormState createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  bool _isUploading = false;
  String postId = Uuid().v4();

  getRealocation() async {
    bool seriviceEnabled;
    LocationPermission locationPermission;

    seriviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!seriviceEnabled) {
      await Geolocator.openLocationSettings().then((bool isSeriviceEnabled) {
        if (!isSeriviceEnabled) {
          return Future.error('Location service is not enabled');
        }
      });
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      await Geolocator.openLocationSettings();
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        return Future.error('Location permission is denied');
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission is permanently denied, we cannot request permssion');
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getUserLocation() async {
    try {
      Position position = await getRealocation();
      locationController.text = "${position.latitude},${position.longitude}";
    } catch (e, ee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$e',
          ),
        ),
      );
    }
    // final geocoding = Geocoder.local;
    // final placeMakers = await geocoding.findAddressesFromCoordinates(
    //     Coordinates(position.latitude, position.longitude));
    // final placeMaker = placeMakers[0];

    //     '{placeMaker.locality}, ${placeMaker.countryName}';
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeJpg(widget.file.readAsBytesSync());
    final compressedFile = File('$path/imag_$postId.jpg')
      ..writeAsBytesSync(
        Im.encodeJpg(imageFile, quality: 85),
      );
    setState(() {
      widget.file = compressedFile;
    });
  }

  uploadImage(imageFile) async {
    final uploadTask =
        await storageRef.child('img_$postId.jpg').putFile(imageFile);
    String downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {required String mediaUrl,
      String location = '',
      String description = ''}) {
    postRef.doc(widget.currentUser.id).collection('userPosts').doc(postId).set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {}
    });
  }

  handleSubmit(context) async {
    setState(() {
      _isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(widget.file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    locationController.clear();
    captionController.clear();
    setState(() {
      widget.file.delete();
      _isUploading = false;
      postId = Uuid().v4();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          'Post Uploaded Successfully',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget buildAppBar(context) {
    return Container(
      // color: Colors.white,
      // margin: const EdgeInsets.only(top: 35),
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            onTap: _isUploading ? null : () => handleSubmit(context),
            child: Container(
              child: Container(
                height: 35,
                width: 75,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadiusDirectional.circular(15),
                ),
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              buildAppBar(context),
              _isUploading ? linearProgress(context) : SizedBox(),
              Container(
                height: 220,

                // width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(
                            widget.file,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    currentUser.photUrl,
                  ),
                ),
                title: Container(
                  width: 250,
                  child: TextField(
                    controller: captionController,
                    decoration: InputDecoration(
                      hintText: 'Write caption..',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.pin_drop,
                  color: Theme.of(context).accentColor,
                  size: 36,
                ),
                title: Container(
                  width: 250,
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Where was this image taken?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 200,
                height: 40,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                      primary: Colors.white),
                  onPressed: getUserLocation, //getLocation(),
                  icon: Icon(Icons.my_location),
                  label: Text(
                    'Use Current Location',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
