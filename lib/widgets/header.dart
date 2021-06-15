import 'package:flutter/material.dart';

header(context, {bool isAppTitle = true, String titleText}) {
  return AppBar(
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
