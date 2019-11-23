import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './Loading.dart';
import '../main.dart';

class HttpUtil {
  static HttpUtil instance;
  final String openApi = 'https://mobileapi.qinlinkeji.com/api/';
  final String mobileApi = 'https:///openapi.qinlinkeji.com/api/';
  String sessionId; // sessionId
  Dio dio;
  BaseOptions options;

  CancelToken cancelToken = new CancelToken();

  static Future<HttpUtil> getInstance() async  {
    if (null == instance) instance = new HttpUtil();
    // 初始化本地存储能力
    return instance;
  }

  // 获取本地存储的sessionId
  Future<dynamic> getSessionId () async {
    Future<dynamic> future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return json.decode(prefs.getString("sessionId"));
    });
    await future.then((value) {
      sessionId = value ?? null;
    });
    return sessionId; 
  }

  /*
   * config it and create
   */
  HttpUtil() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = new BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: openApi,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: 5000,
      //Http请求头. 
      headers: {
        //do something
        "version": "1.0.0"
      },
      //请求的Content-Type，默认值是[ContentType.json]. 也可以用ContentType.parse("application/x-www-form-urlencoded")
      contentType: ContentType.json,
      //表示期望以那种格式(方式)接受响应数据。接受4种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      responseType: ResponseType.json,
    );

    dio = new Dio(options);

    // loading
    CancelFunc cancel; 

    //Cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));

    //添加拦截器
    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      // Do something before request is sent
      // 显示loading
      // BotToast.showLoading(allowClick: false, duration: Duration(seconds: 2));
      // cancel = BotToast.showLoading();
      // 自定义loading
      cancel = BotToast.showCustomLoading(
        ignoreContentClick: true,
        toastBuilder: (cancelFunc) {
          return Loading();
        }
      );
      return options;
    }, onResponse: (Response response) { // 请求成功
      // Do something with response data
      // 关闭其他弹窗 2个都可以
      Future.delayed(Duration(milliseconds: 100), (){
        cancel();
        print(response.data['code']);
        if (response.data['code'] == 401) {
           // sessionId 过期 跳转登录
          Router.navigatorKey.currentState.pushNamed("login");
        } else if (response.data['code'] != 0) {
          // 抛出错误      
          BotToast.showText(
            text: response.data["message"], 
            align: Alignment(0, 0.1),
            onlyOne: true, 
            duration: Duration(milliseconds: 1500)
          ); 
        }
        return response;
      });
      // BotToast.closeAllLoading();
    }, onError: (DioError e) { // 请求错误
      // Do something with response error
      Future.delayed(Duration(milliseconds: 200), (){  // 关闭其他弹窗
        cancel();
        // 抛出错误
        BotToast.showText(
          text: '网络异常，请稍后再试！', 
          align: Alignment(0, 0.1), 
          onlyOne: true, duration: 
          Duration(milliseconds: 1500)
        );
        return e;
      });
    }));

    // 开启请求日志
    dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  /*
   * get请求
   * @path 去除前缀和 sessionId 的路劲参数
   * @type 什么格式 JSON 还是 formData
   * @params 请求参数
   * @options 该请求单独的 options 配置， 会覆盖全局的 options， 无特殊情况不用传
   * @cancelToken 该请求的标识，可用于取消该请求
   */
  get(url, {params, options, cancelToken}) async {
    Response response;
    try {
      response = await dio.get(url, queryParameters: params, options: options, cancelToken: cancelToken);
      //  response.data; 响应体
      //  response.headers; 响应头
      //  response.request; 请求体
      //  response.statusCode; 状态码
    } on DioError catch (e) {
      formatError(e);
    }
    return response.data;
  }

  /*
   * post请求
   * @path 去除前缀和 sessionId 的路劲参数
   * @urlType 前缀类型 moblie --> mobileApi | open --> openApi
   * @type 什么格式 JSON 还是 formData
   * @isData 是否有body参数
   * @data 请求体body
   * @options 该请求单独的 options 配置， 会覆盖全局的 options， 无特殊情况不用传
   * @cancelToken 该请求的标识，可用于取消该请求
   */
  post(path, urlType, type, isData, {data, options, cancelToken}) async {
    // Future<dynamic> future = Future(() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   return json.decode(prefs.getString("sessionId"));
    // });
    // await future.then((value) {
    //   sessionId = value ?? null;
    // });
    // 添加sessionId
    await getSessionId();
    var url = sessionId == null ? path : '${path}sessionId=$sessionId';
    // print(sessionId.trim().isNotEmpty);
    Response response;
    FormData formData;
    // formData 格式转换
    if (isData) formData = FormData.from(data);
    try {
      isData 
      ? response = await dio.post(url, data: type == 'formData' ? formData : data, options: urlType == 'mobile' ?  RequestOptions(baseUrl: mobileApi) : options, cancelToken: cancelToken)
      : response = await dio.post(url, options: urlType == 'mobile' ? RequestOptions(baseUrl: mobileApi) : options, cancelToken: cancelToken);
      print(response);
    } on DioError catch (e) {
      formatError(e);
    }
    return response.data;
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await dio.download(urlPath, savePath,onReceiveProgress: (int count, int total){
        //进度
        print("$count $total");
      });
      print('downloadFile success---------${response.data}');
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      formatError(e);
    }
    return response.data;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      print("连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      print("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      print("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("未知错误");
    }
  }

  /*
   * 取消请求 
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}