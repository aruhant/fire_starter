import 'dart:math';

import 'package:fire_starter/helpers/helpers.dart';
import 'package:fire_starter/services/config_service.dart';
import 'package:fire_starter/services/package_info.dart';
import 'package:fire_starter/ui/components/widgets/glass/blob.dart';
import 'package:get/get.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/slide_object.dart';

class IntroSliderUI extends StatelessWidget {
  List<Slide> makeSlides(context) {
    if (PackageInfoService.metadata == null) {
      GetLogger.to.w('No Metadata');
      Future.delayed(Duration(milliseconds: 1000)).then((value) => onDonePress());
      return [];
    }
    if (PackageInfoService.metadata!.introSlider == null || PackageInfoService.metadata!.introSlider!.length == 0) {
      Future.delayed(Duration(milliseconds: 1000)).then((value) => onDonePress());
      return [];
    }
    GetLogger.to.i(PackageInfoService.metadata!.introSlider_hi.toString());
    return (ConfigStorage.locale == 'hi')
        ? PackageInfoService.metadata!.introSlider_hi!.map((e) => makeSlide(context, e)).toList()
        : PackageInfoService.metadata!.introSlider!.map((e) => makeSlide(context, e)).toList();
  }

  Slide makeSlide(BuildContext context, Map slide) {
    print(slide);
    return new Slide(
        title: (slide['title'] as String).replaceAll('\\n', '\n'),
        description: slide['description'].replaceAll('\\n', '\n'),
        styleTitle: Theme.of(context).textTheme.headline3,
        styleDescription: Theme.of(context).textTheme.headline6,
        pathImage: slide['image'],
        backgroundColor: Color((slide['color'] ?? Random().nextInt(0xFFFFFF)) as int).withAlpha(50),
        maxLineTitle: 5,
        maxLineTextDescription: 20);
  }

  @override
  Widget build(BuildContext context) {
    List<Slide> slides = makeSlides(context);
    return Scaffold(
        body: (slides.length != 0)
            ? BlobBackground(
                child: IntroSlider(
                doneButtonStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
                showSkipBtn: false,
                showNextBtn: true,
                slides: slides,
                onDonePress: this.onDonePress,
              ))
            : Container());
  }

  void onDonePress() {
    ConfigStorage.saveShowIntroSlider(false);
    Get.offAllNamed('/');
  }
}
