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


class DialogRecordMetamorphosis extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogRecordMetamorphosisState();
  }
}
class DialogRecordMetamorphosisState extends State<DialogRecordMetamorphosis> {
  TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);

  Future<Data> getUser = DataUser.getDataUser();
  List<String> getData;
  String idSub, stage, idStaff;
  int minNum = -1;
  var txtDate = new TextEditingController(), txtNum = new TextEditingController();

  AsyncMemoizer<String> memCache = AsyncMemoizer();
  Future<String> _getMiOfMetamorphosis(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Nauplii.queryGetMinNumOfMetamorphosis(idSub)),
          encoding: Encoding.getByName("UTF-8")
      );

      Data data = new Data();
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      data = Data.fromJson(jsonData[0]);
      return data.att1.toString();
    });
  }

  _recordMetamorphosis(BuildContext context) async {

    if(txtDate.text.toString().length != 0 && txtNum.text.toString().length != 0) {
      int num = int.parse(txtNum.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String date = function.convertDefaultToDateCSDL(txtDate.text.toString());
      print('date ${date}');
      if(num <= minNum) {
        http.Response response = await http.post(
            Api.url_update,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Nauplii.queryRecordStageMetamorphosis(
                idSub,
                stage,
                "",
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
          Navigator.pop(context, [stage,result]);
        } else {
          Toast.show(Translations.of(context).text('error'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }else{
        Toast.show('${Translations.of(context).text('you_have_just')} '
            '${function.formatNumber(minNum.toString())} '
            '${Translations.of(context).text('nauplii')}',
            context,
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
  int initial = 0;
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    if(initial == 0){
      getData = InheritedProvider.of<List<String>>(context);
      idSub = getData[0];
      stage = getData[1];
      minNum = int.parse(getData[2]);
      initial = 1;
    }

    // TODO: implement build
    return  AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      contentPadding: EdgeInsets.only(top: 0.0),
      content: SingleChildScrollView(
          child: Container(
            width: 300.0,
            child: FutureBuilder(
              future: _getMiOfMetamorphosis(idSub),
                builder:(BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasError){
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                        build(context);
                      });
                    });
                  }else if(snapshot.hasData){
                    if(snapshot.data.toString() != "null")
                      minNum = int.parse(snapshot.data.toString());
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ViewsWidget.buildRowDetails(context,'stage',stage),
                        //ViewsWidget.buildInputNumberRow(context,num,'number_of_metamorphosis','hint_number_of_metamorphosis',themeData),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                          child: Text(Translations.of(context).text('number_of_metamorphosis'),
                            style: themeData.primaryTextTheme.display4,),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              style: themeData.primaryTextTheme.display3,
                              controller: txtNum,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                new NumericTextFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: Translations.of(context).text('hint_number_of_metamorphosis'),
                                border: InputBorder.none,
                              ),
                            )
                        ),
                        ViewsWidget.selectDateTimePicker(context, txtDate, 'recorded_date', themeData),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ViewsWidget.buildButtonDismiss(context,'cancel'),
                            ViewsWidget.buildButtonAction(context,'save', _recordMetamorphosis)
                          ],
                        ),
                      ],
                    );
                  }
                  return new Center(
                      child: CircularProgressIndicator());
                }
            )
          ),
      )

    );
  }
}