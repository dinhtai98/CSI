import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/queries/spawning.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';
import '../translations.dart';
import 'package:postgres/postgres.dart';
import '../Data/ConvertDataList.dart';

class NaupliiAssignTankFromContract extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new NaupliiAssignTankFromContractState();
  }
}
class NaupliiAssignTankFromContractState extends State<NaupliiAssignTankFromContract> {
  List<String> dataContract;
  String idCon, idStaff, idHatchery;
  int curNum = -1;
  TextEditingController txtNum = new TextEditingController(), txtDate = new TextEditingController(),
      txtExpectedHarvestDate = new TextEditingController();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoOfNaupliiContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoOfNaupliiContractBuy(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("query get info of nauplii: ${response.body}");
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

  Data _currentClus;
  Data _currentUnit;
  Data _currentTank = new Data();
  List<DropdownMenuItem<Data>> _dropDownCluster = List();
  AsyncMemoizer<List<dynamic>> memCacheCluster = AsyncMemoizer();

  List<DropdownMenuItem<Data>> _dropDownProductionUnit = List();
  AsyncMemoizer<List<dynamic>> memCacheProductionUnit = AsyncMemoizer();

  Future<List<dynamic>> _getAllProductionClusterHasUnitHasTank(String idHatchery) async{

    List<dynamic> listClus = List();
    return memCacheCluster.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetClusterHasUnitHasTankOfHatchery(idHatchery)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("query get cluster result: ${response.body}");
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic pro in jsonData) {
          listClus.add(pro);
        }
        _listDropdownMenuCluster(listClus);
        return listClus;
      }
      throw("");
    });
  }
  Future<List<dynamic>> _getAllProductionUnitHasTankOfCluster(String idKhuSX) async{

    List<dynamic> listUnit = List();
    return memCacheProductionUnit.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetUnitHasTankOfCluster(idKhuSX)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("query get unit has tank of cluster: ${response.body}");
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic pro in jsonData) {
          listUnit.add(pro);
        }
        _listDropdownMenuProductionUnit(listUnit);
        return listUnit;
      }
      throw("");
    });
  }
  _listDropdownMenuCluster(List<dynamic> list){

    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownCluster.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      _currentClus = _dropDownCluster[0].value;
    });
  }
  void changedDropDownClus(Data selectedClus) {
    setState(() {
      _dropDownProductionUnit.clear();
      _dropDownTank.clear();
      _currentClus = selectedClus;
      memCacheProductionUnit = AsyncMemoizer();
      //_getAllTankOfCluster(_currentClus.att1);
    });

  }
  _listDropdownMenuProductionUnit(List<dynamic> list){

    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownProductionUnit.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      memCacheTank = AsyncMemoizer();
      _currentUnit = _dropDownProductionUnit[0].value;
    });
  }
  void changedDropDownProductionUnit(Data selectedUnit) {
    setState(() {
      _dropDownTank.clear();
      _currentUnit = selectedUnit;
      memCacheTank = AsyncMemoizer();
      //_getAllTankOfCluster(_currentClus.att1);
    });

  }
  void changedDropDownTank(Data selectedTank) {
    setState(() {
      _currentTank = selectedTank;
    });

  }

  List<DropdownMenuItem<Data>> _dropDownTank = List();
  AsyncMemoizer<List<dynamic>> memCacheTank = AsyncMemoizer();
  Future<List<dynamic>> _getAllTankOfProductionUnit(String idNhaSX) async{
    return memCacheTank.runOnce(() async {
      List<dynamic> _listTank = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetAllTankEmptyOfCluster(idNhaSX)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("query Get All Tank Empty Of Cluster ${response.body}");
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic item in jsonData) {
          _listTank.add(item);
        }
        //setState(() {
        _listDropdownMenuTank(_listTank);
        //});

        return _listTank;
      }
      throw("");
    });
  }
  _listDropdownMenuTank(List<dynamic> list){
    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownTank.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      _currentTank = _dropDownTank[0].value;
    });

  }

  _naupliiAssignToTankFromContract(BuildContext context) async {
    if(txtNum.text.toString().length != 0 && txtExpectedHarvestDate.text.toString().length != 0 &&
        txtDate.text.length != 0 &&
        _currentClus.att1 != null && _currentTank.att1 != null) {
      String idTank = _currentTank.att1;
      int num = int.parse(txtNum.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String date = function.convertDefaultToDateCSDL(txtDate.text.toString()),
          expectedHarvestDate = function.convertDefaultToDateCSDL(txtExpectedHarvestDate.text.toString());
      if(num <= curNum && num > 0) {
        http.Response response = await http.post(
            Api.url_update,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Nauplii.queryNaupliiAssignTankFromNaupliiContract(
                idCon,
                num,
                idHatchery,
                idStaff,
                idTank,
                date,
                expectedHarvestDate)),
            encoding: Encoding.getByName("UTF-8")
        );
        print("query nauplii assign tank from nauplii contract: ${response.body}");
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);

        if (result.contains("1")) {
          Toast.show(Translations.of(context).text('saved'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
      }else{
        Toast.show('${Translations.of(context).text('you_have_just')} ${function.formatNumber(curNum.toString())} ${Translations.of(context).text('nauplii')}',
            context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  @override
  void initState() {
    super.initState();
  }
  int initial = 0;
  @override
  Widget build(BuildContext context) {
    dataContract = InheritedProvider.of<List<String>>(context);
    idCon = dataContract[0];
    idStaff = dataContract[1];
    idHatchery = dataContract[2];

    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('assign_to_tank'),
            style: themeData.primaryTextTheme.caption
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
              future: _getInfoOfNaupliiContract(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                      build(context);
                    });
                  });
                } else if (snapshot.hasData) {
                  Data contract = snapshot.data;
                  curNum = int.parse(contract.att5.toString());
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'id_contract', '${contract.att1}'),
                      ViewsWidget.buildRowDetails(context,'number_of_nauplii','${function.formatNumber(contract.att5)}'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Container(
                          height: 1.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                      FutureBuilder(
                          future: _getAllProductionClusterHasUnitHasTank(idHatchery),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if(snapshot.data == null){
                              return new Center(
                                child: Text('Loading'),
                              );
                            }else if(snapshot.hasData){
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Text(Translations.of(context).text('production_cluster')),
                                        ),
                                        ViewsWidget.buildDropDownList(
                                            _dropDownCluster, _currentClus, changedDropDownClus,themeData),
                                      ],
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: _getAllProductionUnitHasTankOfCluster(_currentClus.att1.toString()),
                                      builder: (BuildContext context, AsyncSnapshot snapshotUnit){
                                        if(snapshotUnit.data == null){
                                          return new Center(
                                            child: Text('Loading'),
                                          );
                                        }else if(snapshotUnit.hasData){
                                          print('cluster ${_currentClus.att1.toString()}');
                                          return Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(Translations.of(context).text('production_unit')),
                                                    ),
                                                    ViewsWidget.buildDropDownList(
                                                        _dropDownProductionUnit, _currentUnit, changedDropDownProductionUnit, themeData),
                                                  ],
                                                ),
                                              ),
                                              FutureBuilder(
                                                  future: _getAllTankOfProductionUnit(_currentUnit.att1.toString()),
                                                  builder: (BuildContext context, AsyncSnapshot snapshotTank){
                                                    if(snapshotTank.data == null){
                                                      return new Center(
                                                        child: Text('Loading'),
                                                      );
                                                    }else if(snapshotTank.hasData){
                                                      print('unit ${_currentUnit.att1.toString()}');
                                                      return Padding(
                                                        padding: EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(Translations.of(context).text('tank')),
                                                            ),
                                                            ViewsWidget.buildDropDownList(
                                                                _dropDownTank, _currentTank, changedDropDownTank, themeData),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return new Center(
                                                      child: Text('Waiting'),
                                                    );
                                                  }),
                                            ],
                                          );
                                        }
                                        return new Center(
                                          child: Text('Loading'),
                                        );
                                      }),
                                ],
                              );
                            }
                            return new Center(
                              child: Text('Loading'),
                            );
                          }
                      ),
                      ViewsWidget.buildInputNumberRow(context, txtNum,'number_of_nauplii', 'hint_number_of_nauplii',themeData ),
                      ViewsWidget.selectDateTimePicker(context,txtDate,'assign_tank_date', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtExpectedHarvestDate,'expected_harvest_date', themeData),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 25.0),
                            width: 120,
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(30.0),
                              color: Color(0xff01A0C7),
                              child: MaterialButton(
                                //minWidth: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                onPressed: (){
                                  _naupliiAssignToTankFromContract(context);
                                },
                                child: Text(Translations.of(context).text('save'),
                                    textAlign: TextAlign.center,
                                    style: themeData.primaryTextTheme.button),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                }
                return new Center(child: CircularProgressIndicator());
              })
      ),
    );
  }
}
