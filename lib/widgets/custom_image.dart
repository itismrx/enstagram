import 'package:cached_network_image/cached_network_image.dart';
import 'package:enstagram/widgets/progress.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    width: 480,
    fit: BoxFit.fitWidth,
    placeholder: (context, url) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: circularProgress(context),
      );
    },
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
