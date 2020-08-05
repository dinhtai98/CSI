import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/views/view.dart';

import '../../main.dart';

class SuccessSignup extends StatefulWidget {
  String username;
  int typeSignup;
  SuccessSignup({this.username, this.typeSignup});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SuccessSignupState();
  }

// This widget is the root of your application.

}
class _SuccessSignupState extends State<SuccessSignup> {

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return Material(
      child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('ĐĂNG KÝ THÀNH CÔNG',style:themeData.primaryTextTheme.subtitle, )
                ),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Thông tin tài khoản',style:themeData.primaryTextTheme.display3,)
                ),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Tên tài khoản: ',style:themeData.primaryTextTheme.display4,),
                        Text('${widget.username}',style:themeData.primaryTextTheme.headline,)
                      ],
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Mật khẩu: ',style:themeData.primaryTextTheme.display4,),
                        Text('123456',style:themeData.primaryTextTheme.headline,)
                      ],
                    )
                ),
                SizedBox(height: 30,),
                ViewsWidget.buildBigButtonAction(context,'confirm',(context){
                  if(widget.typeSignup != 1){
                    /* Loi duplicate key
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        MyApp(user: null,)), (Route<dynamic> route) => false);
                     */

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => MyLoginPage()));
                  }else{
                    Navigator.of(context).pop();
                  }
                })
              ],
            ),
          )
      ),
    );
  }

}