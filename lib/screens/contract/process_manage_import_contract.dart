import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/screens/broodstock/list_of_importcontract_assign_to_tank.dart';
import 'package:flutter_helloworld/screens/broodstock/list_of_importcontract_sell.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class ManageImportContract extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ManageImportContractState();
  }
}
class ManageImportContractState extends State<ManageImportContract> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;

  String idBatch,idContract;
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getBatchOfImportContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetBatchOFImportContact(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("process_manage_import_contract");
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
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idCon = InheritedProvider.of<String>(context);

    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('Manage_broodstock_assignment_contract'),
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
                future: _getBatchOfImportContract(idCon),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                      });
                    });
                  } else if (snapshot.hasData) {
                    Data contract = snapshot.data;
                    idBatch = contract.att1.toString();
                    idContract = contract.att2.toString();
                    return Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context, 'id_contract', contract.att2),
                              ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att3)}'),
                              ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att4)}'),
                              ViewsWidget.buildRowDetails(context, 'number_of_pair', '${function.formatNumber(contract.att5)}'),
                              ViewsWidget.buildRowDetails(context, 'unit_price', '${function.formatNumber(contract.att6)}'),
                              ViewsWidget.buildRowDetails(context, 'bonus', contract.att7.toString() == "null" ? '': contract.att7.toString() ),
                            ],
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context, 'number_of_cur_male', '${function.formatNumber(contract.att8)}'),
                              ViewsWidget.buildRowDetails(context, 'number_of_cur_female', '${function.formatNumber(contract.att9)}'),
                            ],
                          ),
                        ),
                        ViewsWidget.buildRowAction(context,'assign_to_tank', _onTapAssignToTank,
                            Image.asset("assets/images/icon_tank.png", width: 30,height: 30,color: Colors.blue)),
                        ViewsWidget.buildRowAction(context,'sell', _onTapSell,
                            Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.blueGrey)),

                      ],
                    );
                  }
                  return new Center(child: CircularProgressIndicator());
                }
            )
        )
    );
  }
  _onTapAssignToTank(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<List<String>>(
              child: new ListOfBroodStockAssignToTank(),
              inheritedData: [idContract,idBatch],
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });

  }
  _onTapSell(){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<List<String>>(
              child: new ListOfBroodStockSell(),
              inheritedData: [idContract,idBatch],
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
}
