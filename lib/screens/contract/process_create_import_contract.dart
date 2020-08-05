import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class InfoImportContract extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new InfoImportContractState();
  }
}
class InfoImportContractState extends State<InfoImportContract> {

  String idCon,idHatcheryRankingProducer,idDFishRankingProducer, idProducer,idHatchery;
  Future<Data> dataUser = DataUser.getDataUser();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoImportContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoImportContract(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data contract = new Data();
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
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
    dataUser.then((onValue){
      setState(() {
        idHatchery = onValue.att1.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idCon = InheritedProvider.of<String>(context);
    print('idCon $idCon');
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('import_contract_details'),
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
            future: _getInfoImportContract(idCon),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasError){
                return ViewsWidget.buildNoInternet(context,(){
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }else if(snapshot.hasData){
                Data contract = snapshot.data;
                idProducer = contract.att21.toString();
                idHatcheryRankingProducer = contract.att22.toString();
                idDFishRankingProducer = contract.att23.toString();
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
                          ViewsWidget.buildRowDetails(context,  'producer', '${contract.att4}'),
                          ViewsWidget.buildRowDetails(context, 'trader', '${contract.att3}'),
                          ViewsWidget.buildRowDetails(context, 'sign_date', '${function.convertDateCSDLToDateDefault(contract.att5)}'),
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
                          ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att16)}'),
                          ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att17)}'),
                          ViewsWidget.buildRowDetails(context,'number_of_pair', '${function.formatNumber(contract.att19)}'),
                          ViewsWidget.buildRowDetails(context, 'unit_price', '${function.formatNumber(contract.att18)}'),
                          ViewsWidget.buildRowDetails(context, 'bonus', '${contract.att20.toString() == "null" ? "" : contract.att20.toString()}'),
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
                          ViewsWidget.buildRowDetails(context, 'expected_deli_date', '${function.convertDateCSDLToDateTimeDefault(contract.att6)}'),
                          ViewsWidget.buildRowDetails(context, 'arrival_port', '${contract.att7}'),
                          ViewsWidget.buildRowDetails(context, 'arrival_port_date', '${function.convertDateCSDLToDateTimeDefault(contract.att8)}'),
                          ViewsWidget.buildRowDetails(context, 'arrival_hatchery_date', '${function.convertDateCSDLToDateTimeDefault(contract.att9)}'),
                          ViewsWidget.buildRowDetails(context, 'money_transfer_date', '${function.convertDateCSDLToDateDefault(contract.att10)}'),
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
                          ViewsWidget.buildRowDetails(context, 'via_bank', '${contract.att11}'),
                          ViewsWidget.buildRowDetails(context, 'wiring_number', '${contract.att12}'),
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
                          ViewsWidget.buildRowDetails(context,'transfer_amount', '${function.formatNumber(contract.att13)}'),
                          ViewsWidget.buildRowDetails(context,'total_amount', '${function.formatNumber(contract.att14)}'),
                        ],
                      ),
                    ),
                    ViewsWidget.buildRowAction(context,'ranking', _onTapHatcheryRanking,
                        Image.asset("assets/images/icon_rating_view.png", width: 30,height: 30,color: Colors.amber)),
                    ViewsWidget.buildRowAction(context,'dfish_ranking', _onTapDFISHRanking,
                        Image.asset("assets/images/icon_rating_view.png", width: 30,height: 30,color: Colors.amber)),
                  ],
                );
              }
              return new Center(
                child: CircularProgressIndicator(),
              );
            }
        )
      ),
    );
  }
  _onTapHatcheryRanking(BuildContext context){
    showDialog(
        context: context,
        builder: (_) => idHatcheryRankingProducer == "null" ? InheritedProvider<List<String>>(
            child: new DialogInputRanking(ctx: context),
            inheritedData: [idCon,idProducer,idHatchery]
        ) : InheritedProvider<String>(
            child: new DialogRatingInfomation(ctx: context),
            inheritedData: 'hatchery$idCon'
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
  _onTapDFISHRanking(BuildContext context){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
            child: new DialogRatingInfomation(ctx: context),
            inheritedData: 'dfish$idCon'
    )).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
}
