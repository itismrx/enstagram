import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enstagram/pages/upload_form.dart';
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
  bool _isImagePicked = false;
  File _file = File('');

  @override
  void dispose() {
    super.dispose();
    _file.delete();
  }

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('please pick an imaage')));
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
      setState(() {
        _isImagePicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('please pick an imaage')));
    }
  }

  selectImage(parentContext) async {
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
                onPressed: () {
                  _isImagePicked = false;
                  Navigator.pop(context);
                },
              )
            ],
          );
        }).then((value) {
      if (_isImagePicked) {
        Navigator.push(context, MaterialPageRoute(builder: (cxt) {
          return UploadForm(currentUser: currentUser, file: _file);
        }));
      }
    });
  }

  buildSplashScreen() {
    return Scaffold(
      body: Container(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen();
  }
}
