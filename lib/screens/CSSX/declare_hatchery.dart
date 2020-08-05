/*
import 'dart:io';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/screens/signup/success_signup.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeclareHatchery extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DeclareHatcheryState();
  }

// This widget is the root of your application.

}
class DeclareHatcheryState extends State<DeclareHatchery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog pr;

  TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);
  TextStyle styleInput = TextStyle(fontFamily: 'Google sans', fontSize: 20.0,color: Colors.black,decoration: TextDecoration.none);
  //File file;
  //Future<File> imageFile;

  DateTime selc = DateTime.now();

  PageController controllerPageView = PageController();

  var  txtNameCompany = new TextEditingController(), txtWebsite = new TextEditingController(),
      txtOwner = new TextEditingController(), txtPhoto = new TextEditingController(),
      txtAddress = new TextEditingController(), txtBussinessNumber = new TextEditingController(),
      txtStartYear = new TextEditingController(), txtNKhuSX = new TextEditingController();
  String speciesProducing = "";
  var arrCheck = [false, false, false, false, false, false, false, false, false];
  int step = 0;
  // 1: SX, 2: SX & KD, 3: KD
  int _radioTypeOfBusiness = 0;
  void _handleTypeOfBusiness(int value) {
    setState(() {
      _radioTypeOfBusiness = value;
    });
  }
  int _radioTypeOfHatchery = 0;
  void _handleTypeOfHatchery(int value) {
    setState(() {
      _radioTypeOfHatchery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          //resizeToAvoidBottomPadding: true,
          //resizeToAvoidBottomInset: false,
            appBar: ViewsWidget.getAppBar(context, 'registration_of_hatchery'),
            body: PageView(
              controller: controllerPageView,
              children: <Widget>[
                ViewsWidget.introductionRegister(context,clickContinnue),
                ViewsWidget.widgetTextRegister(context, themeData, 'company_name', '_ _ _ _ _', txtNameCompany, false,clickContinnue,clickSkip),
                ViewsWidget.widgetTextRegister(context, themeData, 'business_owner', '_ _ _ _ _', txtOwner, false,clickContinnue,clickSkip),
                ViewsWidget.widgetNumberRegister(context, themeData, 'business_number', '_ _ _ _ _', txtBussinessNumber, false,clickContinnue,clickSkip),
                ViewsWidget.widgetTextRegister(context, themeData, 'address', '_ _ _ _ _', txtAddress, false,clickContinnue,clickSkip),
                ViewsWidget.widgetTextRegister(context, themeData, 'website', '_ _ _ _ _', txtWebsite, true,clickContinnue,clickSkip),
                ViewsWidget.widgetYearRegister(context, themeData, 'establish_year', '_ _ _ _ _', txtStartYear,clickContinnue, _yearPicker),
                //widgetPickUpImage(),
                widgetRadioTypeHatchery(context, themeData, 'type_of_hatchery', false),
                widgetRadioTypeBussinessRegister(context, themeData, 'type_of_business', false),
                widgetCheckBoxSpecies(context, themeData, 'species_producted_or_marketed', false),
                ViewsWidget.widgetNumberRegister(context, themeData, 'n_of_production_cluster', '_ _ _ _ _', txtNKhuSX, false,clickContinnue,clickSkip),
                ViewsWidget.endRegister(context,clickContinnue)
              ],
              physics:new NeverScrollableScrollPhysics(),

            )
        ),
      )
    );
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
                      txtStartYear.text = selc.year.toString();
                    });
                    Navigator.of(context).pop(false);
                  },
                ),
              ));
        });
  }
  Widget widgetRadioTypeBussinessRegister(BuildContext context, ThemeData themeData, String label, bool visible){
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 1,
                  groupValue: _radioTypeOfBusiness,
                  onChanged: _handleTypeOfBusiness,
                ),
                new Text(
                  'Sản xuất',
                  style: themeData.primaryTextTheme.display3,
                )
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 2,
                  groupValue: _radioTypeOfBusiness,
                  onChanged: _handleTypeOfBusiness,
                ),
                new Text(
                  'Sản xuất & Kinh doanh',
                  style: themeData.primaryTextTheme.display3,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 3,
                  groupValue: _radioTypeOfBusiness,
                  onChanged: _handleTypeOfBusiness,
                ),
                new Text(
                  'Kinh doanh',
                  style: themeData.primaryTextTheme.display3,
                ),
              ],
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',clickContinnue),
            Visibility(
              child: ViewsWidget.buildBigButtonAction(context,'skip',clickSkip),
              visible: visible,
            )
          ],
        ),
      ),
    );
  }
  Widget widgetRadioTypeHatchery(BuildContext context, ThemeData themeData, String label, bool visible){
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 1,
                  groupValue: _radioTypeOfHatchery,
                  onChanged: _handleTypeOfHatchery,
                ),
                new Text(
                  'Kinh doanh tôm bố mẹ',
                  style: themeData.primaryTextTheme.display3,
                )
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 2,
                  groupValue: _radioTypeOfHatchery,
                  onChanged: _handleTypeOfHatchery,
                ),
                new Text(
                  'Kinh doanh Nauplii',
                  style: themeData.primaryTextTheme.display3,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 3,
                  groupValue: _radioTypeOfHatchery,
                  onChanged: _handleTypeOfHatchery,
                ),
                new Text(
                  'Kinh doanh Postlarvea',
                  style: themeData.primaryTextTheme.display3,
                ),
              ],
            ),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',clickContinnue),
            Visibility(
              child: ViewsWidget.buildBigButtonAction(context,'skip',clickSkip),
              visible: visible,
            )
          ],
        ),
      ),
    );
  }
  Widget widgetCheckBoxSpecies(BuildContext context, ThemeData themeData, String label, bool visible){
    return Center(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(Translations.of(context).text('$label'),style:styleTitle,)
            ),
            singleCheckBoxSpecies('penaeus_vanamei',arrCheck[1], 1),
            singleCheckBoxSpecies('penaeus_monodon',arrCheck[2],2),
            singleCheckBoxSpecies('penaeus_merguiensis',arrCheck[3],3),
            singleCheckBoxSpecies('penaeus_indicus', arrCheck[4],4),
            singleCheckBoxSpecies('penaeus_chinensis',arrCheck[5],5),
            singleCheckBoxSpecies('penaeus_japonicus',arrCheck[6],6),
            singleCheckBoxSpecies('macrobrachium_rosenbergii',arrCheck[7],7),
            singleCheckBoxSpecies('shrimp_other',arrCheck[8],8),
            SizedBox(height: 30,),
            ViewsWidget.buildBigButtonAction(context,'next',clickContinnue),
            Visibility(
              child: ViewsWidget.buildBigButtonAction(context,'skip',clickSkip),
              visible: visible,
            )
          ],
        ),
      ),
    );
  }
  Widget singleCheckBoxSpecies(String label, bool value, int pos){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Row(
      children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width / 10),
        new Checkbox(
          value: value,
          onChanged: (bool value) {
            setState(() {
              arrCheck[pos] = value;
            });
          }
        ),
        new Text(
          Translations.of(context).text(label),
          style: themeData.primaryTextTheme.display3,
        )
      ],
    );
  }
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (ctx) => new AlertDialog(
        title: new Text(Translations.of(context).text('stop_signup')),
        content: new Text(Translations.of(context).text('alert_stop_signup')),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: new Text(Translations.of(context).text('continue')),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: new Text(Translations.of(context).text('stop')),
          ),
        ],
      ),
    ) ?? false;
  }

  clickContinnue(BuildContext context){
    FocusScope.of(context).requestFocus(FocusNode());
    int flag = 1;

    switch(step){
      case 1:
        if(txtNameCompany.text.toString() == "")
          flag = 0;
        break;
      case 2:
        if(txtOwner.text.toString() == "")
          flag = 0;
        break;
      case 3:
        if(txtBussinessNumber.text.toString() == "")
          flag = 0;
        break;
      case 4:
        if(txtAddress.text.toString() == "")
          flag = 0;
        break;
      case 5:
        if(txtWebsite.text.toString() == "")
          flag = 0;
        break;
      case 6:
        if(txtStartYear.text.toString() == "")
          flag = 0;
        break;
      case 7:
        if(_radioTypeOfHatchery == 0) {
          flag = -1;
          Toast.show(Translations.of(context).text('please_choose'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        break;
      case 8:
        if(_radioTypeOfBusiness == 0) {
          flag = -1;
          Toast.show(Translations.of(context).text('please_choose'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        break;
      case 9:
        if(arrCheck.contains(true)) {
          flag = 1;
        }else{
          flag = -1;
          Toast.show(Translations.of(context).text('please_choose'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        if(_radioTypeOfBusiness == 3){
          step += 1;
        }
        break;
      case 10:
        if(txtNKhuSX.text.toString() == "")
          flag = 0;
        break;
      case 11:
        _signupHatchery(context);
        flag = -1;
        break;
    }
    if(flag == 1){
      //controllerPageView.nextPage(duration: kTabScrollDuration, curve: Curves.ease);
      setState(() {
        step += 1;
        controllerPageView.animateToPage(step,duration: kTabScrollDuration, curve: Curves.ease);
        //controllerPageView.jumpToPage(step);
      });
    }else if(flag != -1){
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
    //controllerPageView.nextPage(duration: Duration(seconds: 1), curve: null);
  }
  clickSkip(BuildContext context){
    FocusScope.of(context).requestFocus(FocusNode());
    controllerPageView.nextPage(duration: kTabScrollDuration, curve: Curves.ease);
    setState(() {
      step += 1;
    });
  }
  _signupHatchery(BuildContext context) async {
    var _checkInternet = function.checkInternet();
    _checkInternet.then((onValue) async {
      if (onValue) {
        pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
        pr.style(
          message: Translations.of(context).text('please_wait'),
        );
        pr.show();
        String startYear = function.formatDateCSDL(selc);
        speciesProducing = "";
        for(int i = 1 ; i < arrCheck.length; i++) {
          if (arrCheck[i])
            speciesProducing += i.toString() + ',';
        }
        int nKhu = 0;
        if(_radioTypeOfBusiness < 3){
          nKhu = int.parse(txtNKhuSX.text.toString());
        }
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Hatchery.queryDangKyCoSoSanXuat(
                txtNameCompany.text.toString(), txtOwner.text.toString(), txtWebsite.text.toString(), txtBussinessNumber.text.toString(),
                txtAddress.text.toString(), startYear, txtPhoto.text.toString(), _radioTypeOfBusiness,
                _radioTypeOfHatchery, speciesProducing.substring(0,speciesProducing.length - 1), nKhu)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        if (result.contains("CSIID")) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete(() {
              var jsonData = json.decode(result);
              Data data = Data.fromJson(jsonData[0]);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SuccessSignup(username: data.att1.toString(),)));
              print('result $result');
            }) ;
          });
          //existsbusiness
        }else if(result.contains("existsbusiness")){
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              ViewsWidget.showAlertDialog(context, 'Số doanh nghiệp đã tồn tại');
              setState(() {
                step = 3;
                controllerPageView.jumpToPage(step);
              });
            });
          });
        }

        Future.delayed(Duration(seconds: 2)).then((value) {
          pr.hide();
        });
      }else{
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(Translations.of(context).text('no_internet')),
              duration: Duration(seconds: 1),
            ));
      }
    });
  }

}

 */