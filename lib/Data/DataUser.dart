import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Data.dart';

class DataUser{

  static Future<Data> getDataUser() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    Map userMap = jsonDecode(sharedUser.getString('user'));
    Data user = Data.fromJson(userMap);
    return user;
  }
}
