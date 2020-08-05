import 'dart:convert';
import 'package:flutter_helloworld/queries/mortality.dart';
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


class DialogRecordMortality extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogRecordMortalityState();
  }
}
class DialogRecordMortalityState extends State<DialogRecordMortality> {
  TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);

  Future<Data> getUser = DataUser.getDataUser();
  String idSub, idStaff;
  var txtDate = new TextEditingController(),txtSign = new TextEditingController();

  int _radio = -1;
  void _handleRadio(int value) {
    setState(() {
      _radio = value;
    });
  }

  _recordMortality(BuildContext context) async {

    if(txtDate.text.toString().length != 0 && _radio != -1) {
      String date = function.convertDefaultToDateCSDL(txtDate.text.toString()),
      sign = txtSign.text.toString();
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Mortality.queryRecordMortalityBroodStock(
              idSub,
              date,
              sign,
              _radio,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ViewsWidget.buildInputRow(context, txtSign, 'sign_of_diseases', 'hint_sign_of_diseases', themeData),
                ViewsWidget.buildRadioYesOrNo(context, _radio, _handleRadio, 'collecting_sample', themeData),
                ViewsWidget.selectDateTimePicker(context, txtDate, 'detect_date', themeData),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ViewsWidget.buildButtonDismiss(context,'cancel'),
                    ViewsWidget.buildButtonAction(context,'save', _recordMortality)
                  ],
                ),
              ],
            )
          ),
      )

    );
  }
}