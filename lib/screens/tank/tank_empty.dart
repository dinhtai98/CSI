import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/theme_style.dart';

import '../../translations.dart';

class TankEmpty extends StatefulWidget {
  Function callback;

  TankEmpty(this.callback);
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TankEmptyState();
  }
}
class TankEmptyState extends State<TankEmpty> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
        title: Text(Translations.of(context).text('tank_details')
        , style: themeData.primaryTextTheme.caption),),
      body: Center(
        child: Text(Translations.of(context).text('empty'),
          style: new TextStyle(
          fontFamily: 'Google sans',
          fontSize: 22.0,
          color: Colors.black45,
        )),
      ),
    );
  }

}