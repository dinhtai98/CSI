import 'dart:convert';
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


class DialogRecordSalinity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogRecordSalinityState();
  }
}
class DialogRecordSalinityState extends State<DialogRecordSalinity> {
  TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);

  Future<Data> getUser = DataUser.getDataUser();
  String idSub, idStaff;

  var txtStartTime = new TextEditingController(), txtCompletionTime = new TextEditingController()
  , txtInitial = new TextEditingController(), txtTarget= new TextEditingController();

  _recordSalinity(BuildContext context) async {

    if(txtStartTime.text.toString().length != 0 && txtCompletionTime.text.toString().length != 0 &&
        txtInitial.text.toString().length != 0 && txtTarget.text.toString().length != 0) {
      String initial = txtInitial.text.toString(),
      target = txtTarget.text.toString(),
      startDate = function.convertDefaultToDateCSDL(txtStartTime.text),
      completionDate = function.convertDefaultToDateCSDL(txtCompletionTime.text);
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Nauplii.queryRecordSalinity(
              idSub,
              initial,target,startDate, completionDate,
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
      idSub = InheritedProvider.of<String>(context);
    // TODO: implement build
    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: SingleChildScrollView(
          child: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    child: Text(Translations.of(context).text('initial_salinity'),
                      style: themeData.primaryTextTheme.display4,),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        style: themeData.primaryTextTheme.display3,
                        controller: txtInitial,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: Translations.of(context).text('hint_initial_salinity'),
                          border: InputBorder.none,
                        ),
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    child: Text(Translations.of(context).text('targer_salinity'),
                      style: themeData.primaryTextTheme.display4,),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        style: themeData.primaryTextTheme.display3,
                        controller: txtTarget,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: Translations.of(context).text('hint_targer_salinity'),
                          border: InputBorder.none,
                        ),
                      )
                  ),
                  ViewsWidget.selectDateTimePicker(context, txtStartTime, 'start_time', themeData),
                  ViewsWidget.selectDateTimePicker(context, txtCompletionTime, 'completion_time', themeData),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ViewsWidget.buildButtonDismiss(context,'cancel'),
                      ViewsWidget.buildButtonAction(context,'save', _recordSalinity)
                    ],
                  ),
                ],
              )
          ),
        )

    );
  }
}