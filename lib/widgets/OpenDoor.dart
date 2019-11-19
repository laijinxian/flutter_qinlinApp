// 开门页 && 权限申请页
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../utils/Http.dart';

class OpenDoor extends StatefulWidget {
  @override
  _OpenDoor createState() => _OpenDoor();
}

class _OpenDoor extends State<OpenDoor> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  bool visible = false;
  bool isShowCityList = true;
  String commonlyUsedDoorName = '';
  Object commonlyUsedDoor = {};
  List doorList = new List();
  List cityList = new List();
  OverlayEntry plotOverlayEntry;
  DateTime _dateTime;
  var controllerView = new ScrollController();

  @override
  // 页面初始化
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _getDoorList('13');
    animationScale();
  }

  // 初始化常用开门按钮放大缩小动画
  void animationScale() {
    controller = new AnimationController(
        duration: const Duration(seconds: 2), vsync: this);
    // 图片宽高从110变到130
    animation = new Tween(begin: 110.0, end: 130.0).animate(controller)
      ..addListener(() {
        setState(() => {});
      });

    //启动动画(正向执行)
    controller.forward();
    // 监听动画执行动态
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  // 获取门禁列表
  void _getDoorList(communityId) async {
    try {
      var response = await HttpUtil().post(
          "doorcontrol/v2/queryUserDoor", 'formData',
          data: {"communityId": communityId});
      if (response["code"] == 0) {
        setState(() {
          commonlyUsedDoor = response["data"]["commonlyUsedDoor"];
          commonlyUsedDoorName =
              response["data"]["commonlyUsedDoor"]["doorControlName"];
          doorList = response["data"]["userDoorDTOS"];
        });
        // 门禁整体左移
        controllerView.animateTo(
          12.0,
          duration: new Duration(milliseconds: 200), // 300ms
          curve: Curves.bounceIn, // 动画方式
        );
      }
      // BotToast.showText(text:"xxxx");
    } catch (e) {
      print(e);
    }
  }

  // 开门
  void _onOpenDoor(list) async {
    try {
      var response = await HttpUtil().post("doorcontrol/v2/open", 'formData',
          data: {"macAddress": list["macAddress"]});
      print(response);
      if (response["data"]["openDoorState"] != 1) {
        Future.delayed(Duration(milliseconds: 200), () {
          BotToast.showText(
              text: response["data"]["message"],
              align: Alignment(0, 0.1),
              onlyOne: true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // 页面渲染
  Widget build(BuildContext context) {
    _dateTime = DateTime.now();
    return new Scaffold(
      // 下拉刷新组件
      body: EasyRefresh(
        header: ClassicalHeader(
          refreshText: '下拉刷新',
          refreshedText: '刷新成功',
          refreshingText:  "正在刷新...",
          refreshReadyText:  "松开后开始刷新",
          infoText: '更新于 ${_dateTime.hour}: ${_dateTime.minute}'
        ),
        onRefresh: () async { // 下拉刷新
          _getDoorList('13');
          await Future.delayed(Duration(seconds: 1), (){
            
          });
        },
        onLoad: null,
        child: ListView(
          children: <Widget>[
            // 顶部轮播图
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 170.0,
              child: Swiper(
                itemBuilder: _swiperBuilder,
                itemCount: 3,
                pagination: new SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                  color: Colors.black54,
                  activeColor: Colors.white,
                )),
                scrollDirection: Axis.horizontal,
                autoplay: true,
              ),
            ),
            // 我的小区
            new Padding(
              padding: const EdgeInsets.fromLTRB(15.0, .0, 15.0, .0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 45.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Color(0xffe5e5e5)))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Text('小区： 亲邻紫光测试'),
                    ),
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Text('切换小区'),
                          new Image(
                            width: 23.0,
                            height: 15.0,
                            image: AssetImage("images/icon_community.png"),
                          )
                        ],
                      ),
                      onTap: () async {
                        var response = await HttpUtil().post(
                            "auth/v2/getApplyListGroupByCommunity", 'formData',
                            data: {"communityId": "13"});
                        Future.delayed(Duration(milliseconds: 250), () {
                          if (response["code"] == 0) {
                            setState(() {
                              cityList = response["data"];
                            });
                            choicePlot();
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            // 常用开门按钮
            new Offstage(
              offstage: visible,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: new Image(
                          width: animation.value,
                          height: animation.value,
                          fit: BoxFit.contain,
                          image: AssetImage("images/open-door.png"),
                        ),
                        onTap: () {
                          _onOpenDoor(commonlyUsedDoor);
                        },
                      ),
                      // ScaleTransition(
                      //   scale: controller,
                      //   child:  new Image(
                      //     width: 400.0,
                      //     height: 120.0,
                      //     fit: BoxFit.contain,
                      //     image: AssetImage("images/open-door.png"),
                      //   ),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: new Text('常用门禁：$commonlyUsedDoorName',
                            style: TextStyle(fontSize: 18.0)),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // 门禁列表
            new Container(
              height: 120.0,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Transform.rotate(
                    angle: math.pi,
                    child: new Image(
                      width: 30.0,
                      fit: BoxFit.fitHeight,
                      image: AssetImage("images/community-more.png"),
                    ),
                  ),
                  Expanded(
                    child: new Container(
                        // 门禁列表渲染
                        child: _doorListBuild()),
                  ),
                  new Image(
                    width: 30.0,
                    fit: BoxFit.fitHeight,
                    image: AssetImage("images/community-more.png"),
                  ),
                ],
              ),
            ),
            // footer
            new Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                width: MediaQuery.of(context).size.width,
                child: new Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 5.0),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: '物业电话： '),
                          TextSpan(
                              text: '0755 - 8208208820',
                              style: TextStyle(color: Colors.red))
                        ])),
                      ),
                      Text('温馨提示： 如开门遇到问题，请拨打物业电话进行处理')
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // 门禁列表渲染函数
  Widget _doorListBuild() {
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    //   scrollDirection: Axis.horizontal,
    //   children: doorList.map((list) { // 动态渲染门禁列表
    //     return _buildList(list);
    //   }).toList(),
    // );

    return new ListView.builder(
        itemCount: doorList.length,
        controller: controllerView,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 215),
              child: SlideAnimation(
                //滑动动画
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  //渐隐渐现动画
                  child: _buildList(doorList[index]),
                ),
              ));
        });
  }

  Widget _buildList(list) {
    return new Container(
      width: 85.0,
      margin: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Column(
              children: <Widget>[
                FlatButton(
                  child: Image(
                    width: 60.0,
                    height: 60.0,
                    image: AssetImage("images/open-door.png"),
                  ),
                  onPressed: () async {
                    _onOpenDoor(list);
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  child: Text(list["doorControlName"],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 14.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 轮播图渲染函数 showModalBottomSheet
  Widget _swiperBuilder(BuildContext context, int index) {
    return (new Image(
      image: AssetImage("images/banner$index.jpg"),
      fit: BoxFit.cover, // 会按图片的长宽比放大后居中填满显示空间，图片不会变形，超出显示空间部分会被剪裁
    ));
    // return (Image.network(
    //   images[index % images.length],
    //   fit: BoxFit.fill,
    // ));
  }

  // 小区选择
  void choicePlot() {
    plotOverlayEntry = new OverlayEntry(builder: (context) {
      // 堆叠组件
      return new Stack(
        children: <Widget>[
          // 遮罩层
          new GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 800.0,
              color: Colors.black38,
            ),
            onTap: () {
              plotOverlayEntry.remove();
            },
          ),
          // 小区列表
          new Positioned(
              top: kToolbarHeight,
              width: MediaQuery.of(context).size.width,
              child: new SafeArea(
                  child: new Material(
                      child: new Container(
                height: 420.0,
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: doorList.length,
                          controller: controllerView,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 215),
                                child: SlideAnimation(
                                  //滑动动画
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    //渐隐渐现动画
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))),
                                        child: ListTile(
                                          title: new Text('Flutter app'),
                                          trailing: new Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                          onTap: () {
                                            _getDoorList(cityList[index]["communityId"]);
                                            plotOverlayEntry.remove();
                                          },
                                        )),
                                  ),
                                ));
                          }),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[100],
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 33.0,
                            margin: const EdgeInsets.fromLTRB(.0, 7.0, .0, 7.0),
                            child: FlatButton(
                              color: Colors.red,
                              colorBrightness: Brightness.dark,
                              splashColor: Colors.grey,
                              child: Text("申请更多权限"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )))),
        ],
      );
    });
    Overlay.of(context).insert(plotOverlayEntry);
  }
}
