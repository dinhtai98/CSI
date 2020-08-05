import 'dart:convert';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:postgres/postgres.dart';

class DialogAblation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogAblationState();
  }
}
class DialogAblationState extends State<DialogAblation> {
  TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);

  Future<Data> getUser = DataUser.getDataUser();
  List<String> getData;
  String idSub, idStaff,ablationTime, ablationStaff;
  var txtDate = new TextEditingController();

  void executeAblation(BuildContext context) async {

    if(txtDate.text.toString().length != 0) {
      String date = function.convertDefaultToDateCSDL(txtDate.text.toString());
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Broodstock.queryAblating(
              idSub,
              date,
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
      } else {
        Toast.show(Translations.of(context).text('error'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser.then((onValue){
      setState(() {
        idStaff = onValue.att10.toString();
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    getData = InheritedProvider.of<List<String>>(context);
    idSub = getData[0];
    ablationTime = getData[1];
    ablationStaff = getData[2];
    // TODO: implement build
    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: SingleChildScrollView(
          child: Container(
              width: 300.0,
              child: ablationTime.toString() != "null" ?
              infoAblation(context) : inputAblation(context)
          ),
        )

    );
  }
  Widget infoAblation(BuildContext context){
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(context,'ablation'),
          ViewsWidget.buildRowDetails(context,'date','${function.convertDateCSDLToDateTimeDefault(ablationTime)}'),
          ViewsWidget.buildRowDetails(context,'staff',ablationStaff)
        ]
    );
  }
  Widget inputAblation(BuildContext context){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(context,'ablation'),
          ViewsWidget.selectDateTimePicker(context, txtDate, 'recorded_date', themeData),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ViewsWidget.buildButtonDismiss(context,'cancel'),
              ViewsWidget.buildButtonAction(context,'save', executeAblation)

            ],
          ),
        ]
    );
  }
}