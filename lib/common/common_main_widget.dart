import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin CommonMainWidget {
  WillPopScope
  mainWidget(context, {required Widget child}) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: child,
    );
  }
}
