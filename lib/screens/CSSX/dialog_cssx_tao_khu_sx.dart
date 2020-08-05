import 'dart:async';
import 'package:async/async.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';




class DialogCSSXTaoKhuSX extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogCSSXTaoKhuSXState();
  }
}
class DialogCSSXTaoKhuSXState extends State<DialogCSSXTaoKhuSX> {
  int typeHatchery = -1;

  DateTime selc = DateTime.now();
  String idHatchery;

  TextEditingController controllerNameCluster = new TextEditingController(),
    controllerAddress = new TextEditingController(), controllerYearEstablish = new TextEditingController(),
    controllerCountry = new TextEditingController(), controllerGPS = new TextEditingController(),
    controllerContractPerson = new TextEditingController(), controllerTelephone = new TextEditingController(),
      controllerCapacity = new TextEditingController(), controllerNUnit = new TextEditingController();

  _createKhuSX(BuildContext context,String idHatchery) async {
    if(controllerNameCluster.text.toString().length != 0 && controllerAddress.text.toString().length != 0 &&
        controllerCountry.text.toString().length != 0 && controllerYearEstablish.text.toString().length != 0 &&
        controllerCapacity.text.toString().length != 0 && ( controllerNUnit.text.toString().length != 0 || typeHatchery == 1 )) {
      String name = controllerNameCluster.text.toString(), address = controllerAddress.text.toString(),
            country = controllerCountry.text.toString();
      int capacity = int.parse(controllerCapacity.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      int nUnit = -1;
      if(typeHatchery > 1)
        nUnit = int.parse(controllerNUnit.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String year = function.formatDateCSDL(selc);
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryCreateKhuSX(
              name,
              address,
              country,
              year,
              capacity,
              nUnit,
              idHatchery)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      if (result.contains("1")) {
        Toast.show(Translations.of(context).text('saved'), context,
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final data = InheritedProvider.of<Data>(context);
    idHatchery = data.att1.toString();
    typeHatchery = int.parse(data.att9.toString());
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      //resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: Text(Translations.of(context).text('create_production_cluster'), style: themeData.primaryTextTheme.caption,),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ViewsWidget.buildInputRow(context, controllerNameCluster, 'name_of_production_cluster', 'enter_name_of_production_cluster', themeData),
            ViewsWidget.buildInputRow(context, controllerAddress, 'address', 'enter_address', themeData),
            ViewsWidget.buildInputCountryRow(context, controllerCountry, 'country', 'select_country', _countryPicker, themeData),
            ViewsWidget.buildInputNumberRow(context, controllerCapacity, 'production_capacity', 'enter_production_capacity', themeData),
            // chỉ có nauplii & postlarvea mới có nhập nhà sản xuất (2 & 3)
            Visibility(
              visible: typeHatchery > 1,
              child: ViewsWidget.buildInputNumberRow(context, controllerNUnit, 'n_of_production_unit', 'enter_n_of_production_unit', themeData),
            ),
            ViewsWidget.buildInputYearRow(context, controllerYearEstablish, 'establish_year', 'enter_establish_year', _yearPicker,themeData),
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
                        _createKhuSX(context, data.att1.toString());
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
        ),
      ),
    );
  }
  _openCountryPickerDialog() {
    ThemeData themeData = buildPrimaryThemeData(context);
    return showDialog(
      context: context,
      builder: (ctx) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
          child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.grey,
              searchInputDecoration: InputDecoration(hintText: Translations.of(context).text('search')),
              isSearchable: true,
              isDividerEnabled: true,
              title: Text(Translations.of(context).text('select_country'), style: themeData.primaryTextTheme.display4 ),
              onValuePicked: (Country country) =>
                  setState(() => controllerCountry.text  = country.name),
              itemBuilder: _buildDropdownItem)),
    );
  }
  Widget _buildDropdownItem(Country country) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return  Container(
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8,),
          Expanded(
            child: Text("${country.name}",style: themeData.primaryTextTheme.display3,),
          )

        ],
      ),
    );
  }
  _countryPicker() {
    //ThemeData themeData = buildPrimaryThemeData(context);
    FocusScope.of(context).requestFocus(FocusNode());
    _openCountryPickerDialog();
  }
  _yearPicker(){
      FocusScope.of(context).requestFocus(FocusNode());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Container(
                  width: 100,
                  height: 100,
                  child: YearPicker(
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    selectedDate: selc,
                    onChanged: (date) {
                      setState(() {
                        selc = date;
                        controllerYearEstablish.text = selc.year.toString();
                      });
                      Navigator.of(context).pop(false);
                    },
                  ),
                ));
          });
    }
}

