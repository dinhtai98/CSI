import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/colors.dart';

ThemeData buildPrimaryThemeData(BuildContext context) {
  return Theme.of(context).copyWith(
      primaryColor: kColorPrimary,
      primaryColorDark: kColorPrimaryDark,
      accentColor: kColorAccentColor,
      primaryIconTheme: IconThemeData(
        color: kColorIcon
      ),
      primaryTextTheme: TextTheme(
        title: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.white
        ),
        subtitle: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 14.0,
            color: kColorText
        ),
        headline: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 30.0,
            fontWeight: FontWeight.w400,
            color: kColorText
        ),
        subhead: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 12.0,
            wordSpacing: 3,
            color: kColorSecondaryText
        ),
        caption: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 20.0,
            //fontWeight: FontWeight.w200,
            color: kColorWhite
        ),
        // item
        display1: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: kColorText
        ),
        display2: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 14.0,
            color: kColorText
        ),
        display3: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 14.0,
            wordSpacing: 3.0,
            color: kColorSecondaryText
        ),
        display4: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: kColorSecondaryText
        ),
        overline: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            color: kColorText
        ),
        button: TextStyle(
            fontFamily: 'Google sans',
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.white
        ),
      )
  );
}