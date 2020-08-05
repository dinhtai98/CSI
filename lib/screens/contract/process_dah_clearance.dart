import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/screens/photo/view_image.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';

class DahClearance extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DahClearanceState();
  }
}
class DahClearanceState extends State<DahClearance> {
  Future<Data> _getInfoDAHCustomClearance(String idCon) async{
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Contract.queryGetInFoDAHClearanceOfImportContract(idCon)),
        encoding: Encoding.getByName("UTF-8")
    );
    print("process DAH clearance");
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
        title: Text(Translations.of(context).text('title_dah_clearance_and_collecting')
        ,style: themeData.primaryTextTheme.caption,
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
              future: _getInfoDAHCustomClearance(idCon),
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
                        ViewsWidget.buildRowDetails(context, 'staff', contract.att2),
                        ViewsWidget.buildRowDetails(context, 'status','${function.statusDAHCustomClearance(context,contract.att3.toString())}'),
                        ViewsWidget.buildRowDetails(context, 'date', '${function.convertDateCSDLToDateTimeDefault(contract.att4.toString())}'),
                        GestureDetector(
                            child: Image.network("${contract.att5}",
                                height: 450,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                //imageUrl: "${contract.att5}",
                                //placeholder: (context, url) => new CircularProgressIndicator(),
                                //errorWidget: (context, url, error) => new Icon(Icons.error)
                            ),
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute<Null>(
                                  builder: (_) =>
                                      InheritedProvider<String>(
                                        child: new ViewImage() ,
                                        inheritedData: "${contract.att5}",
                                      ))
                              );
                            }
                        ),
                        /*Image.network(
                        '${contract.att4}',
                        height: 100,
                        width: 100,
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.fitWidth,
                      )*/
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
