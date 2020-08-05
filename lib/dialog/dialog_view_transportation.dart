import 'dart:convert';
import 'package:flutter_helloworld/queries/transporter.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;


class DialogTransportaionInfomation extends StatefulWidget {
  BuildContext ctx;
  DialogTransportaionInfomation({this.ctx});
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogTransportaionInfomationState();
  }
}
class DialogTransportaionInfomationState extends State<DialogTransportaionInfomation> {
  BuildContext preContext;
  String idCon;
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTransportaionContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Transport.queryGetTransportOfContract(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("dialog_new_transportation");
      Data data = new Data();
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      if(jsonData.length > 0)
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
    idCon = InheritedProvider.of<String>(context);
    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: SingleChildScrollView(
          child: Container(
              width: 300.0,
              child: transportationInformation(preContext)
          ),
        )

    );
  }
  Widget transportationInformation(BuildContext context){
    ThemeData themeData = buildPrimaryThemeData(context);
    return FutureBuilder(
        future: _getTransportaionContract(idCon),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          context = preContext;
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            Data transport = snapshot.data;
            print('transport ${transport.att1.toString()}');
            return transport.att1.toString() != "null" ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ViewsWidget.buildTitleDialog(context,'transportation_information'),
                  ViewsWidget.buildRowDetails(context,'transporter','${transport.att1}'),
                  ViewsWidget.buildRowDetails(context,'transporter','${transport.att2}'),
                  ViewsWidget.buildRowDetails(context,'transporter_phone','${transport.att3}'),
                  ViewsWidget.buildRowDetails(context,'depart_time','${function.convertDateCSDLToDateTimeDefault(transport.att4)}'),
                  ViewsWidget.buildRowDetails(context,'arrival_time','${function.convertDateCSDLToDateTimeDefault(transport.att5)}'),
                ]
            ) : _TransportationNotYet(context,themeData);
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );
  }
  Widget _TransportationNotYet(BuildContext context, ThemeData themeData){
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(context,'transportation_information'),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text(Translations.of(context).text('not_yet'),
                  style: themeData.primaryTextTheme.display3,),
              )
          ),
        ]
    );
  }
}