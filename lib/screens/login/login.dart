import 'dart:convert';
import 'package:flutter_helloworld/queries/coquanquanly.dart';
import 'package:flutter_helloworld/queries/login.dart';
import 'package:flutter_helloworld/queries/nguoilaodong.dart';
import 'package:flutter_helloworld/screens/CSSX/declare_hatchery.dart';
import 'package:flutter_helloworld/screens/CoQuanQL/declare_authority.dart';
import 'package:flutter_helloworld/screens/NguoiLaoDong/dangky_nguoilaodong.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/dah.dart';
import 'package:flutter_helloworld/queries/dard.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:postgres/postgres.dart';
import '../../translations.dart';
import '../home_screen.dart';

class Login extends StatefulWidget {

  int type;
  Login({this.type});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _MyLoginPageState();
  }

  // This widget is the root of your application.

}
class _MyLoginPageState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog pr;
  TextStyle style = TextStyle(fontStyle: FontStyle.normal,fontFamily: 'Google sans', fontSize: 20.0,color: Colors.white);
  TextEditingController  getEmail = new TextEditingController();
  TextEditingController  getPass = new TextEditingController();

  _attemptLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var _checkInternet = function.checkInternet();
    _checkInternet.then((onValue) async {
      if(onValue){
        Data data;
        var success = 0;
        pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
        pr.style(
          message: Translations.of(context).text('authenticating'),
        );
        pr.show();

        var passMD5 = function.generateMd5(getPass.text.toString());

        //List<String> stringQuery = [NguoiLaoDong.queryGetAllUser];
        String stringQuery = "";
        switch(widget.type){
        //queryLoginAdmin
          case 0:
            stringQuery = QueryLogin.queryLoginAdmin(getEmail.text.toString(), passMD5);
            break;
          case 1:
            stringQuery = QueryLogin.queryLoginCQQL(getEmail.text.toString(), passMD5);
            break;
          case 2:
            stringQuery = QueryLogin.queryLoginCSSX(getEmail.text.toString(), passMD5);
            break;
          case 3:
            stringQuery = QueryLogin.queryGetDVKB(getEmail.text.toString(), passMD5);
            break;
          case 4:
            stringQuery = QueryLogin.queryGetBuyer(getEmail.text.toString(), passMD5);
            break;
          case 5:
            stringQuery = QueryLogin.queryGetDNLD(getEmail.text.toString(), passMD5);
            break;
        }

        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(stringQuery),
            encoding: Encoding.getByName("UTF-8")
        );
        print("body: ${response.body}");
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p,e + 1);
        List<dynamic> list = json.decode(result);
        for(var k = 0 ; k < list.length; k++){
          data = Data.fromJson(list[k]);
          //_saveStorage(list[k]);
          setSharePreference(list[k]);
          Future.delayed(Duration(seconds: 3)).then((value) {
            pr.hide().whenComplete(() {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) =>
                  MyHome(data: data,)), (Route<dynamic> route) => false);
              success = 1;
            });
          });
          //Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
          //Navigator.pushReplacement(context,
          //MaterialPageRoute(builder: (BuildContext ctx) => MyHome(data: data,)));
          return;
        }
        if (success == 0) {
          Future.delayed(Duration(seconds: 3)).then((value) {
            pr.hide().whenComplete(() {
              Toast.show(
                  Translations.of(context).text('user_pass_incorrect'), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            });
          });
        }
      }else{
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(Translations.of(context).text('no_internet')),
              duration: Duration(seconds: 1),
            ));
      }
    });
  }
  /*_saveStorage(dynamic jsonString) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'user', value: jsonString);

  }*/

  Future<bool> setSharePreference(dynamic jsonString) async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var user = json.encode(jsonString);
    return shared_User.setString('user', user);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    getEmail.dispose();
    getPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData themeData = buildPrimaryThemeData(context);

    final emailField = Container(
      width: MediaQuery.of(context).size.width / 1.2,
      child: TextField(
        cursorColor: Colors.white,
        controller: getEmail,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
            hintText: Translations.of(context).text('username'),
            hintStyle: style,
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            prefixIcon: new Icon(Icons.account_circle,color: Colors.white,),
            focusedBorder:  OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white ,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white ,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(6))),
        ),
      ),
    );
    final passwordField = Container(
      width: MediaQuery.of(context).size.width / 1.2,
      child: new TextField(
        cursorColor: Colors.white,
        obscureText: true,
        controller: getPass,
        style: style,
        decoration: InputDecoration(
            hintText: Translations.of(context).text('password'),
            hintStyle: style,
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            prefixIcon:  new Icon(Icons.lock_outline,color: Colors.white,),
            focusedBorder:  OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white ,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white ,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(6))),
        ),
      ),
    );

    final forgotPassword = FlatButton(
        onPressed: _launchURLForgotPassword,
        child: Text(
          Translations.of(context).text('forgot_password'),
          style: themeData.primaryTextTheme.overline,
        ));
    final loginButon = Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
          ),
          color: Color(0xFF00bfa5),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2F4F4F),
              offset: const Offset(3.0, 3.0),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            )
          ]
      ),
      child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width / 1.8,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            _attemptLogin();
          },
          child: Text(Translations.of(context).text('login'),
              textAlign: TextAlign.center,
              style: themeData.primaryTextTheme.button
          )
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new Container(
                //alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  color: kColorBackground,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/images/background.jpg",fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                          height: 200,),
                        SizedBox(height: 45.0),
                        emailField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(
                          height: 35.0,
                        ),
                        loginButon,
                        SizedBox(height: 100.0),
                        Column(
                          children: <Widget>[
                            Image.asset("assets/images/logo_csiro.png",fit: BoxFit.cover,
                              width: 80,height: 80,),
                            Text("Exclusively licensed to Directorate of Fisheries of Vietnam\nAll rights reserved @ CSIRO",
                              style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.grey[200]),textAlign: TextAlign.center,),
                          ],
                        )
                      ],
                    ),
                  )
              )
          ),
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back,color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }
  _launchURLForgotPassword() async {
    const url = 'http://www.tomgiongvn.vn/home/forgotpassword';
    if (await canLaunch(url)) {
      print('lauch');
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

