import 'dart:convert';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/postlarvea.dart';
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
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';


class DialogHarvestInfomation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogHarvestInfomationState();
  }
}
class DialogHarvestInfomationState extends State<DialogHarvestInfomation> {

  String idSub;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoHarvest(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Postlarvea.queryInfoHavest(idSub)),
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
    ThemeData themeData = buildPrimaryThemeData(context);
    idSub = InheritedProvider.of<String>(context);

    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: SingleChildScrollView(
          child: Container(
              width: 300.0,
              child: infoHarvestInfomation(context,idSub)
          ),
        )

    );
  }
  Widget infoHarvestInfomation(BuildContext context, String idSub){
    return FutureBuilder(
        future: _getInfoHarvest(idSub),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            Data harvest = snapshot.data;
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ViewsWidget.buildTitleDialog(context,'harvest_infomation'),
                  ViewsWidget.buildRowDetails(context,'expected_harvest_number_of_post','${function.formatNumber(harvest.att1)}'),
                  ViewsWidget.buildRowDetails(context,'expected_date_of_harvest','${function.convertDateCSDLToDateTimeDefault(harvest.att2)}'),
                  ViewsWidget.buildRowDetails(context,'harvest_number_of_post','${function.formatNumber(harvest.att3)}'),
                  ViewsWidget.buildRowDetails(context,'date_of_harvest','${function.convertDateCSDLToDateTimeDefault(harvest.att4)}'),

                ]
            );
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );

  }
}