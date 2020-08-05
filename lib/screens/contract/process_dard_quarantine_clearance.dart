import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class DARDQuarantineClearance extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DARDQuarantineClearanceState();
  }
}
class DARDQuarantineClearanceState extends State<DARDQuarantineClearance> {

  Future<Data> _getInfoDARDClearance(String idCon) async{
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Contract.queryGetInfoOfDARDClearance(idCon)),
        encoding: Encoding.getByName("UTF-8")
    );
    print("DARDQuarantineClearance ${response.body}");
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
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idCon = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('title_dard_quarantine_clearance')
            ,style: themeData.primaryTextTheme.caption
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
              future: _getInfoDARDClearance(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text("ERROR OCCURRED, Tap to retry !"),),
                      onTap: () =>
                          setState(() {
                            build(context);
                          }));
                } else if (snapshot.hasData) {
                  Data contract = snapshot.data;
                  return Card(
                    //elevation: 5.0,
                    child: Column(
                      children: <Widget>[
                        ViewsWidget.buildRowDetails(context, 'id_contract', contract.att1),
                        ViewsWidget.buildRowDetails(context, 'staff', contract.att6),
                        ViewsWidget.buildRowDetails(context, 'date', '${function.convertDateCSDLToDateTimeDefault(contract.att5.toString())}'),
                      ],
                    ),
                  );
                }
                return new Center(child: CircularProgressIndicator());
              }
          )
      )
    );
  }
}
