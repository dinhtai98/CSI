import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/screens/tank/tank_broodstock.dart';
import 'package:flutter_helloworld/screens/tank/tank_empty.dart';
import 'package:flutter_helloworld/screens/tank/tank_nauplii.dart';
import 'package:flutter_helloworld/screens/tank/tank_postlarvea.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
class TankDetails extends StatefulWidget {

  String idTank,idSub,checkPostlarvea;
  TankDetails({this.idTank,this.idSub,this.checkPostlarvea});

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TankDetailsState();
  }
}
class TankDetailsState extends State<TankDetails> {
  String idTank, idSub,checkPostlarvea;

  TankBroodstock tankBroodstock;
  TankNauplii tankNauplii;
  TankPostlarvea tankPostlarvea;
  TankEmpty tankEpmty;

  Widget currentPage;
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTankDetails(String idTank) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetDetailTank(idTank)),
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
    super.initState();
    //setState(() {
    idTank  = widget.idTank.toString();
    idSub = widget.idSub.toString();
    checkPostlarvea = widget.checkPostlarvea.toString();
    if(idSub != "null"){
      if(idSub.contains("SUBAT")){
        tankBroodstock = TankBroodstock(this.callback,idSub);
        currentPage = tankBroodstock;
      }else{
        if(checkPostlarvea != "null"){
          tankPostlarvea = TankPostlarvea(this.callback,idSub);
          currentPage = tankPostlarvea;
        }else{
          tankNauplii = TankNauplii(this.callback,idSub,checkPostlarvea);
          currentPage = tankNauplii;
        }
      }
    }else{
      tankEpmty = TankEmpty(this.callback);
      currentPage = tankEpmty;
    }
    //});

  }

  void callback(Widget nextPage) {
    setState(() {
      this.currentPage = nextPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //Current page to be changed from other classes too?
        body: currentPage
    );
  }

}