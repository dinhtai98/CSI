import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/mortality.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class MortalityDetails extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new MortalityDetailsState();
  }
}
class MortalityDetailsState extends State<MortalityDetails> {
  Future<Data> getUser = DataUser.getDataUser();

  String idMor,idStaff;
  var  txtMale = new TextEditingController();
  var  txtFemale = new TextEditingController();
  var  txtReason = new TextEditingController();
  var  txtDate = new TextEditingController();
  var  txtNote = new TextEditingController();
  int curMale,curFemale;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getMortality(String idMor) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Mortality.queryGetInFoOfBroodstockMortality(idMor)),
          encoding: Encoding.getByName("UTF-8")
      );
      Data data = new Data();
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      data = Data.fromJson(jsonData[0]);
      return data;
    });
  }
  _executeDiscard(BuildContext context) async {

    if(txtMale.text.toString().length != 0 && txtFemale.text.toString().length != 0 &&
        txtDate.text.toString().length != 0) {
      int male = int.parse(txtMale.text.replaceAll(new RegExp(r'[.,]+'),'').toString()),
      female = int.parse(txtFemale.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String date = function.convertDefaultToDateCSDL(txtDate.text);
      String reason = txtReason.text.toString(), note = txtNote.text.toString();
      if(male <= curMale && female <= curFemale && male > -1 && female > -1){
        http.Response response = await http.post(
            Api.url_update,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Mortality.queryBroodstockDiscard(
                idMor, male, female, reason, note, date, idStaff)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        if (result == "1") {
          Toast.show(Translations.of(context).text('saved'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }else{
          Toast.show(Translations.of(context).text('error'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }else{
        Toast.show('${Translations.of(context).text('you_have_just')} '
            '${function.formatNumber(curMale.toString())} '
            '${Translations.of(context).text('male')} & ${function.formatNumber(curFemale.toString())} '
            '${Translations.of(context).text('female')}',
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
      idStaff = onValue.att10.toString();
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idMor = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('mortality_details')),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _getMortality(idMor),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                } else if (snapshot.hasData) {
                  Data mortality = snapshot.data;
                  curMale = int.parse(mortality.att12.toString());
                  curFemale = int.parse(mortality.att13.toString());
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'sign_of_diseases', '${mortality.att3}'),
                      ViewsWidget.buildRowDetailsYesNo(context,'collecting_sample', '${mortality.att5.toString()}'),
                      ViewsWidget.buildRowDetails(context,'detect_date', '${function.convertDateCSDLToDateTimeDefault(mortality.att4)}'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Container(
                          height: 1.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                      mortality.att2.toString() == "null" ? notYetDiscard(context,themeData) : finishedDiscard(context,mortality,themeData)

                    ],
                  );
                }
                return new Center(child: CircularProgressIndicator());
              })
      ),
    );
  }
  Widget notYetDiscard(BuildContext context,ThemeData themeData){
    return Column(
      children: <Widget>[
        ViewsWidget.buildInputNumberRow(context, txtMale,'number_of_dead_male', 'hint_number_of_dead_male',themeData ),
        ViewsWidget.buildInputNumberRow(context, txtFemale,'number_of_dead_female', 'hint_number_of_dead_female',themeData ),
        ViewsWidget.buildInputRow(context, txtReason ,'reason','hint_reason', themeData),
        ViewsWidget.buildInputRow(context, txtNote ,'note','hint_note', themeData),
        ViewsWidget.selectDateTimePicker(context,txtDate,'discard_date', themeData),
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
                    _executeDiscard(context);
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
    );
  }
  Widget finishedDiscard(BuildContext context,Data data,ThemeData themeData){
    return Column(
      children: <Widget>[
        ViewsWidget.buildRowDetails(context,'number_of_dead_male', function.formatNumber(data.att10)),
        ViewsWidget.buildRowDetails(context,'number_of_dead_female', function.formatNumber(data.att11)),
        ViewsWidget.buildRowDetails(context,'reason', data.att8.toString() != "null" ? data.att8.toString() : ''),
        ViewsWidget.buildRowDetails(context,'note', data.att9.toString() != "null" ? data.att9.toString() : ''),
        ViewsWidget.buildRowDetails(context,'discard_date', function.convertDateCSDLToDateTimeDefault(data.att7)),
      ],
    );
  }
}