import 'package:flutter/material.dart';

class AppState {
  final Map<String, dynamic> appLayout;

  AppState({ required this.appLayout });

  AppState copyWith({ Map<String, dynamic>? appLayout }) {
    return AppState(appLayout: appLayout ?? this.appLayout);
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
    return data == oldWidget.data;
  }
}

class AppStateWidget extends StatefulWidget {
  final Map<String, dynamic> appLayout;
  final Widget child;

  AppStateWidget({
    Key? key,
    required this.appLayout,
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
    _data = AppState(appLayout: this.widget.appLayout);
  }

  void setAppLayout(Map<String, dynamic> newAppLayout) {
    if (_data.appLayout != newAppLayout) {
      setState(() {
        _data = _data.copyWith(appLayout: newAppLayout);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(_data, child: widget.child);
  }
}
