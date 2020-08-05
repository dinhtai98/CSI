import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../navigator.dart';
import '../translations.dart';

class ViewsWidget{

  static Widget buildDropDownList(List<DropdownMenuItem<Data>> list, Data _current, change, ThemeData themeData){
    return Expanded(
      flex: 4,
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton(
          isExpanded: true,
          style: themeData.primaryTextTheme.display3,
          value: _current,
          items: list,
          onChanged: change,
        ),
      ),

    );
  }
  static Widget buildTypeAHead(ThemeData themeData, TextEditingController ahead, String idData, String nameData,
    AsyncMemoizer<List<dynamic>> cache, function ){
    TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
    return Expanded(
      flex: 4,
      child: ButtonTheme(
        alignedDropdown: true,
        child: TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: ahead,
              style:  idData == ""  ? notOk : themeData.primaryTextTheme.display3,
              decoration: InputDecoration(
                hintText: 'Chọn Đại diện NCC',
              ),
            ),
            getImmediateSuggestions: true,
            suggestionsCallback: (pattern) {
              if(nameData != pattern){
                idData = "";
              }
              cache = AsyncMemoizer();
              return function(pattern);
            },
            itemBuilder: (context, suggestion) {
              dynamic list = suggestion;
              String name = list['att2'];
              return ListTile(
                title: Text(name,style:  themeData.primaryTextTheme.display3,),
              );
            },
            noItemsFoundBuilder: (context) {
              return Text(Translations.of(context).text("no_results_found"),style:  notOk,);
            },
            errorBuilder: (context,object) {
              return Text(Translations.of(context).text("error"),style:  notOk,);
            },
            hideOnLoading: true,
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              dynamic list = suggestion;
              String id = list['att1'];
              String name = list['att2'];
              idData = id;
              nameData = name;
              ahead.text = name;
            },

            onSaved: (value){
              print('onSaved $value');
              //this._typeAheadController.text = value;
            }
        ),
      ),
    );
  }
  static Widget buildDropDownListString(List<DropdownMenuItem<String>> list, String _current, change, ThemeData themeData){
    return Flexible(
      flex: 4,
      child: new DropdownButton(
        style: themeData.primaryTextTheme.display3,
        value: _current,
        items: list,
        onChanged: change,
      ),
    );
  }
  static Widget buildRadioSpecies(BuildContext context,String _radioSpecies, _handleRadioSpecies, ThemeData themeData){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Radio(
          value: "1",
          groupValue: _radioSpecies,
          onChanged: _handleRadioSpecies,
        ),
        new Text(
          Translations.of(context).text('penaeus_vanamei'),
          style: themeData.primaryTextTheme.display3,
        ),
        new Radio(
          value: "2",
          groupValue: _radioSpecies,
          onChanged: _handleRadioSpecies,
        ),
        new Text(
          Translations.of(context).text('penaeus_monodon'),
          style: themeData.primaryTextTheme.display3,
        ),
      ],
    );
  }

  static Widget buildButton(BuildContext context, String label,_click ,ThemeData themeData ){
    return Container(
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
            _click();
          },
          child: Text(Translations.of(context).text('$label'),
              textAlign: TextAlign.center,
              style: themeData.primaryTextTheme.display2),
        ),
      ),
    );
  }
  static Widget selectDateTimePicker(BuildContext context, TextEditingController textController, String label, ThemeData themeData){
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10 , 10),
        child: TextField(
            style: themeData.primaryTextTheme.display3,
            controller: textController,
            onTap: () => function.openDateTimePicker(context, textController),
            decoration: InputDecoration(
                labelStyle: themeData.primaryTextTheme.display4,
                labelText: Translations.of(context).text('$label'),
                prefixIcon: Image.asset('assets/images/ic_clock.png'),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xffCED0D2),width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6))
                )
            )
        )
    );
  }
  static Widget selectDatePicker(BuildContext context, TextEditingController textController, String label, ThemeData themeData){
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10 , 10),
        child: TextField(
            style: themeData.primaryTextTheme.display3,
            controller: textController,
            onTap: () => function.openDatePicker(context, textController),
            decoration: InputDecoration(
                labelStyle: themeData.primaryTextTheme.display4,
                labelText: Translations.of(context).text('${label}'),
                prefixIcon: Image.asset('assets/images/ic_clock.png'),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xffCED0D2),width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6))
                )
            )
        )
    );
  }
  static Widget buildInputNumberRow(BuildContext context, TextEditingController textController, String label, String hint ,ThemeData themeData){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Text(
                Translations.of(context).text('$label'),
                style: themeData.primaryTextTheme.display4),
            flex: 2,
          ),
          Expanded(
            flex: 4,
            child: TextField(
                style: themeData.primaryTextTheme.display4,
                inputFormatters: [
                  new NumericTextFormatter(),
                  new BlacklistingTextInputFormatter(new RegExp('[\\-]')),
                ],
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                  hintText: Translations.of(context).text('$hint'),
                  //border:
                  //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                )
            ),
          )
          //,
        ],
      ),
    );
  }
  static Widget buildInputPhoneNumberRow(BuildContext context, TextEditingController textController, String label, String hint ,ThemeData themeData){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
                Translations.of(context).text('$label'),
                style: themeData.primaryTextTheme.display4),
            flex: 2,
          ),
          Expanded(
            flex: 4,
            child: TextField(
                style: themeData.primaryTextTheme.display3,
                //maxLength: 15,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  new PhoneNumberTextInputFormatter(),
                  //new BlacklistingTextInputFormatter(new RegExp('[\\-|\\,|\\.]')),
                ],
                controller: textController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                  hintText: Translations.of(context).text('$hint'),
                  //border:
                  //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                )
            ),
          )
          //,
        ],
      ),
    );
  }
  static Widget buildInputRow(BuildContext context, TextEditingController textController, String label, String hint ,ThemeData themeData){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Text(
                Translations.of(context).text('$label'),
                style: themeData.primaryTextTheme.display4),
            flex: 2,
          ),
          Expanded(
            flex: 4,
            child: TextField(
                style: themeData.primaryTextTheme.display3,
                controller: textController,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                  hintText: Translations.of(context).text('$hint'),
                  //border:
                  //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                )
            ),
          )
          //,
        ],
      ),
    );
  }
  static Widget buildInputYearRow(BuildContext context, TextEditingController textController, String label,
      String hint ,_yearPicker, ThemeData themeData){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Text(
                Translations.of(context).text('$label'),
                style: themeData.primaryTextTheme.display4),
            flex: 2,
          ),
          Expanded(
            flex: 4,
            child: TextField(
                onTap: (){
                  _yearPicker();
                },
                style: themeData.primaryTextTheme.display3,
                controller: textController,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                  hintText: Translations.of(context).text('$hint'),
                  //border:
                  //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                )
            ),
          )
          //,
        ],
      ),
    );
  }
  static Widget buildInputCountryRow(BuildContext context, TextEditingController textController, String label,
      String hint ,_countryPicker, ThemeData themeData){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Text(
                Translations.of(context).text('$label'),
                style: themeData.primaryTextTheme.display4),
            flex: 2,
          ),
          Expanded(
            flex: 4,
            child: TextField(
                onTap: (){
                  _countryPicker();
                },
                style: themeData.primaryTextTheme.display3,
                controller: textController,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                  hintText: Translations.of(context).text('$hint'),
                  //border:
                  //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                )
            ),
          )
          //,
        ],
      ),
    );
  }
  static Widget buildRowDetails(BuildContext context, String label, String result){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(Translations.of(context).text('$label'),
              style: themeData.primaryTextTheme.display4,),
          ),
          Expanded(
            flex: 4,
            child: Text(result,style: themeData.primaryTextTheme.display3,),
          ),
        ],
      ),
    );
  }
  static Widget buildRowDetailsWithWidget(BuildContext context, String label, Widget widget){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(Translations.of(context).text('$label'),
              style: themeData.primaryTextTheme.display4,),
          ),
          Expanded(
            flex: 4,
            child: widget,
          ),
        ],
      ),
    );
  }
  static Widget buildRowEvents(BuildContext context, String label, String result){
    TextStyle styleLabel = TextStyle(fontFamily: 'Google sans', fontSize: 12.0,fontWeight: FontWeight.w500,color: kColorSecondaryText);
    TextStyle styleResult = TextStyle(fontFamily: 'Google sans', fontSize: 12.0,wordSpacing: 3,color: kColorSecondaryText);

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(Translations.of(context).text('$label'),
              style: styleLabel),
          ),
          Expanded(
            flex: 4,
            child: Text(result,style: styleResult),
          ),
        ],
      ),
    );
  }
  static Widget buildPleaseWait(){
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  static Widget buildNoInternet(BuildContext context, onTap){
    return Center(
      child: InkWell(
          child: Container(
            height: MediaQuery.of(context).size.height ,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image.asset("assets/images/nointernet.png",color: Colors.grey,width: 150,height: 150,),
                Text(
                  Translations.of(context).text('no_internet'),
                  style: new TextStyle(
                    fontFamily: 'Google sans',
                    fontSize: 24.0,
                    color: Colors.black45,
                  ),
                ),
                Text(
                  Translations.of(context).text('tap_to_retry'),
                  style: new TextStyle(
                    fontFamily: 'Google sans',
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
          onTap: () => onTap()
      )
    );
  }
  static Widget buildNoResultSearch(BuildContext context){

    return Center(
        child: Text(
          Translations.of(context).text('no_results_found'),
          style: new TextStyle(
            fontFamily: 'Google sans',
            fontSize: 18.0,
            color: Colors.grey,
          ),
        ),
    );
  }
  static Widget buildRowAction(BuildContext context, String label, action, Widget image){
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
            onTap: (){
              action(context);
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right: new BorderSide(width: 1.0, color: Color(0xff007B97)))),
                child: image //
            ),
            title: Text(Translations.of(context).text('$label'),
              style: themeData.primaryTextTheme.display4,),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 30.0)
        )
    );
  }

  static Widget buildRowMissingMetamorphosis(BuildContext context, String label){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('$label',style: themeData.primaryTextTheme.display1),

          ),
          Expanded(
            flex: 9,
            child: Text(Translations.of(context).text("missing"),style: themeData.primaryTextTheme.display3,textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }
  static Widget buildRowMetamorphosis(BuildContext context, String label, String result){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(Translations.of(context).text('$label'),
              style: themeData.primaryTextTheme.display4,),
          ),
          Expanded(
            flex: 1,
            child: Text(result,style: themeData.primaryTextTheme.subhead,),
          ),
        ],
      ),
    );
  }
  static Widget buildInfoMetamorphosis(BuildContext context, String label, String num, String date){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('$label',style: themeData.primaryTextTheme.display1),
          ),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildRowMetamorphosis(context,'number_of_metamorphosis','$num'),
                buildRowMetamorphosis(context,'recorded_date','$date')
              ],
            )
          ),
        ],
      ),
    );
  }
  static Widget buildButtonAction(BuildContext context, String label, action){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: 100,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          //minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          onPressed: (){
            action(context);
          },
          child: Text(Translations.of(NavigatorStateFromKeyOrContext.getKey(context).currentContext).text('$label'),
              textAlign: TextAlign.center,
              style: styleButton),
        ),
      ),
    );
  }
  static Widget buildBigButtonAction(BuildContext context, String label, action){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Material(
        //elevation: 5.0,
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          //minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          onPressed: (){
            action(context);
          },
          child: Text(Translations.of(context).text('$label'),
              textAlign: TextAlign.center,
              style: styleButton),
        ),
      ),
    );
  }
  static Widget buildTitleDialog(BuildContext context,String label){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.white,fontWeight: FontWeight.w500);
    return Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      decoration: BoxDecoration(
        color: kColorBackground,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0)),
      ),
      child: Text(
        Translations.of(context).text('$label'),
        style: styleButton ,
        textAlign: TextAlign.center,
      ),
    );
  }
  static Widget buildButtonDismiss(BuildContext context, String label){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      width: 100,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(25.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
          //minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          onPressed: (){
            Navigator.of(context).pop();
          },
          child: Text(Translations.of(NavigatorStateFromKeyOrContext.getKey(context).currentContext).text('$label'),
              textAlign: TextAlign.center,
              style: styleButton),
        ),
      ),
    );
  }
  static Widget buildRadioBuyer(BuildContext context,int _radioBuyer, _handleRadioBuyer, ThemeData themeData){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Radio(
          value: 0,
          groupValue: _radioBuyer,
          onChanged: _handleRadioBuyer,
        ),
        new Text(
          Translations.of(context).text('hatchery'),
          style: themeData.primaryTextTheme.display3,
        ),
        new Radio(
          value: 1,
          groupValue: _radioBuyer,
          onChanged: _handleRadioBuyer,
        ),
        new Text(
          Translations.of(context).text('farmer'),
          style: themeData.primaryTextTheme.display3,
        ),
      ],
    );
  }
  static Widget buildRadioBuySale(BuildContext context,int _radio, _handleRadio, ThemeData themeData){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('Type',style: themeData.primaryTextTheme.display1,),
        ),
        new Radio(
          value: 1,
          groupValue: _radio,
          onChanged: _handleRadio,
        ),
        new Text(
          Translations.of(context).text('buy'),
          style: themeData.primaryTextTheme.display3,
        ),
        new Radio(
          value: 2,
          groupValue: _radio,
          onChanged: _handleRadio,
        ),
        new Text(
          Translations.of(context).text('sell'),
          style: themeData.primaryTextTheme.display3,
        ),
      ],
    );
  }
  static Widget buildRadioYesOrNo(BuildContext context,int _radio, _handleRadio,String label, ThemeData themeData){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(Translations.of(context).text('$label'),
            style: themeData.primaryTextTheme.display4,),
        ),
        new Radio(
          value: 1,
          groupValue: _radio,
          onChanged: _handleRadio,
        ),
        new Text(
          Translations.of(context).text('yes'),
          style: themeData.primaryTextTheme.display3,
        ),
        new Radio(
          value: 2,
          groupValue: _radio,
          onChanged: _handleRadio,
        ),
        new Text(
          Translations.of(context).text('no'),
          style: themeData.primaryTextTheme.display3,
        ),
      ],
    );
  }
  static Widget buildRowDetailsYesNo(BuildContext context, String label, String result){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(Translations.of(context).text('$label'),
              style: themeData.primaryTextTheme.display4,),
          ),
          Expanded(
            flex: 4,
            child: Text('${result == "1" ?
            Translations.of(context).text('yes') : Translations.of(context).text('no')
            }',style: themeData.primaryTextTheme.display3,),
          ),
        ],
      ),
    );
  }
  static Widget buildMenu(BuildContext context, String label, action){
    TextStyle style = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.white);
    return new GestureDetector(
        onTap: (){
          action();
        },
        child: new Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
              colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
            ),
            color: Color(0xFF00bfa5),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2F4F4F),
                offset: const Offset(3.0, 3.0),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              )
            ]
          ),
          width:  MediaQuery.of(context).size.width / 1.25,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
            child: Text(Translations.of(context).text("$label"),style: style,textAlign: TextAlign.center,),
          )
        )
    );
  }
  static Widget introductionRegister(BuildContext context, _actionNext){
    TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('introduce_signup'),style:styleTitle,)
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',_actionNext),
          ],
        ),
      ),
    );
  }
  static Widget endRegister(BuildContext context, _actionNext){
    TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text('Xác nhận đồng ý đăng ký',style:styleTitle,)
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'register',_actionNext),
          ],
        ),
      ),
    );
  }
  static Widget widgetTextRegister(BuildContext context, ThemeData themeData, String label,
      String hint, TextEditingController controller, bool visible, _actionNext, _actionSkip){
    TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
    TextStyle styleInput = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.black,decoration: TextDecoration.none);
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                style: styleInput,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: styleInput,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',_actionNext),
            Visibility(
              child: ViewsWidget.buildBigButtonAction(context,'skip',_actionSkip),
              visible: visible,
            )
          ],
        ),
      ),
    );
  }
  static Widget widgetNumberRegister(BuildContext context, ThemeData themeData, String label,
      String hint, TextEditingController controller, bool visible, _actionNext, _actionSkip){
    TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
    TextStyle styleInput = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.black,decoration: TextDecoration.none);
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: controller,
                textAlign: TextAlign.center,
                style: styleInput,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: styleInput,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',_actionNext),
            Visibility(
              child: ViewsWidget.buildBigButtonAction(context,'skip',_actionSkip),
              visible: visible,
            )
          ],
        ),
      ),
    );
  }
  static Widget widgetYearRegister(BuildContext context, ThemeData themeData,
      String label, String hint, TextEditingController controller, _actionNext, _yearPicker){
    TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
    TextStyle styleInput = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.black,decoration: TextDecoration.none);
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
              child: TextField(
                onTap: (){
                  _yearPicker();
                },
                controller: controller,
                textAlign: TextAlign.center,
                style: styleInput,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: styleInput,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',_actionNext),
          ],
        ),
      ),
    );
  }
  static showAlertDialog(BuildContext context, String content){
    return showDialog(
      context: context,
      builder: (ctx) => new AlertDialog(
        title: Center(child: new Text('Thông báo'),),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : <Widget>[
            Expanded(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,

                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          Row (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Center(child: new Text(Translations.of(context).text('confirm'))),
                ),
              ]
          )

        ],
      ),
    ) ?? false;
  }
  static Widget getAppBar(BuildContext context, String title) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return AppBar(
      title: Text(Translations.of(context).text('$title'),
      style: themeData.primaryTextTheme.caption,),
    );
  }
}