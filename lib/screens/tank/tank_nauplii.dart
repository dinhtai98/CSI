import 'dart:convert';
import 'package:flutter_helloworld/dialog/dialog_record_metamorphosis.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/screens/nauplii/list_salinity.dart';
import 'package:flutter_helloworld/screens/tank/tank_postlarvea.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import '../../translations.dart';

class TankNauplii extends StatefulWidget {
  Function callback;
  String idSub,checkPostlarvea;
  TankNauplii(this.callback,this.idSub,this.checkPostlarvea);
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TankNaupliiState();
  }
}
class TankNaupliiState extends State<TankNauplii> {
  String idSub;
  double numZ1, numZ2, numZ3, numM1, numM2, numM3, numP1;
  String percentZ1, percentZ2, percentZ3, percentM1, percentM2, percentM3, percentP1;
  int numNauplii = -1;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTankNauplii(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Nauplii.queryGetSubBatchOfNauplii(idSub)),
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

  AsyncMemoizer<Map<String, Data>> memCacheStages = AsyncMemoizer();
  Future<Map<String, Data>> _getInfoStagesNauplii(String idSub) async{
    return memCacheStages.runOnce(() async {
      Map<String, Data> stages = new Map();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Nauplii.queryInfoStagesOfNaplii(idSub)),
          encoding: Encoding.getByName("UTF-8")
      );

      Data data = new Data();
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (dynamic item in jsonData) {
        data = Data.fromJson(item);
        stages[data.att1] = data;
      }

      return stages;
    });
  }

  _recordMetamorphosis(BuildContext context, String label){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<List<String>>(
          child: new DialogRecordMetamorphosis(),
          inheritedData: [idSub,label, numNauplii.toString()],
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        memCacheStages = AsyncMemoizer();
        if(onValue != null) {
          String returnStage = onValue[0], returnResult = onValue[1];
          if (returnStage.toString() == "P1" && returnResult.toString() == "1") {
            this.widget.callback(
                new TankPostlarvea(this.widget.callback, idSub));
          }
        }
      });

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      idSub = widget.idSub;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('tank_nauplii')
            , style: themeData.primaryTextTheme.caption),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future:_getTankNauplii(idSub),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                      memCacheStages = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data sub = snapshot.data;
                  numNauplii = int.parse(sub.att1.toString());
                  return new Column(
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context,'species', Translations.of(context).text("nauplii")),
                            ViewsWidget.buildRowDetails(context,'number_of_nauplii', '${function.formatNumber(sub.att1)}'),
                            ViewsWidget.buildRowDetails(context,'assign_tank_date', '${function.convertDateCSDLToDateTimeDefault(sub.att2)}'),
                            ViewsWidget.buildRowDetails(context,'expected_harvest_date', '${function.convertDateCSDLToDateTimeDefault(sub.att3)}'),
                          ],
                        ),
                      ),
                      ViewsWidget.buildRowAction(context,'salinity',_onTapSalinity,
                          Image.asset("assets/images/icon_salinity.png", width: 30,height: 30,color: Colors.blue)),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: FutureBuilder(
                            future:_getInfoStagesNauplii(idSub),
                            builder: (BuildContext context, AsyncSnapshot snapshotStages) {
                              if(snapshotStages.hasError){
                                return ViewsWidget.buildNoInternet(context,(){
                                  setState(() {
                                    memCacheStages = AsyncMemoizer();
                                    build(context);
                                  });
                                });
                              }else if(snapshotStages.hasData){
                                Data z1 = snapshotStages.data["Z1"];
                                Data z2 = snapshotStages.data["Z2"];
                                Data z3 = snapshotStages.data["Z3"];
                                Data m1 = snapshotStages.data["M1"];
                                Data m2 = snapshotStages.data["M2"];
                                Data m3 = snapshotStages.data["M3"];
                                Data p1 = snapshotStages.data["P1"];
                                if(z1.att2.toString() != "null"){
                                  numZ1 = double.parse(z1.att3.toString());
                                  percentZ1 = function.formatpercentage((numZ1/numNauplii) * 100);
                                }
                                if(z2.att2.toString() != "null"){
                                  numZ2 = double.parse(z2.att3.toString());
                                  percentZ2 = function.formatpercentage((numZ2/numNauplii) * 100);
                                }
                                if(z3.att2.toString() != "null"){
                                  numZ3 = double.parse(z3.att3.toString());
                                  percentZ3 = function.formatpercentage((numZ3/numNauplii) * 100);
                                }
                                if(m1.att2.toString() != "null"){
                                  numM1 = double.parse(m1.att3.toString());
                                  percentM1 = function.formatpercentage((numM1/numNauplii) * 100);
                                }
                                if(m2.att2.toString() != "null"){
                                  numM2 = double.parse(m2.att3.toString());
                                  percentM2 = function.formatpercentage((numM2/numNauplii) * 100);
                                }
                                if(m3.att2.toString() != "null"){
                                  numM3 = double.parse(m3.att3.toString());
                                  percentM3 = function.formatpercentage((numM3/numNauplii) * 100);
                                }
                                int curStage = 1;
                                if(m3.att2.toString() != "null"){
                                  curStage = 6;
                                }else if(m2.att2.toString() != "null")
                                  curStage = 5;
                                else if(m1.att2.toString() != "null")
                                  curStage = 4;
                                else if(z3.att2.toString() != "null")
                                  curStage = 3;
                                else if(z2.att2.toString() != "null")
                                  curStage = 2;
                                return Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(Translations.of(context).text('process_metamorphosis'), style: themeData.primaryTextTheme.display1,)
                                        ],
                                      ),
                                    ),
                                    z1.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'Z1',
                                        '${function.formatNumber(z1.att3)} ($percentZ1%)',
                                        '${function.convertDateCSDLToDateTimeDefault(z1.att4.toString())}') : (
                                        curStage > 1 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'Z1') :
                                        buildInputMetamorphosis(context, 'Z1')
                                    ),
                                    z2.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'Z2',
                                        '${function.formatNumber(z2.att3)} ($percentZ2%)',
                                        '${function.convertDateCSDLToDateTimeDefault(z2.att4)}') : (
                                        curStage > 2 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'Z2') :
                                        buildInputMetamorphosis(context, 'Z2')
                                    ),
                                    z3.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'Z3',
                                        '${function.formatNumber(z3.att3)} ($percentZ3%)',
                                        '${function.convertDateCSDLToDateTimeDefault(z3.att4)}') : (
                                        curStage > 3 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'Z3') :
                                        buildInputMetamorphosis(context, 'Z3')
                                    ),
                                    m1.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'M1',
                                        '${function.formatNumber(m1.att3)} ($percentM1%)',
                                        '${function.convertDateCSDLToDateTimeDefault(m1.att4)}') : (
                                        curStage > 4 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'M1') :
                                        buildInputMetamorphosis(context, 'M1')
                                    ),
                                    m2.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'M2',
                                        '${function.formatNumber(m2.att3)} ($percentM2%)',
                                        '${function.convertDateCSDLToDateTimeDefault(m2.att4)}') : (
                                        curStage > 5 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'M2') :
                                        buildInputMetamorphosis(context, 'M2')
                                    ),
                                    m3.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'M3',
                                        '${function.formatNumber(m3.att3)} ($percentM3%)',
                                        '${function.convertDateCSDLToDateTimeDefault(m3.att4)}') : (
                                        curStage > 6 ? ViewsWidget.buildRowMissingMetamorphosis(context, 'M3') :
                                        buildInputMetamorphosis(context, 'M3')
                                    ),
                                    p1.att2.toString() != "null" ?
                                    ViewsWidget.buildInfoMetamorphosis(context, 'P1',
                                        '${function.formatNumber(p1.att3)}',
                                        '${function.convertDateCSDLToDateTimeDefault(p1.att4)}') : (
                                        buildInputMetamorphosis(context, 'P1')
                                    ),
                                  ],
                                );
                              }
                              return new Center(
                                  child: CircularProgressIndicator());
                            })
                      ),
                    ],
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      )
    );
  }
  buildInputMetamorphosis(BuildContext context, String label){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('$label',style: themeData.primaryTextTheme.display1),
          ),
          Expanded(
            flex: 9,
              child: IconButton(
                padding: new EdgeInsets.all(0.0),
                color: themeData.primaryColor,
                icon: new Icon(Icons.edit,color: kColorBackground,size: 26.0),
                onPressed: () {
                  _recordMetamorphosis(context,label);
                },
              )
          )
        ],
      ),
    );
  }
  _onTapSalinity(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new ListOfSalinity(),
              inheritedData: idSub,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
        memCacheStages = AsyncMemoizer();
      });
    });
  }
}
