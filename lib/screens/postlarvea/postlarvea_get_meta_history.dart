import 'dart:convert';
import 'package:flutter_helloworld/queries/postlarvea.dart';
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

class PostlarveaMetaHistory extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new PostlarveaMetaHistoryState();
  }
}
class PostlarveaMetaHistoryState extends State<PostlarveaMetaHistory> {
  String idSub;
  double numZ1, numZ2, numZ3, numM1, numM2, numM3, numP1;
  String percentZ1, percentZ2, percentZ3, percentM1, percentM2, percentM3, percentP1;
  int numNauplii = -1;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getNaupliiFromPost(String idSub) async{
    return memCache.runOnce(() async {
      int i = 0;
      while(i++ < 3) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(
                Postlarvea.queryHistoryNumNaupliiOfPostlarvea(idSub)),
            encoding: Encoding.getByName("UTF-8")
        );
        print('${response.statusCode}');
        Data data = new Data();
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        data = Data.fromJson(jsonData[0]);
        return data;
      }
      return null;
    });
  }
  AsyncMemoizer<Map<String, Data>> memCacheStages = AsyncMemoizer();
  Future<Map<String, Data>> _getPostMetaHistory(String idSub) async{
    return memCacheStages.runOnce(() async {
      int i = 0;
      while(i++ < 3) {
        Map<String, Data> stages = new Map();
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Postlarvea.queryGetHistoryOfPostLarvea(idSub)),
            encoding: Encoding.getByName("UTF-8")
        );
        print('${response.statusCode}');
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
        }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ThemeData themeData = buildPrimaryThemeData(context);
    idSub = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: Text(Translations.of(context).text('metamorphosis_history')
              , style: themeData.primaryTextTheme.caption
          ),
          centerTitle: true,
          flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
                ),
              )
          ),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future:_getNaupliiFromPost(idSub),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasError){
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                        memCacheStages = AsyncMemoizer();
                      });
                    });
                  }else if(snapshot.hasData){
                    Data nau = snapshot.data;
                    numNauplii = int.parse(nau.att1.toString());
                    return new Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                          child: Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context,'number_of_nauplii', '${function.formatNumber(nau.att1)}'),
                              ViewsWidget.buildRowDetails(context,'assign_tank_date', '${function.convertDateCSDLToDateTimeDefault(nau.att2)}'),
                            ],
                          ),
                        ),
                        Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                            child: FutureBuilder(
                                future:_getPostMetaHistory(idSub),
                                builder: (BuildContext context, AsyncSnapshot snapshotStages) {
                                  if(snapshotStages.hasError){
                                    return ViewsWidget.buildNoInternet(context,(){
                                      setState(() {
                                        memCacheStages = AsyncMemoizer();
                                        //build(context);
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
                                    numP1 = double.parse(p1.att3.toString());
                                    percentP1 = function.formatpercentage((numP1/numNauplii) * 100);
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
                                            '${function.convertDateCSDLToDateTimeDefault(z1.att4)}') :
                                             ViewsWidget.buildRowMissingMetamorphosis(context, 'Z1'),

                                        z2.att2.toString() != "null" ?
                                        ViewsWidget.buildInfoMetamorphosis(context, 'Z2',
                                            '${function.formatNumber(z2.att3)} ($percentZ2%)',
                                            '${function.convertDateCSDLToDateTimeDefault(z2.att4)}') :
                                            ViewsWidget.buildRowMissingMetamorphosis(context, 'Z2'),
                                        z3.att2.toString() != "null" ?
                                        ViewsWidget.buildInfoMetamorphosis(context, 'Z3',
                                            '${function.formatNumber(z3.att3)} ($percentZ3%)',
                                            '${function.convertDateCSDLToDateTimeDefault(z3.att4)}') :
                                        ViewsWidget.buildRowMissingMetamorphosis(context, 'Z3'),
                                        m1.att2.toString() != "null" ?
                                        ViewsWidget.buildInfoMetamorphosis(context, 'M1',
                                            '${function.formatNumber(m1.att3)} ($percentM1%)',
                                            '${function.convertDateCSDLToDateTimeDefault(m1.att4)}') :
                                        ViewsWidget.buildRowMissingMetamorphosis(context, 'M1'),
                                        m2.att2.toString() != "null" ?
                                        ViewsWidget.buildInfoMetamorphosis(context, 'M2',
                                            '${function.formatNumber(m2.att3)} ($percentM2%)',
                                            '${function.convertDateCSDLToDateTimeDefault(m2.att4)}') :
                                        ViewsWidget.buildRowMissingMetamorphosis(context, 'M2'),
                                        m3.att2.toString() != "null" ?
                                        ViewsWidget.buildInfoMetamorphosis(context, 'M3',
                                            '${function.formatNumber(m3.att3)} ($percentM3%)',
                                            '${function.convertDateCSDLToDateTimeDefault(m3.att4)}') :
                                        ViewsWidget.buildRowMissingMetamorphosis(context, 'M3'),
                                        ViewsWidget.buildInfoMetamorphosis(context, 'P1',
                                            '${function.formatNumber(p1.att3)} ($percentP1%)',
                                            '${function.convertDateCSDLToDateTimeDefault(p1.att4)}'),
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


}
