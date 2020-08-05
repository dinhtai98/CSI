import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_input_transportation_information.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_transportation.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class PostlarveaContractSell extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new PostlarveaContractSellState();
  }
}
class PostlarveaContractSellState extends State<PostlarveaContractSell> {

  String idCon, idTransport;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoPostlarveaContractSell(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoOfPostlarveaContractSell(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("detail postlarvea contract sell");
      if(response.statusCode == 200){
        Data contract = new Data();
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var jsonData = json.decode(result);
        contract = Data.fromJson(jsonData[0]);
        return contract;
      }
      else{
        throw("");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idCon = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('contract_details'),
          style: themeData.primaryTextTheme.caption,
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
              future: _getInfoPostlarveaContractSell(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data contract = snapshot.data;
                  String signDate = function.convertDateCSDLToDateDefault('${contract.att2}');
                  signDate = signDate.split(' ')[0];
                  idTransport = contract.att11.toString();
                  return new Column(
                    children: <Widget>[
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'id_contract', '${contract.att1}'),
                            ViewsWidget.buildRowDetails(context,'buyer', '${contract.att5} '
                                '(${contract.att7.toString() != "null" ? Translations.of(context).text('hatchery') :
                                                                         Translations.of(context).text('farmer')})'),
                            ViewsWidget.buildRowDetails(context, 'sign_date', '$signDate'),
                            ViewsWidget.buildRowDetails(context, 'number_of_postlarvea', '${function.formatNumber(contract.att3)}'),
                            ViewsWidget.buildRowDetails(context,'stage_of_postlarvea', '${contract.att4}'),
                            ViewsWidget.buildRowDetails(context, 'bonus', '${contract.att9.toString() == "null" ? "" : contract.att9.toString()}'),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'expected_deli_date', '${function.convertDateCSDLToDateTimeDefault(contract.att8)}'),
                            ViewsWidget.buildRowDetails(context, 'note', '${contract.att6}'),
                          ],
                        ),
                      ),
                      ViewsWidget.buildRowAction(context,'ranking', _onTapRanking,
                          Image.asset("assets/images/icon_rating_view.png", width: 30,height: 30,color: Colors.amber)),
                      ViewsWidget.buildRowAction(context,'transportation_information',_onTapTransport,
                          Image.asset("assets/images/icon_transportation.png", width: 30,height: 30,color: Colors.blue)),
                    ],
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }
  _onTapRanking(BuildContext context){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogRatingInfomation(ctx: context),
          inheritedData: idCon,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
  _onTapTransport(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<String>(
          child: idTransport != "null" ? new DialogTransportaionInfomation(ctx: context) : new DialogInputTransportationInformation(ctx: context) ,
          inheritedData: idCon,
        ))).then((onValue){
            setState(() {
            memCache = AsyncMemoizer();
            //_getTankBroodstock(idSub);
            });
        });
  }
}
