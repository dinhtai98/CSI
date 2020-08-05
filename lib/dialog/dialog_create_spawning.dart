import 'package:flutter/material.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:toast/toast.dart';
import '../translations.dart';
import 'package:postgres/postgres.dart';
class DialogCreateSpawning extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogCreateSpawningState();
  }
}
class DialogCreateSpawningState extends State<DialogCreateSpawning> {
  String idSub, idStaff;

  TextEditingController txtName = new TextEditingController(), txtNum = new TextEditingController(),
      txtDate = new TextEditingController();
  _createSpawning(BuildContext context) async {

    if(txtName.text.toString().length != 0 && txtNum.text.toString().length != 0 &&
        txtDate.text.length != 0) {
      int num = int.parse(txtNum.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String date = function.convertDefaultToDateCSDL(txtDate.text),
      name = txtName.text.toString();
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Broodstock.queryCreateSpawning(
              name,
              idSub,
              date,
              num,
              idStaff)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      if (result.contains("1")) {
        Toast.show(Translations.of(context).text('saved'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  @override
  Widget build(BuildContext context) {
    List<String> getData = InheritedProvider.of<List<String>>(context);
    idSub = getData[0];
    idStaff = getData[1];
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
        appBar: new AppBar(title: Text(Translations.of(context).text('create_spawning'),
        style: themeData.primaryTextTheme.caption),),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ViewsWidget.buildInputRow(context, txtName,'spawning', 'hint_spawning',themeData ),
            ViewsWidget.buildInputNumberRow(context, txtNum ,'number_of_nauplii','hint_number_of_nauplii', themeData),
            ViewsWidget.selectDateTimePicker(context, txtDate ,'spawning_time', themeData),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  width: 120,
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color(0xff01A0C7),
                    child: MaterialButton(
                      //minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: (){
                        _createSpawning(context);
                      },
                      child: Text(Translations.of(context).text('save'),
                          textAlign: TextAlign.center,
                          style: themeData.primaryTextTheme.button),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

}