import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_harvest_infomation.dart';
import 'package:flutter_helloworld/queries/postlarvea.dart';
import 'package:flutter_helloworld/screens/postlarvea/list_of_postlarvea_sell.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

import 'package:flutter_helloworld/screens/postlarvea/postlarvea_get_meta_history.dart';

class TankPostlarvea extends StatefulWidget {
  Function callback;
  String idSub;

  TankPostlarvea(this.callback,this.idSub);
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TankPostlarveaState();
  }
}
class TankPostlarveaState extends State<TankPostlarvea> {
  String idSub, idPrepostlarvea;
  int difference;
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTankPostlarvea(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Postlarvea.queryGetSubBatchOfPostLarvea(idSub)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data contract = new Data();
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        contract = Data.fromJson(jsonData[0]);
        return contract;
      }else {
        throw("");
      }
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
          title: Text(Translations.of(context).text('tank_postlarvea'),
            style: themeData.primaryTextTheme.caption,),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: _getTankPostlarvea(idSub),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                        //build(context);
                      });
                    });
                  } else if (snapshot.hasData) {
                    Data postlarvea = snapshot.data;
                    idPrepostlarvea = postlarvea.att3.toString();
                    DateFormat defaultDate = new DateFormat("yyyy-MM-dd hh:mm");
                    DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");
                    var dateHarvest = DateTime.parse('${defaultDate.format(defaultCSDL.parse(postlarvea.att2))}');
                    var dateCurrent = DateTime.now();
                    difference = dateCurrent.difference(dateHarvest).inDays + 1;
                    return Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context, 'species', Translations.of(context).text('postlarvea')),
                              ViewsWidget.buildRowDetails(context, 'number_of_postlarvea', '${function.formatNumber(postlarvea.att1)}'),
                              ViewsWidget.buildRowDetails(context, 'cur_stage_of_postlarvea', '$difference'),
                            ],
                          ),
                        ),

                        ViewsWidget.buildRowAction(context,'harvest_infomation', _onTapHarvest,
                            Image.asset("assets/images/icon_infomation.png", width: 30,height: 30)),
                        ViewsWidget.buildRowAction(context,'metamorphosis_history', _onTapHistory,
                            Image.asset("assets/images/icon_history.png", width: 30,height: 30,color: Colors.blue)),
                        ViewsWidget.buildRowAction(context,'sell', _onTapListSell,
                            Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.blue)),
                      ],
                    );
                  }
                  return new Center(child: CircularProgressIndicator());
                }
            )
        )
    );
  }
  _onTapHistory(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new PostlarveaMetaHistory(),
              inheritedData: idSub,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
  _onTapListSell(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<List<String>>(
              child: new ListOfPostlarveaSell(),
              inheritedData: [idSub,idPrepostlarvea,difference.toString()]
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
  _onTapHarvest(){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogHarvestInfomation(),
          inheritedData: idSub,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
}
