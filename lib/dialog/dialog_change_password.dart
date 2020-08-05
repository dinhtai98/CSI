import 'dart:convert';
import 'package:flutter_helloworld/queries/admin.dart';
import 'package:flutter_helloworld/queries/login.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:postgres/postgres.dart';
class DialogChangePassword extends StatefulWidget {
  BuildContext ctx;
  int checkAdmin;
  DialogChangePassword({this.ctx,this.checkAdmin});
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogChangePasswordState();
  }
}
class DialogChangePasswordState extends State<DialogChangePassword> {
  int flag = 1;
  Data data;
  String error = "";

  var txtMKHienTai = new TextEditingController(),txtMKMoi = new TextEditingController(),
      txtNhapLaiMKMoi = new TextEditingController();

  _executeChangePassword(BuildContext context) async {
    flag = 1;
    FocusScope.of(context).requestFocus(FocusNode());
    var passMD5 = function.generateMd5(txtMKHienTai.text.toString());
    if(passMD5 == data.att7.toString()){
      if(txtMKMoi.text.length != 0 && txtNhapLaiMKMoi.text.length != 0){
        if(txtMKMoi.text.length >= 6 && txtNhapLaiMKMoi.text.length >= 6){
          if(txtMKMoi.text.toString() == txtNhapLaiMKMoi.text.toString()){
            String newPass = function.generateMd5(txtMKMoi.text.toString());
            //var passMD5 = function.generateMd5(txtMKHienTai.text.toString());
            String query = '';
            if(widget.checkAdmin == 1){
              query = Admin.queryChangePassword(data.att10.toString(), passMD5, newPass);
            }else{
              query = QueryLogin.queryChangePassword(data.att10.toString(), passMD5, newPass);
            }
            http.Response response = await http.post(
                Api.url_update,
                headers: {
                  "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
                  "Content-Type": "application/x-www-form-urlencoded",
                  "cache-control": "no-cache"
                },
                body: utf8.encode(query),
                encoding: Encoding.getByName("UTF-8")
            );
            var p = response.body.indexOf(">");
            var e = response.body.lastIndexOf("<");
            var result = response.body.substring(p + 1, e);
            if (result.contains("1")) {
              data.att7 = newPass;
              Data newData = data;
              setSharePreference(newData.toJson());
              Toast.show('Đổi mật khẩu thành công', context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              Navigator.pop(context);
            }else{
              flag = 0;
              error = Translations.of(context).text('error');
            }
          }else{
            flag = 0;
            error = Translations.of(context).text('you_must_enter_the_same_password_twice_inorderto_confirm_it');
          }
        }else{
          flag = 0;
          error = Translations.of(context).text('password_must_be_at_least_6_characters_long');
        }
      }else{
        flag = 0;
        error = Translations.of(context).text('you_cannot_use_a_blank_password');
      }
    }else{
      flag = 0;
      error = Translations.of(context).text('your_password_was_incorrect');
    }
    if(flag == 0){
      setState(() {
        txtMKHienTai.text = '';
        txtMKMoi.text = '';
        txtNhapLaiMKMoi.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
    data = InheritedProvider.of<Data>(context);
    data.att9 = "1";
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
          title:
        Text(Translations.of(context).text('change_password'),
          style: themeData.primaryTextTheme.caption,),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
              ),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Text(error, style: notOk),
                ),
                visible: flag == 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: TextField(
                    controller: txtMKHienTai,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: Translations.of(widget.ctx).text('current_password'),
                      //border:
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: TextField(
                    controller: txtMKMoi,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: Translations.of(widget.ctx).text('new_password'),
                      //border:
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: TextField(
                    controller: txtNhapLaiMKMoi,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: Translations.of(widget.ctx).text('retype_new_password'),
                      //border:
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: ViewsWidget.buildButtonAction(widget.ctx,'save', _executeChangePassword),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ViewsWidget.buildButtonDismiss(widget.ctx,'cancel'),
              )
            ]
        ),
      ),
    );
  }
  Future<bool> setSharePreference(dynamic jsonString) async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var user = json.encode(jsonString);
    return shared_User.setString('user', user);

  }
}