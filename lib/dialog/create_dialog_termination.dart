import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/queries/termination.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';

import '../translations.dart';
import 'dialog_input_transportation_information.dart';



class DialogBroodstockTermination extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogBroodstockTerminationState();
  }
}
class DialogBroodstockTerminationState extends State<DialogBroodstockTermination> {
  String idSub,idTer,idStaff, idHatchery;
  Future<Data> getUser = DataUser.getDataUser();

  TextEditingController txtReason = new TextEditingController(), txtDate = new TextEditingController();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTermationOfSubBatch(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Termination.queryGetTerminationOfBroodStockSub(idSub)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data ter = new Data();
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        ter = Data.fromJson(jsonData[0]);
        return ter;
      }else {
        throw("");
      }
    });
  }

  Data _curStaffDARD;
  List<DropdownMenuItem<Data>> _dropDownStaffDARD = List();
  AsyncMemoizer<List<dynamic>> memCacheStaffDARD = AsyncMemoizer();

  Future<List<dynamic>> _getStaffDARDBelongHatchery(String idHatchery) async{

    List<dynamic> list = List();
    return memCacheStaffDARD.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Termination.queryGetAllDARDStaffOfHatchery(idHatchery)),
          encoding: Encoding.getByName("UTF-8")
      );
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic item in jsonData) {
          list.add(item);
        }
        _listDropdownMenuStaffDARD(list);
        return list;
      }
      throw("");
    });
  }
  _listDropdownMenuStaffDARD(List<dynamic> list){

    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownStaffDARD.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      _curStaffDARD = _dropDownStaffDARD[0].value;
      //_getAllTankOfCluster(_currentClus.att1);
    });

    //setState(() {
    //});

  }
  void changedDropDownStaffDARD(Data selectedStaffDARD) {
    setState(() {
      _curStaffDARD = selectedStaffDARD;
    });

  }

  _executeTerminationBroodstock(BuildContext context) async {

    if(txtDate.text.toString().length != 0) {

      String idStaffDARD = _curStaffDARD.att1;

      String reason = txtReason.text.toString(),
          date = function.convertDefaultToDateCSDL(txtDate.text);

      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Termination.executeTerminationBroodstockSubBatch(
              idTer,idSub, idStaff,idStaffDARD ,reason,date)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);

      if (result.contains("1")) {
        Toast.show(Translations.of(context).text('saved'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context,["1"]);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  @override
  void initState() {
    super.initState();
    getUser.then((onValue){
      setState(() {
        idStaff = onValue.att1;
        idHatchery = onValue.att7;
      });
    });
  }
  int initial = 0;
  @override
  Widget build(BuildContext context) {
    idSub = InheritedProvider.of<String>(context);

    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('terminaton'),
            style: themeData.primaryTextTheme.caption),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _getTermationOfSubBatch(idSub),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                      build(context);
                    });
                  });
                } else if (snapshot.hasData) {
                  Data termination = snapshot.data;
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'plan_date', '${function.convertDateCSDLToDateTimeDefault(termination.att3)}'),
                      ViewsWidget.buildRowDetails(context,'number_of_male_plan', '${function.formatNumber(termination.att5)}'),
                      ViewsWidget.buildRowDetails(context,'number_of_female_plan', '${function.formatNumber(termination.att6)}'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Container(
                          height: 1.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                      ViewsWidget.buildInputRow(context, txtReason ,'cull_reason','input_cull_reason', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtDate,'cull_date', themeData),
                      FutureBuilder(
                          future: _getStaffDARDBelongHatchery(idHatchery),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if(snapshot.data == null){
                              return new Center(
                                child: Text('Loading'),
                              );
                            }else{
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Text(Translations.of(context).text('dard_staff'),
                                              style: themeData.primaryTextTheme.display4),
                                        ),
                                        ViewsWidget.buildDropDownList(
                                            _dropDownStaffDARD, _curStaffDARD, changedDropDownStaffDARD,themeData),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ViewsWidget.buildButtonAction(context,'confirm', _executeTerminationBroodstock)
                        ],
                      ),
                    ],
                  );
                }
                return new Center(child: CircularProgressIndicator());
              })
      ),
    );
  }

}
