import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:enstagram/models/user.dart';
import 'package:enstagram/pages/home.dart';
import 'package:enstagram/widgets/progress.dart';
// import 'package:geocoder/geocoder.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({required this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  bool _isImagePicked = false;
  bool _isUploading = false;
  File _file = File('file.txt');
  String postId = Uuid().v4();

  takePhoto() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
        _isImagePicked = true;
      });
    } else {
      print('no file');
      setState(() {
        _isImagePicked = false;
      });
    }
  }

  fromGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
        _isImagePicked = true;
      });
    } else {
      print('no file');
    }
  }

  selectImage(parentContext) {
    showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: takePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: fromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildSplashScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            './assets/images/upload.svg',
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
            ),
            child: GestureDetector(
              onTap: () => selectImage(context),
              child: Container(
                width: 250,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Upload Image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  handleBack() {
    setState(() {
      _isImagePicked = false;
      _file.delete();
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeJpg(_file.readAsBytesSync());
    final compressedFile = File('$path/imag_$postId.jpg')
      ..writeAsBytesSync(
        Im.encodeJpg(imageFile, quality: 85),
      );
    setState(() {
      _file = compressedFile;
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
    String mediaUrl = await uploadImage(_file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    locationController.clear();
    captionController.clear();
    setState(() {
      _file.delete();
      _isUploading = false;
      postId = Uuid().v4();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post Uploaded Successfully'),
      ),
    );
  }

  getRealocation() async {
    bool seriviceEnabled;
    LocationPermission locationPermission;

    seriviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!seriviceEnabled) {
      return Future.error('Location service is not enabled');
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

  getUserLocation() async {
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

  buildUploadForm(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: handleBack,
        ),
        title: Text('Caption Post'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : () => handleSubmit(context),
            child: Text(
              'Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isUploading ? linearProgress(context) : Container(),
            Container(
              height: 220,

              // width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          _file,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_isImagePicked ? buildSplashScreen() : buildUploadForm(context);
  }
}
