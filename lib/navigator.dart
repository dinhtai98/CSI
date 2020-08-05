import 'package:flutter/material.dart';

class NavigatorStateFromKeyOrContext extends InheritedWidget {
  const NavigatorStateFromKeyOrContext({
    Key key,
    @required this.navigatorKey,
    @required Widget child,
  }) : super(key: key, child: child);

  final GlobalKey<NavigatorState> navigatorKey;

  static GlobalKey<NavigatorState> getKey(BuildContext context) {
    final NavigatorStateFromKeyOrContext provider =
    context.inheritFromWidgetOfExactType(NavigatorStateFromKeyOrContext);
    return provider.navigatorKey;
  }

  static NavigatorState of(BuildContext context) {
    NavigatorState state;
    try {
      state = Navigator.of(context);
    } catch (e) {
      // Assertion error thrown in debug mode, in release mode no errors are thrown
      print(e);
    }
    if (state != null) {
      // state can be null when context does not include a Navigator in release mode
      return state;
    }
    final NavigatorStateFromKeyOrContext provider =
    context.inheritFromWidgetOfExactType(NavigatorStateFromKeyOrContext);
    return provider.navigatorKey?.currentState;
  }

  @override
  bool updateShouldNotify(NavigatorStateFromKeyOrContext oldWidget) {
    return navigatorKey != oldWidget.navigatorKey;
  }
}