import 'dart:convert';
import 'package:flutter_helloworld/dialog/create_dialog_termination.dart';
import 'package:flutter_helloworld/dialog/dialog_ablation.dart';
import 'package:flutter_helloworld/screens/mortality/list_of_broodstock_mortality.dart';
import 'package:flutter_helloworld/screens/spawning/list_of_broodstock_spawning.dart';
import 'package:flutter_helloworld/screens/tank/tank_empty.dart';
import 'package:flutter_helloworld/screens/tank/tank_nauplii.dart';
import 'package:flutter_helloworld/screens/tank/tank_postlarvea.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import '../../translations.dart';
import '../../Data/ConvertDataList.dart';
import 'package:postgres/postgres.dart';
class TankBroodstock extends StatefulWidget {
  Function callback;
  String idSub;
  TankBroodstock(this.callback,this.idSub);
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TankBroodstockState();
  }
}
class TankBroodstockState extends State<TankBroodstock> {

  String idSub;
  String ablationTime, ablationStaff;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTankBroodstock(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Broodstock.queryGetTankOfBroodstock(idSub)),
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      idSub = widget.idSub.toString();
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);

    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: Text(Translations.of(context).text('tank_broodstock')
            , style: themeData.primaryTextTheme.caption),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future:_getTankBroodstock(idSub),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Data sub = snapshot.data;
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    memCache = AsyncMemoizer();
                    build(context);
                  });
                });
              }else if(snapshot.hasData){
                ablationTime = sub.att6;
                ablationStaff = sub.att7;
                return new Column(
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                      child: Column(
                        children: <Widget>[
                          ViewsWidget.buildRowDetails(context,'species', '${function.getSpecies(context,sub.att1)}'),
                          ViewsWidget.buildRowDetails(context,'type', '${function.getType(context,sub.att2)}'),
                          ViewsWidget.buildRowDetails(context,'number_of_male','${function.formatNumber(sub.att3)}'),
                          ViewsWidget.buildRowDetails(context,'number_of_female', '${function.formatNumber(sub.att4)}'),
                          ViewsWidget.buildRowDetails(context,'assign_tank_date', '${function.convertDateCSDLToDateTimeDefault(sub.att8)}'),
                        ],
                      ),
                    ),
                    ViewsWidget.buildRowAction(context,'ablation',_actionTapAblation,
                        Image.asset("assets/images/icon_ablation.png", width: 30,height: 30,)),
                    ViewsWidget.buildRowAction(context,'spawning',_actionTapSpawning,
                        Image.asset("assets/images/icon_spawning.png", width: 30,height: 30,color: Colors.blue)),
                    ViewsWidget.buildRowAction(context,'mortality',_actionTapMortality,
                        Image.asset("assets/images/icon_mortality.png", width: 30,height: 30,color: Colors.red)),
                    ViewsWidget.buildRowAction(context,'termination',_actionTapTermination,
                        Image.asset("assets/images/icon_termination.png", width: 30,height: 30,color: Colors.red))
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
  _actionTapMortality(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<String>(
          child: new ListOfBroodStockMortality(),
          inheritedData: idSub,
        ),
    )).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });
    });

  }
  _actionTapSpawning() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<String>(
          child: new ListOfBroodStockSpawning(),
          inheritedData: idSub,
        ),
    )).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
  _actionTapAblation() {
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<List<String>>(
          child: new DialogAblation(),
          inheritedData: [idSub, ablationTime, ablationStaff],
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });

    });
  }
  _actionTapTermination() {
    showDialog(
        context: context,
        builder: (_) =>
          InheritedProvider<String>(
            child: new DialogBroodstockTermination(),
            inheritedData: idSub,
          )
    ).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
        if(onValue != null) {
          String confirm = onValue[0];
          if (confirm.toString() == "1") {
            this.widget.callback(
                new TankEmpty(this.widget.callback));
          }
        }
      });
    });
  }


}