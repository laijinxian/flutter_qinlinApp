import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Http.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  String _phone = '';
  String _smCode = '';
  bool _isDisabled = true;
  bool _checkboxSelected = false;
  bool _isSendCode;
  Timer _timer;
  int _seconds;
  FocusNode _autofocus = FocusNode();
  void initState() {
    _seconds = 60;
    _isSendCode = false;
    super.initState();
  }
  // 倒计时
  void countdownTime () async {
    try {
      var response = await HttpUtil().post("ccb/sendSms?phone=$_phone&resource=1&", 'mobile', 'formData', false);
      if (response["code"] == 0) {
        _isSendCode = true;
        // 验证码框自动聚焦
        Future.delayed(Duration(milliseconds: 200), (){
          FocusScope.of(context).requestFocus(_autofocus); 
           BotToast.showText(
            text: '验证码已发送请注意查收',
            align: Alignment(0, 0.1),
            onlyOne: true, 
          );
        });
        _seconds = 60;
        _timer = Timer.periodic(new Duration(seconds: 1), (timer) {
          setState(() {
            _seconds--;
          });
          if (_seconds <= 0) {
            _isSendCode = false;
            _timer?.cancel();
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
  // 登录按钮状态重置
  void _resetButonState () {
    setState(() {
      _isDisabled = _phone.length == 11 && _smCode.length == 6 && _checkboxSelected ? false : true;
    });
  }
  // 查看协议
  void _launchURL() async {
    const url = 'https://qinlinkeji.com/agreement.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  // 组件销毁释放定时器
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // title
            Container(
              margin: const EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 20.0),
              child: const Text(
                '手机登录',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            // 用户名
            Container(
              height: 80.0,
              margin: const EdgeInsets.fromLTRB(13.0, .0, 13.0, 10.0),
              child: Stack(
                alignment: const Alignment(1.0, 0.1),
                children: <Widget>[
                  TextField(
                    autofocus: true,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: "用户名",
                      hintText: "您的手机号",
                      counterText: "",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) {
                      print(v);
                      setState(() {
                        _phone = v;
                      });
                      _resetButonState();
                    },
                  ),
                  FlatButton(
                    highlightColor: Colors.transparent,
                    child: Text( _isSendCode ? '${_seconds}s重新获取' : '获取验证码',
                      style: TextStyle(color: Colors.red)),
                    onPressed: !_isSendCode ? () {
                      if (_phone.length == 11) {
                        countdownTime();
                      } else {
                        BotToast.showText(
                          text: '手机号输入有误，请检查',
                          align: Alignment(0, 0.1),
                          onlyOne: true, 
                        ); 
                      }
                    } : null,
                  )
                ],
              ),
            ),
            // 验证码
            Container(
              height: 70.0,
              margin: const EdgeInsets.fromLTRB(13.0, .0, 13.0, .0),
              child: TextField(
                maxLength: 6,
                focusNode: _autofocus,
                decoration: InputDecoration(
                  labelText: "验证码",
                  hintText: "手机验证码",
                  counterText: "",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    _smCode = v;
                  });
                  _resetButonState();
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    value: _checkboxSelected,
                    activeColor: Colors.orange, //选中时的颜色
                    onChanged: (value) {
                      setState(() {
                        _checkboxSelected = value;
                        _resetButonState();
                      });
                    },
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "我已阅读并接受用户协议"),
                    TextSpan(
                      text: "《亲邻用户使用协议》",
                      style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = _launchURL
                    ),
                  ]))
                ],
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, .0),
              child: RaisedButton(
                color: Colors.red,
                child: Text("登  录", style: TextStyle(fontSize: 20.0, color: Colors.white)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                disabledColor: Colors.grey[400],
                onPressed: !_isDisabled ? () async { // 登录
                  final prefs = await SharedPreferences.getInstance();
                  try {
                    var response = await HttpUtil().post("ccb/register?phone=$_phone&smsCode=$_smCode&", 'mobile', 'formData', false);
                    print(response);
                    if (response["code"] == 0) {
                      prefs.setString('sessionId', json.encode(response['data']['sessionId']));
                      // Navigator.pop(context, 'login');
                      Navigator.of(context).pushNamed("openDoor");
                    }
                  } catch (e) {
                    print(e);
                  }
                } : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
