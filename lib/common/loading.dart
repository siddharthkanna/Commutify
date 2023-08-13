import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.twoRotatingArc(
        color: Apptheme.noir,
        size: 40,
      ),
    );
  }
}

class LoaderAnimated extends StatelessWidget {
  const LoaderAnimated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black45,
        body: Center(
          child: LoadingAnimationWidget.twoRotatingArc(
            color: Apptheme.ivory,
            size: 45,
          ),
        ));
  }
}
