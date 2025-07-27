import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppState {
  final Map<String, dynamic> appLayout;
  final String? loaded;

  AppState({ required this.appLayout, this.loaded });

  AppState copyWith({ Map<String, dynamic>? appLayout, String? loaded}) {
    return AppState(
      appLayout: appLayout ?? this.appLayout,
      loaded: loaded ?? this.loaded,
    );
  }
}

class AppStateScope extends InheritedWidget {
  final AppState data;
  AppStateScope(this.data, {
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.data;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return !mapEquals(data.appLayout, oldWidget.data.appLayout) ||
           data.loaded != oldWidget.data.loaded;
  }
}

class AppStateWidget extends StatefulWidget {
  final Map<String, dynamic> appLayout;
  final String? loaded;
  final Widget child;

  AppStateWidget({
    Key? key,
    required this.appLayout,
    this.loaded,
    required this.child,
  }) : super(key: key);

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}


class AppStateWidgetState extends State<AppStateWidget> {
  late AppState _data;

  @override
  void initState() {
    super.initState();
    _data = AppState(
      appLayout: this.widget.appLayout,
      loaded: this.widget.loaded,
    );
  }

  void setAppState(Map<String, dynamic> newAppLayout, String newLoaded) {
    if (_data.appLayout != newAppLayout || _data.loaded != newLoaded) {
      setState(() {
        _data = _data.copyWith(
          appLayout: newAppLayout,
          loaded: newLoaded,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(_data, child: widget.child);
  }
}
