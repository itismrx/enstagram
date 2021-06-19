import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

circularProgress(context) {
  // return Container(
  //   alignment: Alignment.center,
  //   padding: EdgeInsets.only(top: 10),
  //   child:
  //   CircularProgressIndicator(
  //     valueColor: AlwaysStoppedAnimation(
  //       Theme.of(context).accentColor,
  //     ),
  //   ),
  // );
  return SleekCircularSlider(
      appearance: CircularSliderAppearance(
    customColors:
        CustomSliderColors(progressBarColor: Theme.of(context).accentColor),
    customWidths: CustomSliderWidths(progressBarWidth: 5),
    spinnerMode: true,
  ));
}

linearProgress(context) {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Theme.of(context).accentColor,
      ),
    ),
  );
}
