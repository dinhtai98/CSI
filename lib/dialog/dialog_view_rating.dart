import 'dart:convert';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/postlarvea.dart';
import 'package:flutter_helloworld/queries/ranking.dart';
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
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';


class DialogRatingInfomation extends StatefulWidget {
  BuildContext ctx;
  DialogRatingInfomation({this.ctx});
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogRatingInfomationState();
  }
}
class DialogRatingInfomationState extends State<DialogRatingInfomation> {
  BuildContext preContext;
  String idCon = '', query = "";

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getRankingContract(String query) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(query),
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
  }
  @override
  Widget build(BuildContext context) {
    preContext = widget.ctx;
    //print('value ${Translations.of(context).text('no_internet')}');
    idCon = InheritedProvider.of<String>(context);
    if(idCon.contains('ASCON'))
      query = Ranking.queryGetRankingBroodstockContract(idCon);
    else if(idCon.contains('NACON'))
      query = Ranking.queryGetRankingNaupliiContract(idCon);
    else if(idCon.contains('POCON'))
      query = Ranking.queryGetRankingPostlarveaContract(idCon);
    else if(idCon.contains('IMCON')){
      if(idCon.contains('hatchery'))
        query = Ranking.queryGetHatcheryRankingImportContract(idCon.replaceAll('hatchery', ''));
      else if(idCon.contains('dfish'))
        query = Ranking.queryGetDFISHRankingImportContract(idCon.replaceAll('dfish', ''));
    }
    print(query);
    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: Container(
            width: 300.0,
            child: rankingInformation(context,query)
        )

    );
  }
  Widget rankingInformation(BuildContext context, String query){
    ThemeData themeData = buildPrimaryThemeData(context);
    return FutureBuilder(
        future: _getRankingContract(query),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(preContext, (){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            Data ranking = snapshot.data;
            return SingleChildScrollView(
              child: ranking.att1.toString() != "null" ? _RankingDone(context, themeData, ranking) :
              _RankingNotYet(context,themeData),
            );
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );
  }
  Widget _RankingDone(BuildContext context, ThemeData themeData,Data ranking){
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(preContext,'ranking'),
          new StarRating(rating: double.parse(ranking.att1.toString()),size: 30,),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(Translations.of(preContext).text('comment'),
                    style: themeData.primaryTextTheme.display4,),
                ),
                Flexible(
                  flex: 4,
                  child: Text(
                    "${ranking.att2.toString() != "null" ? ranking.att2.toString() : ''}",
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.primaryTextTheme.display3,
                    maxLines: 10,),
                ),
              ],
            ),
          ),
          ViewsWidget.buildRowDetails(preContext,'ranking_date','${function.convertDateCSDLToDateTimeDefault(ranking.att3)}'),
        ]
    );
  }
  Widget _RankingNotYet(BuildContext context, ThemeData themeData){
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(preContext,'ranking'),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(Translations.of(preContext).text('not_yet'),
                style: themeData.primaryTextTheme.display3,),
            )
          ),
        ]
    );
  }
}