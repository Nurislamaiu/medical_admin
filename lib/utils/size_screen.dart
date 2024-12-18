import 'package:flutter/widgets.dart';

class ScreenSize {
  final BuildContext context;

  ScreenSize(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  double percentWidth(double percent) => width * percent / 100;
  double percentHeight(double percent) => height * percent / 100;
}
