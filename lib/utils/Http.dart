import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/rendering.dart';
import './ShowLoading.dart';

class HttpUtil {
  static HttpUtil instance;
  final String sesstion = 'h5:402880ae6e83b238016e83b251d00001'; // sesstionId 接口凭证 正式开发应由通过登录获取并存储起来
  Dio dio;
  BaseOptions options;

  CancelToken cancelToken = new CancelToken();

  static HttpUtil getInstance() {
    if (null == instance) instance = new HttpUtil();
    return instance;
  }

  /*
   * config it and create
   */
  HttpUtil() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = new BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: "https://uat-mobileapi.qinlinkeji.com/api/",
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
          return ShowLoading();
        }
      );
      return options;
    }, onResponse: (Response response) { // 请求成功
      // Do something with response data
      // 关闭其他弹窗 2个都可以
      Future.delayed(Duration(milliseconds: 200), (){
        cancel();
        if (response.data['code'] != 0) {  
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
      //  response.data; 响应体
      //  response.headers; 响应头
      //  response.request; 请求体
      //  response.statusCode; 状态码
      response = await dio.get(url, queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      formatError(e);
    }
    return response.data;
  }

  /*
   * post请求
   * @path 去除前缀和 sessionId 的路劲参数
   * @type 什么格式 JSON 还是 formData
   * @data 请求体body
   * @options 该请求单独的 options 配置， 会覆盖全局的 options， 无特殊情况不用传
   * @cancelToken 该请求的标识，可用于取消该请求
   */
  post(path, type, {data, options, cancelToken}) async {
    // 添加sessionId
    var url = '$path?sessionId=$sesstion';
    Response response;
    // formData 格式转换
    FormData formData = FormData.from(data);
    try {
      response = await dio.post(url, data: type == 'formData' ? formData : data, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      print('post error---------$e');
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
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}

