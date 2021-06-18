import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:enstagram/widgets/header.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, titleText: 'Enstagram'),
        body: Text('Timeline'));
  }
}
