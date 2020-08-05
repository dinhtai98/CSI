import 'dart:io';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/nguoilaodong.dart';
import 'package:flutter_helloworld/screens/signup/success_signup.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/screens/login/menu_login.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/translations.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpWorker extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SignUpWorkerState();
  }

// This widget is the root of your application.

}
class SignUpWorkerState extends State<SignUpWorker> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog pr;
  TextStyle styleTitle = TextStyle(fontFamily: 'Google sans', fontSize: 24.0,color: kColorText,fontWeight: FontWeight.w500);

  PageController controllerPageView = PageController();

  DateTime selc = DateTime.now();

  var  txtName = new TextEditingController(), txtIDNumber = new TextEditingController(),
      txtEmail = new TextEditingController(), txtAvatar = new TextEditingController(),
      txtAddress = new TextEditingController(), txtCurStatus = new TextEditingController(),
      txtPhone = new TextEditingController(), txtStartYear = new TextEditingController();

  int step = 0;
  int _radioExpertise = 0;
  void _handleTypeOfExpertise(int value) {
    setState(() {
      _radioExpertise = value;
    });
  }
  int _radioStatus = 0;
  void _handleTypeOfStatus(int value) {
    setState(() {
      _radioStatus = value;
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
            appBar: ViewsWidget.getAppBar(context, 'create_account'),
            body: PageView(
              controller: controllerPageView,
              children: <Widget>[
                ViewsWidget.introductionRegister(context,clickContinnue),
                ViewsWidget.widgetTextRegister(context, themeData, 'full_name', '_ _ _ _ _', txtName, false,clickContinnue,clickSkip),
                ViewsWidget.widgetNumberRegister(context, themeData, 'id_number', '_ _ _ _ _', txtIDNumber, false,clickContinnue,clickSkip),
                ViewsWidget.widgetNumberRegister(context, themeData, 'mobile_phone', '_ _ _ _ _', txtPhone, false,clickContinnue,clickSkip),
                ViewsWidget.widgetTextRegister(context, themeData, 'email', '_ _ _ _ _', txtEmail, true,clickContinnue,clickSkip),
                ViewsWidget.widgetTextRegister(context, themeData, 'address', '_ _ _ _ _', txtAddress, false,clickContinnue,clickSkip),
                ViewsWidget.widgetYearRegister(context, themeData, 'year_start_working', '_ _ _ _ _', txtStartYear,clickContinnue, _yearPicker),
                widgetRadioRegisterExpertise(context, themeData, 'expertise', false,_radioExpertise,_handleTypeOfExpertise ),
                widgetRadioRegisterCurStatus(context, themeData, 'current_status', false,_radioStatus,_handleTypeOfStatus),
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
  Widget widgetRadioRegisterExpertise(BuildContext context, ThemeData themeData, String label, bool visible, int _radio, _handle){
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
                  groupValue: _radio,
                  onChanged: _handle,
                ),
                new Text(
                  'Quản lý',
                  style: themeData.primaryTextTheme.display3,
                )
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 2,
                  groupValue: _radio,
                  onChanged: _handle,
                ),
                new Text(
                  'Kinh doanh',
                  style: themeData.primaryTextTheme.display3,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 3,
                  groupValue: _radio,
                  onChanged: _handle,
                ),
                new Text(
                  'Kỹ thuật',
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
  Widget widgetRadioRegisterCurStatus(BuildContext context, ThemeData themeData, String label, bool visible, int _radio, _handle){
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
                  groupValue: _radio,
                  onChanged: _handle,
                ),
                new Text(
                  'Lao động tự do',
                  style: themeData.primaryTextTheme.display3,
                )
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 4,),
                new Radio(
                  value: 2,
                  groupValue: _radio,
                  onChanged: _handle,
                ),
                new Text(
                  'Đang làm việc',
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
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Bạn có muốn dừng đăng ký không?'),
        content: new Text('Nếu dừng bây giờ, bạn sẽ mất toàn bộ tiến trình cho đến nay.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Tiếp tục'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Dừng'),
          ),
        ],
      ),
    ) ?? false;
  }
  clickContinnue(BuildContext context){
    FocusScope.of(context).requestFocus(FocusNode());
    int flag = 1;
    switch(step) {
      case 1:
        if (txtName.text.toString() == "")
          flag = 0;
        break;
      case 2:
        if (txtIDNumber.text.toString() == "")
          flag = 0;
        break;
      case 3:
        if (txtPhone.text.toString() == "")
          flag = 0;
        break;
      case 4:
        if (txtEmail.text.toString() == "")
          flag = 0;
        break;
      case 5:
        if (txtAddress.text.toString() == "")
          flag = 0;
        break;
      case 6:
        if (txtStartYear.text.toString() == "")
          flag = 0;
        break;
      case 7:
        if(_radioExpertise == 0) {
          flag = -1;
          Toast.show(Translations.of(context).text('please_choose'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        break;
      case 8:
        if(_radioStatus == 0) {
          flag = -1;
          Toast.show(Translations.of(context).text('please_choose'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        break;
      case 9:
        _signupNguoiLaoDong(context);
        flag = -1;
        break;
    }
    if(flag == 1){
      controllerPageView.nextPage(duration: kTabScrollDuration, curve: Curves.ease);
      setState(() {
        step += 1;
      });
    }else if(flag != -1){
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  clickSkip(BuildContext context){
    controllerPageView.nextPage(duration: kTabScrollDuration, curve: Curves.ease);
    setState(() {
      step += 1;
    });
    print("tab skip = " + step.toString());
    //controllerPageView.previousPage(duration: Duration(seconds: 1), curve: null);
  }
  showAlertDialog(String content){
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Center(child: new Text('Xác nhận')),
                ),
              ]
          )

        ],
      ),
    ) ?? false;
  }

  _signupNguoiLaoDong(BuildContext context) async {
    var _checkInternet = function.checkInternet();
    _checkInternet.then((onValue) async {
      if (onValue) {
        pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
        pr.style(
          message: Translations.of(context).text('please_wait'),
        );
        pr.show();
        String startYear = function.formatDateCSDL(selc);
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(NguoiLaoDong.queryDangKyNguoiLaoDong(
                txtName.text.toString(), txtIDNumber.text.toString(), txtPhone.text.toString(), txtEmail.text.toString(),txtAddress.text.toString(),
                startYear, _radioExpertise , _radioStatus,)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        Data data = Data.fromJson(jsonData[0]);
        String att1 = data.att1.toString();
        if (att1.contains("CSIID")) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SuccessSignup(username: att1)));
            });
          });
        }else if(att1.contains("existsid")){
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              showAlertDialog('Số CMND (Hộ chiếu) đã tồn tại');
              setState(() {
                step = 2;
                controllerPageView.jumpToPage(step);
              });
            });
          });
        }else if(att1.contains("existsphone")){
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().whenComplete((){
              showAlertDialog('Số điện thoại đã tồn tại');
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