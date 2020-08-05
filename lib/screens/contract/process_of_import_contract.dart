import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/screens/contract/process_create_import_contract.dart';
import 'package:flutter_helloworld/screens/contract/process_dah_clearance.dart';
import 'package:flutter_helloworld/screens/contract/process_dard_quarantine_clearance.dart';
import 'package:flutter_helloworld/screens/contract/process_hatchery_not_save_evidence.dart';
import 'package:flutter_helloworld/screens/contract/process_hatchery_saved_evidence.dart';
import 'package:flutter_helloworld/screens/contract/process_manage_import_contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:http/http.dart' as http;

import 'process_dard_quarantine.dart';


class ProcessImportContract extends StatefulWidget {
  String idContract;

  ProcessImportContract({this.idContract});

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ProcessImportContractState();
  }
}
class ProcessImportContractState extends State<ProcessImportContract> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
  new GlobalKey<RefreshIndicatorState>();
  TextStyle style = TextStyle(fontFamily: 'Google sans', fontSize: 20.0);

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  _getProcessOfImportContract() async{
    Data data = new Data();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(
              Contract.queryGetProcessOfImportContract(widget.idContract)),
          encoding: Encoding.getByName("UTF-8")
      );
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
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicator.currentState?.show();
    });
  }
  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    memCache = AsyncMemoizer();
    setState(() {
      _getProcessOfImportContract();
    });
    return null;
  }
  var drawerItems = [new InfoImportContract(), new HatcheryNotYetSaveEvidence(), new HatcherySavedEvidence(),
                    new DahClearance(), new DARDQuarantine(), new DARDQuarantineClearance(), new ManageImportContract()];
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: Text(Translations.of(context).text('processofcontract'),style: themeData.primaryTextTheme.caption,
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
      body: RefreshIndicator(
          key: _refreshIndicator,
          onRefresh: _handleRefresh,
          child: FutureBuilder(
              future: _getProcessOfImportContract(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();

                    });
                  });
                }else if(snapshot.hasData){
                  Data process = snapshot.data;
                  String quarantine = process.att4.toString();
                  String quarantineClearance = quarantine == "2" ? "2" : "null";
                  String manage = quarantineClearance == "2" ? "ok" : "null";
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Container(
                          //decoration: BoxDecoration(color: Color(0xff000000),
                          //borderRadius: BorderRadius.circular(25.0)),
                          child: new Column(
                            children: <Widget>[
                              buildItemProcess(context,process.att1.toString(), 'Creating_broodstock_import_contract',0),
                              buildItemProcess(context,process.att2.toString(), 'Hatchery_save_approved_custom_clearance_evidence',
                                  process.att2.toString() == "null" ? 1 : 2),
                              buildItemProcess(context,process.att3.toString(), 'DAH_clearance_and_collecting',3),
                              buildItemProcess(context,quarantine, 'DARD_quarantine_at_hatchery',4),
                              buildItemProcess(context,quarantineClearance, 'DARD_quarantine_clearance',5),
                              buildItemProcess(context,manage, 'Manage_broodstock_assignment_contract',6)
                            ],
                          ),
                        )

                    ),
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }
  Widget buildItemProcess(BuildContext ctxt, String check, String label, int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    double _opacity = check != "null" ? 1.0 : 0.0;
    return ListTile(
        onTap: () {
          if(check != "null" || index < 3 ) {
            Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: (_) =>
                    InheritedProvider<String>(
                      child: drawerItems[index],
                      inheritedData: widget.idContract,
                    ))).then((onValue) {
              setState(() {
                memCache = AsyncMemoizer();
                _getProcessOfImportContract();
              });
            });
          }
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 1.0, color: Color(0xff007B97)))),
            child: new Opacity(opacity: _opacity,
                child: Image.asset("assets/images/icontick.png",width: 30,height: 30,color: Colors.green,)
            )
        ),
        title: Text(
            Translations.of(context).text('$label'), style: themeData.primaryTextTheme.display2
        ),
        trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0)
    );
  }
}
