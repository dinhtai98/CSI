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

class HatcherySavedEvidence extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HatcherySavedEvidenceState();
  }
}
class HatcherySavedEvidenceState extends State<HatcherySavedEvidence> {

  Future<Data> _getInfoHatcherySaveEvidence(String idCon) async{
    http.Response response = await http.post(
        Api.urlGetDataByPost,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(Contract.queryGetInfoCustomClearanceOfImportContract(idCon)),
        encoding: Encoding.getByName("UTF-8")
    );
    print("process hatchery saved evidence");
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
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    String idCon = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: Text(Translations.of(context).text('hatchery_save_evidence'),
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
              future: _getInfoHatcherySaveEvidence(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      build(context);
                    });
                  });
                } else if (snapshot.hasData) {
                  Data contract = snapshot.data;
                  return Card(
                    //elevation: 5.0,

                    child: Column(
                      children: <Widget>[
                        ViewsWidget.buildRowDetails(context, 'id_contract', contract.att1),
                        ViewsWidget.buildRowDetails(context, 'staff', contract.att2.toString()),
                        ViewsWidget.buildRowDetails(context, 'date', '${function.convertDateCSDLToDateTimeDefault(contract.att3)}'),
                        GestureDetector(
                            child: Image.network("${contract.att4}",
                                height: 450,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                //imageUrl: ,
                                //placeholder: (context, url) => new CircularProgressIndicator(),
                                //errorWidget: (context, url, error) => new Icon(Icons.error)
                            ),
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute<Null>(
                                  builder: (_) =>
                                      InheritedProvider<String>(
                                        child: new ViewImage() ,
                                        inheritedData: "${contract.att4}",
                                      ))
                              );
                            }
                        ),
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
