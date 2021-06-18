import 'package:flutter/material.dart';

header(context,
    {bool isAppTitle = true,
    String titleText = '',
    bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton,
    title: Text(
      isAppTitle ? 'Enstagram' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : "",
        fontSize: isAppTitle ? 50 : 22,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
