import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/queries/transporter.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';

import '../translations.dart';



class DialogInputTransportationInformation extends StatefulWidget {
  BuildContext ctx;
  DialogInputTransportationInformation({this.ctx});
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogInputTransportationInformationState();
  }
}
class DialogInputTransportationInformationState extends State<DialogInputTransportationInformation> {
  Future<Data> getUser = DataUser.getDataUser();
  String idContract,idStaff;

  TextEditingController txtTransporter = new TextEditingController(), txtTransporterPhone = new TextEditingController(),
      txtDepartDate = new TextEditingController(),txtArrivalDate = new TextEditingController();

  Data _currentTransport;
  List<DropdownMenuItem<Data>> _dropDownTransport = List();
  AsyncMemoizer<List<dynamic>> memCacheTransport = AsyncMemoizer();

  Future<List<dynamic>> _getAllTransport() async{

    List<dynamic> list = List();
    return memCacheTransport.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Transport.query_getAllTransporter),
          encoding: Encoding.getByName("UTF-8")
      );
      print("dialog_input_transportation_information");
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic item in jsonData) {
          list.add(item);
        }
        _listDropdownMenuTransport(list);
        return list;
      }
      throw("");
    });
  }
  _listDropdownMenuTransport(List<dynamic> list){

    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownTransport.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      _currentTransport = _dropDownTransport[0].value;
      //_getAllTankOfCluster(_currentClus.att1);
    });

    //setState(() {
    //});

  }
  void changedDropDownTransport(Data selectedTransport) {
    setState(() {
      _currentTransport = selectedTransport;
    });

  }

  _ConfirmTransportation(BuildContext context) async {
    if(txtTransporter.text.toString().length != 0 && txtTransporterPhone.text.toString().length != 0 &&
        txtDepartDate.text.length != 0 && txtArrivalDate.text.length != 0 && _currentTransport.att1 != null) {
      String idCompany = _currentTransport.att1;

      String transporter = txtTransporter.text.toString(), transporterPhone = txtTransporterPhone.text.toString(),
          departDate = function.convertDefaultToDateCSDL(txtDepartDate.text.toString()),
          arrivalDate = function.convertDefaultToDateCSDL(txtArrivalDate.text.toString());
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Transport.queryInsertTransportInfomation(
              idContract, idCompany, transporter, transporterPhone,
              departDate, arrivalDate, idStaff)),
          encoding: Encoding.getByName("UTF-8")
      );
      print(response.statusCode);
      print(response.body);
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      if (result.contains("1")) {
        Toast.show(Translations.of(context).text('saved'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
      if(result.contains("0")) {
        Toast.show(Translations.of(context).text('contract_already_had_transport_infomation'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  @override
  void initState() {
    super.initState();
    getUser.then((onValue){
      setState(() {
        idStaff = onValue.att10.toString();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    idContract = InheritedProvider.of<String>(context);
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('transportation_information'),
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
              future: _getAllTransport(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCacheTransport = AsyncMemoizer();
                      build(context);
                    });
                  });
                }else if(snapshot.hasData){
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context, 'id_contract',idContract ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(Translations.of(context).text('transport_company'),
                                  style: themeData.primaryTextTheme.display4),
                            ),
                            ViewsWidget.buildDropDownList(
                                _dropDownTransport, _currentTransport, changedDropDownTransport,themeData),
                          ],
                        ),
                      ),
                      ViewsWidget.buildInputRow(context, txtTransporter ,'transporter','hint_transporter', themeData),
                      ViewsWidget.buildInputPhoneNumberRow(context, txtTransporterPhone ,'transporter_phone','hint_transporter_phone', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtDepartDate,'depart_time', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtArrivalDate,'arrival_time', themeData),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  Navigator.of(context).pop();
                                },
                                child: Text(Translations.of(context).text('skip'),
                                    textAlign: TextAlign.center,
                                    style: themeData.primaryTextTheme.button),
                              ),
                            ),
                          ),
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
                                  _ConfirmTransportation(context);
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
                return new Center(
                    child: CircularProgressIndicator());
              }
          ),
      ),
    );
  }
}
